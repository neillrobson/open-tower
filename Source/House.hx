package;

import openfl.display.Tile;
import openfl.display.TileContainer;
import Job.Goto;
import Job.Build;
import Resources.Resource;
import Job.Gather;

class House extends Entity {
    static inline final BUILD_ANIMATION_STEPS = 6;
    static inline final BUILD_DURATION = Std.int(BUILD_ANIMATION_STEPS * 1.1 * Main.TICKS_PER_SECOND);

    final type:HouseType;

    var container = new TileContainer();
    var houseSprite = new Tile();
    var puffs:Array<Puff> = [];

    var buildTime(default, set) = 0;
    var isBuilt(get, null):Bool;

    public function new(x:Float, y:Float, type:HouseType, island:Island, spriteSheet:SpriteSheet) {
        super(x, y, type.radius, island, spriteSheet);
        this.type = type;

        tile = container;
        tile.originX = type.anchorX;
        tile.originY = type.anchorY;

        houseSprite.id = spriteSheet.houses[0][0].id;
        container.addTile(houseSprite);
    }

    public function build():Bool {
        if (!isBuilt)
            ++buildTime;
        return isBuilt;
    }

    public function complete() {
        buildTime = BUILD_DURATION;
    }

    public function sell() {
        island.resources.add(WOOD, Std.int(type.wood * 3 / 4));
        island.resources.add(ROCK, Std.int(type.rock * 3 / 4));
        alive = false;
    }

    override public function update() {
        super.update();

        for (p in puffs) {
            p.update();
            if (!p.alive) {
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
            var peon:Peon = getRandomPeon(50, 50);
            if (peon != null) {
                switch (type) {
                    case HouseType.WOODCUTTER:
                        peon.job = new Gather(island, peon, WOOD, this);
                    case HouseType.MASON:
                        peon.job = new Gather(island, peon, ROCK, this);
                }
            }

            switch (type) {
                case HouseType.GUARDPOST:
                    peon = getRandomPeon(80, 80);
                    if (peon != null && Math.random() < 0.5)
                        peon.job = new Goto(island, peon, this);
            }
        }
    }

    override function render() {
        super.render();
        for (p in puffs)
            p.render();
    }

    inline function get_isBuilt():Bool {
        return buildTime >= BUILD_DURATION;
    }

    function set_buildTime(buildTime:Int):Int {
        this.buildTime = buildTime;
        if (isBuilt) {
            houseSprite.id = type.getImage(spriteSheet).id;
        } else {
            houseSprite.id = spriteSheet.houses[0][Math.floor(buildTime * BUILD_ANIMATION_STEPS / BUILD_DURATION)].id;
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
            return p.job == null;
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

    function puff() {
        var p = new Puff(8, 6, island, spriteSheet);
        puffs.push(p);
        container.addTile(p.tile);
    }

    function unpuff(p:Puff) {
        puffs.remove(p);
        container.removeTile(p.tile);
    }
}
