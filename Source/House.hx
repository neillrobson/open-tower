package;

import Job.Build;
import Resources.Resource;
import Job.Gather;

class House extends Entity {
    final type:HouseType;

    var buildTime(default, set) = 0;
    var buildDuration = 32 * 6;
    var isBuilt(get, null):Bool;

    public function new(x:Float, y:Float, type:HouseType) {
        super(x, y, type.radius);
        this.type = type;
    }

    public override function init(island:Island, spriteSheet:SpriteSheet) {
        super.init(island, spriteSheet);
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
        buildTime = buildDuration;
    }

    public function sell() {
        island.resources.add(WOOD, Std.int(type.wood * 3 / 4));
        island.resources.add(ROCK, Std.int(type.rock * 3 / 4));
        alive = false;
    }

    override public function update() {
        super.update();

        if (!isBuilt) {
            for (_ in 0...2) {
                var peon = getRandomPeon(100, 80);
                if (peon != null) {
                    peon.job = new Build(this);
                }
            }
        } else {
            // Find a nearby peon to "recruit" for this House's job
            var peon:Peon = getRandomPeon(50, 50);
            if (peon != null) {
                if (type == HouseType.WOODCUTTER) {
                    peon.job = new Gather(Resource.WOOD, this);
                }
            }
        }
    }

    inline function get_isBuilt():Bool {
        return buildTime >= buildDuration;
    }

    function set_buildTime(buildTime:Int):Int {
        this.buildTime = buildTime;
        if (inited) {
            if (isBuilt) {
                tile.id = type.getImage(spriteSheet).id;
            } else {
                tile.id = spriteSheet.houses[0][Math.floor(buildTime * 6 / buildDuration)].id;
            }
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
        return buildTime >= buildDuration && type.acceptResource == r;
    }

    override function submitResource(r:Resource):Bool {
        return buildTime >= buildDuration && type.acceptResource == r;
    }
}
