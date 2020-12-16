package;

import Resources.Resource;
import Job.Gather;

class House extends Entity {
    final type:HouseType;

    public function new(x:Float, y:Float, type:HouseType) {
        super(x, y, type.radius);
        this.type = type;
    }

    public override function init(island:Island, spriteSheet:SpriteSheet) {
        super.init(island, spriteSheet);
        tile.originX = type.anchorX;
        tile.originY = type.anchorY;
        tile.id = type.getImage(spriteSheet).id;
    }

    public function sell() {
        island.resources.add(WOOD, Std.int(type.wood * 3 / 4));
        island.resources.add(ROCK, Std.int(type.rock * 3 / 4));
        alive = false;
    }

    override public function update() {
        super.update();

        // Find a nearby peon to "recruit" for this House's job
        var peon:Peon = getRandomPeon(50, 50);
        if (peon != null) {
            if (type == HouseType.WOODCUTTER) {
                peon.job = new Gather(Resource.WOOD, this);
            }
        }
    }

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
        return type.acceptResource == r;
    }

    override function submitResource(r:Resource):Bool {
        return type.acceptResource == r;
    }
}
