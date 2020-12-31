package;

import Job.GotoAndConvert;
import Job.Plant;
import openfl.display.Tile;
import openfl.display.TileContainer;
import Job.Goto;
import Job.Build;
import Resources.Resource;
import Job.Gather;

using Std;

class House extends Entity {
    static inline final BUILD_ANIMATION_STEPS = 6;
    static inline final BUILD_DURATION = Std.int(BUILD_ANIMATION_STEPS * 1.1 * Main.TICKS_PER_SECOND);

    static inline final HEALTH_BAR_WIDTH = 8;

    static inline final POPULATION_PER_RESIDENCE = 10;
    static inline final WARRIORS_PER_BARRACKS = 5;

    final type:HouseType;

    var houseSprite = new Tile();
    var puffs:Array<Puff> = [];
    var health = new TileContainer();

    var buildTime(default, set) = 0;
    var isBuilt(get, null):Bool;

    var maxHp = 256;
    var hp(default, set) = 256;

    public function new(x:Float, y:Float, type:HouseType) {
        super(x, y, type.radius);
        this.type = type;

        sprite.originX = type.anchorX;
        sprite.originY = type.anchorY;

        sprite.addTile(houseSprite);

        sprite.addTile(health);
        health.x = 4;
        health.y = -2;
        health.alpha = 0;
        health.addTile(new Tile(0, 0, 0, HEALTH_BAR_WIDTH));
        health.addTile(new Tile(0, 0, 0, HEALTH_BAR_WIDTH));
    }

    override function init(island:Island, spriteSheet:SpriteSheet) {
        super.init(island, spriteSheet);

        houseSprite.id = spriteSheet.houses[0][0];
        health.getTileAt(0).id = spriteSheet.healthBar[1];
        health.getTileAt(1).id = spriteSheet.healthBar[0];
    }

    public function build():Bool {
        if (!isBuilt) {
            ++buildTime;

            if (isBuilt) {
                switch (type) {
                    case HouseType.RESIDENCE:
                        island.populationCap += POPULATION_PER_RESIDENCE;
                    case HouseType.BARRACKS:
                        island.warriorPopulationCap += WARRIORS_PER_BARRACKS;
                    default:
                }
            }
        }
        return isBuilt;
    }

    public function complete() {
        buildTime = BUILD_DURATION;
    }

    public function sell() {
        island.resources.add(WOOD, Std.int(type.wood * 3 * hp / (4 * maxHp)));
        island.resources.add(ROCK, Std.int(type.rock * 3 * hp / (4 * maxHp)));
        die();
    }

    override public function fight(e:Entity, allowRetaliation = true) {
        --hp;
    }

    override public function update() {
        super.update();

        for (p in puffs) {
            p.update();
            if (!p.alive()) {
                unpuff(p);
            }
        }

        // Find nearby peon(s) to "recruit" for this House's job
        if (!isBuilt) {
            for (_ in 0...2) {
                var peon = getRandomPeon(100, 80);
                if (peon != null) {
                    peon.job = new Build(island, peon, this);
                }
            }
        } else {
            if (hp < maxHp && Math.random() < 0.25)
                ++hp;

            var peon:Peon = getRandomPeon(50, 50);
            if (peon != null) {
                switch (type) {
                    case HouseType.WOODCUTTER:
                        peon.job = new Gather(island, peon, WOOD, this);
                    case HouseType.MASON:
                        peon.job = new Gather(island, peon, ROCK, this);
                    case HouseType.WINDMILL:
                        peon.job = new Gather(island, peon, FOOD, this);
                    // Only plant stuff if there is a clearing nearby.
                    // Peons don't count as taking up "planting space."
                    case HouseType.PLANTER:
                        if (getRandomTarget(6, 40, e -> !e.isOfType(Peon)) == null)
                            peon.job = new Plant(island, peon, this, TREE);
                    case HouseType.FARM:
                        if (getRandomTarget(6, 40, e -> !e.isOfType(Peon)) == null)
                            peon.job = new Plant(island, peon, this, FOOD);
                }
            }

            switch (type) {
                case HouseType.GUARDPOST:
                    peon = getRandomPeon(80, 80);
                    if (peon != null && Math.random() < 0.5)
                        peon.job = new Goto(island, peon, this);
                case HouseType.BARRACKS:
                    if (island.canMakeWarrior) {
                        peon = getRandomPeon(80, 80);
                        if (peon != null)
                            peon.job = new GotoAndConvert(island, peon, this);
                    }
                case HouseType.RESIDENCE:
                    if (island.canMakePeon && Math.random() < 0.05) {
                        var xt = x + (Math.random() * 2 - 1) * 9;
                        var yt = y + (Math.random() * 2 - 1) * 9;

                        var peon = new Peon(xt, yt, PEON);
                        if (island.isFree(peon.x, peon.y, peon.r)) {
                            puff();
                            island.resources.food -= Island.FOOD_PER_PEON;
                            island.addEntity(peon);
                        }
                    }
            }
        }
    }

    override function die() {
        switch (type) {
            case HouseType.RESIDENCE:
                island.populationCap -= POPULATION_PER_RESIDENCE;
            case HouseType.BARRACKS:
                island.warriorPopulationCap -= WARRIORS_PER_BARRACKS;
            default:
        }
        super.die();
    }

    inline function get_isBuilt():Bool {
        return buildTime >= BUILD_DURATION;
    }

    function set_buildTime(buildTime:Int):Int {
        this.buildTime = buildTime;
        if (isBuilt) {
            houseSprite.id = type.getImage(spriteSheet);
        } else {
            houseSprite.id = spriteSheet.houses[0][Math.floor(buildTime * BUILD_ANIMATION_STEPS / BUILD_DURATION)];
        }
        return buildTime;
    }

    /**
        Finds an unoccupied (job == null) peon within the given search parameters.
    **/
    function getRandomPeon(searchRadius:Float, centerPointRadius:Float):Peon {
        var entity = getRandomTarget(searchRadius, centerPointRadius, e -> {
            if (!Std.isOfType(e, Peon))
                return false;
            var p:Peon = cast e;
            return p.type == PEON && p.job == null;
        });
        return cast entity;
    }

    override function acceptsResource(r:Resource):Bool {
        return buildTime >= BUILD_DURATION && type.acceptResource == r;
    }

    override function submitResource(r:Resource):Bool {
        if (buildTime >= BUILD_DURATION && type.acceptResource == r) {
            puff();
            return true;
        }
        return false;
    }

    public function puff() {
        var p = new Puff(11, 3, spriteSheet);
        puffs.push(p);
        sprite.addTile(p.tile);
    }

    function unpuff(p:Puff) {
        puffs.remove(p);
        sprite.removeTile(p.tile);
    }

    function set_hp(hp:Int):Int {
        if (hp <= 0)
            die();

        health.getTileAt(1).scaleX = HEALTH_BAR_WIDTH * (hp / maxHp);
        health.alpha = hp == maxHp ? 0 : 1;

        return this.hp = hp;
    }
}
