package;

import event.JobEvent;
import openfl.display.Tile;

class Peon extends Entity {
    static inline final BASE_SPEED = 10 * Main.SECONDS_PER_TICK;
    static inline final MAX_WANDER_TIME = Std.int(1.5 * Main.TICKS_PER_SECOND);
    static inline final MIN_WANDER_TIME = Std.int(0.5 * Main.TICKS_PER_SECOND);

    static final animSteps = [0, 1, 0, 2];
    static final animDirs = [2, 0, 3, 1];

    var body = new Tile();
    var carried = new Tile();

    public var job(default, set):Job;

    var type:Int;

    public var rot:Float;

    var moveTick:Float;
    var wanderTime:Int = 0;

    override public function new(x:Float, y:Float, type:Int, island:Island,
            spriteSheet:SpriteSheet) {
        super(x, y, 1, island, spriteSheet);
        this.type = type;

        sprite.addTile(body);
        sprite.addTile(carried);
        carried.y = -3;
        carried.alpha = 0;

        rot = Math.random() * 2 * Math.PI;
        moveTick = Math.random() * 12;

        sprite.originX = 4;
        sprite.originY = 8;
    }

    override function update() {
        super.update();

        if (job != null)
            job.update();

        // Calculate speed and direction.
        // If arrived at job, don't move; instead, do a job.arrived() tick
        var speed = BASE_SPEED;
        if (wanderTime == 0 && job != null && job.hasTarget()) {
            var rd = job.target.r + r;
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

        body.id = spriteSheet.peons[type][animDirs[rotStep] * 3 + animStep].id;
    }

    function set_job(job:Job):Job {
        if (this.job != null)
            this.job.removeEventListener(JobEvent.CHANGE_CARRIED, onChangeCarried);
        if (job != null)
            job.addEventListener(JobEvent.CHANGE_CARRIED, onChangeCarried);

        return this.job = job;
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
        } else {
            carried.alpha = 0;
        }
    }
}
