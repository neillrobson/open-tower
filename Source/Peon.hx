package;

import openfl.display.TileContainer;
import Job.Hunt;
import event.JobEvent;
import openfl.display.Tile;

using haxe.EnumTools.EnumValueTools;
using Std;

enum PeonType {
    PEON;
    WARRIOR;
    MONSTER;
}

class Peon extends Entity {
    static inline final BASE_SPEED_PEON = 10 * Main.SECONDS_PER_TICK;
    static inline final BASE_SPEED_MONSTER = 8 * Main.SECONDS_PER_TICK;
    static inline final MAX_WANDER_TIME = Std.int(1.1 * Main.TICKS_PER_SECOND);
    static inline final MIN_WANDER_TIME = Std.int(0.1 * Main.TICKS_PER_SECOND);

    static inline final HEALTH_BAR_WIDTH = 4;

    static final animSteps = [0, 1, 0, 2];
    static final animDirs = [2, 0, 3, 1];

    var body = new Tile();
    var carried = new Tile();
    var health = new TileContainer();

    public var job(default, set):Job;
    public var type(default, set):PeonType;

    var typeIndex:Int;

    var hp(default, set) = 100;
    var maxHp = 100;

    public var rot:Float;

    var baseSpeed:Float;
    var moveTick:Float;
    var wanderTime:Int = 0;

    override public function new(x:Float, y:Float, type:PeonType, island:Island,
            spriteSheet:SpriteSheet) {
        super(x, y, 1, island, spriteSheet);

        sprite.addTile(body);
        sprite.addTile(carried);
        carried.y = -3;
        carried.alpha = 0;

        sprite.addTile(health);
        health.x = 2;
        health.y = -2;
        health.alpha = 0;
        health.addTile(new Tile(spriteSheet.healthBar[1].id, 0, 0, HEALTH_BAR_WIDTH));
        health.addTile(new Tile(spriteSheet.healthBar[0].id, 0, 0, HEALTH_BAR_WIDTH));

        sprite.originX = 4;
        sprite.originY = 8;

        rot = Math.random() * 2 * Math.PI;
        moveTick = Math.random() * 12;

        this.type = type;
    }

    override function update() {
        super.update();

        if (job != null)
            job.update();

        if (job == null) {
            var enemy = type == PEON ? getRandomTarget(30, 15,
                isEnemy) : getRandomTarget(70, 80, isEnemy);
            if (enemy != null) {
                job = new Hunt(island, this, enemy);
            }
        }

        if (hp < maxHp && Math.random() < 0.2)
            ++hp;

        // Calculate speed and direction.
        // If arrived at job, don't move; instead, do a job.arrived() tick
        var speed = baseSpeed;
        if (wanderTime == 0 && job != null && job.hasTarget()) {
            var rd = job.targetDistance + r;
            rot = Math.atan2(job.target.y - y, job.target.x - x);

            if (distance(job.target) < rd * rd) {
                job.arrived();
                speed = 0;
            }
        } else {
            rot += (Math.random() - 0.5) * Math.random() * 2;
        }

        if (wanderTime > 0)
            --wanderTime;

        var xt = x + Math.cos(rot) * speed;
        var yt = y + Math.sin(rot) * speed;

        // If we can't move to the designated space, let the job know that we've
        // collided with something, and do a brief random walk to get around the
        // obstacle
        if (island.isFree(xt, yt, r, this)) {
            x = xt;
            y = yt;
        } else {
            if (job != null) {
                var collided = island.getEntityAt(xt, yt, r, null, this);
                if (collided != null) {
                    job.collide(collided);
                } else {
                    job.cantReach();
                }
            }
            rot = Math.random() * 2 * Math.PI;
            wanderTime = Std.int(Math.random() * (MAX_WANDER_TIME - MIN_WANDER_TIME))
                + MIN_WANDER_TIME;
        }

        moveTick += speed;
    }

    /** Non-negative residue **/
    inline function mod(x:Int, m:Int) {
        return (x % m + m) % m;
    }

    override function render() {
        super.render();

        var rotStep = mod(Math.round(4 * (rot + island.rot) / (2 * Math.PI)), 4);
        var animStep = animSteps[mod(Math.floor(moveTick / 4), 4)];

        body.id = spriteSheet.peons[typeIndex][animDirs[rotStep] * 3 + animStep].id;
    }

    public function isEnemy(e:Entity):Bool {
        switch (type) {
            case MONSTER:
                if (e.isOfType(House))
                    return true;
                return e.isOfType(Peon) && (cast e).type != MONSTER;
            default:
                return e.isOfType(Peon) && (cast e).type == MONSTER;
        }
    }

    function set_job(job:Job):Job {
        if (this.job != null)
            this.job.removeEventListener(JobEvent.CHANGE_CARRIED, onChangeCarried);
        if (job != null)
            job.addEventListener(JobEvent.CHANGE_CARRIED, onChangeCarried);

        return this.job = job;
    }

    function set_hp(hp:Int):Int {
        // TODO: We probably want a full die() function here or in Entity.
        if (hp <= 0)
            alive = false;

        health.getTileAt(1).scaleX = HEALTH_BAR_WIDTH * (hp / maxHp);
        health.alpha = hp == maxHp ? 0 : 1;

        return this.hp = hp;
    }

    function set_type(type:PeonType):PeonType {
        switch (type) {
            case PEON:
                baseSpeed = BASE_SPEED_PEON;
                typeIndex = 0;
            case WARRIOR:
                baseSpeed = BASE_SPEED_PEON;
                typeIndex = 1;
            case MONSTER:
                baseSpeed = BASE_SPEED_MONSTER;
                typeIndex = 3;
                job = new Hunt(island, this, null);
                job.enableBoredom = false;
        }
        return this.type = type;
    }

    function onChangeCarried(event:JobEvent) {
        if (event.carried != null) {
            switch (event.carried) {
                case WOOD:
                    carried.id = spriteSheet.carriedResources[0].id;
                case ROCK:
                    carried.id = spriteSheet.carriedResources[1].id;
                case FOOD:
                    carried.id = spriteSheet.carriedResources[2].id;
            }
            carried.alpha = 1;
            typeIndex = 2;
        } else {
            carried.alpha = 0;
            typeIndex = 0;
        }
    }

    override function fight(e:Entity, allowRetaliation = true) {
        switch (type) {
            case PEON:
                hp -= 4;
                if (allowRetaliation)
                    e.fight(this, false);
                if (job == null && Math.random() < 0.1)
                    job = new Hunt(island, this, e);
            case WARRIOR:
                --hp;
                if (allowRetaliation)
                    e.fight(this, false);
                if (job == null)
                    job = new Hunt(island, this, e);
            case MONSTER:
                --hp;
                if (Math.random() < 0.2) {
                    if (job.isOfType(Hunt))
                        job.target = e;
                    else
                        job = new Hunt(island, this, e);
                }
        }
    }
}
