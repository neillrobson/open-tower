package;

import Job.Goto;
import Job.Build;
import Resources.Resource;
import Job.Gather;

class House extends Entity {
    static inline final BUILD_ANIMATION_STEPS = 6;
    static inline final BUILD_DURATION = Std.int(BUILD_ANIMATION_STEPS * 1.1 * Main.TICKS_PER_SECOND);

    final type:HouseType;

    var buildTime(default, set) = 0;
    var isBuilt(get, null):Bool;

    public function new(x:Float, y:Float, type:HouseType, island:Island, spriteSheet:SpriteSheet) {
        super(x, y, type.radius, island, spriteSheet);
        this.type = type;
        tile.originX = type.anchorX;
        tile.originY = type.anchorY;
        tile.id = spriteSheet.houses[0][0].id;
    }

    public function build():Bool {
        if (!isBuilt) {
            ++buildTime;
            if (isBuilt) {
                // TODO: Set new population caps, HP, etc.
                return true;
            }
        }
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

        // Find nearby peon(s) to "recruit" for this House's job
        if (!isBuilt) {
            for (_ in 0...2) {
                var peon = getRandomPeon(100, 80);
                if (peon != null) {
                    peon.job = new Build(this);
                }
            }
        } else {
            var peon:Peon = getRandomPeon(50, 50);
            if (peon != null) {
                switch (type) {
                    case HouseType.WOODCUTTER:
                        peon.job = new Gather(Resource.WOOD, this);
                }
            }

            switch (type) {
                case HouseType.GUARDPOST:
                    peon = getRandomPeon(80, 80);
                    if (peon != null && Math.random() < 0.5)
                        peon.job = new Goto(this);
            }
        }
    }

    inline function get_isBuilt():Bool {
        return buildTime >= BUILD_DURATION;
    }

    function set_buildTime(buildTime:Int):Int {
        this.buildTime = buildTime;
        if (isBuilt) {
            tile.id = type.getImage(spriteSheet).id;
        } else {
            tile.id = spriteSheet.houses[0][Math.floor(buildTime * BUILD_ANIMATION_STEPS / BUILD_DURATION)].id;
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
        return buildTime >= BUILD_DURATION && type.acceptResource == r;
    }
}
