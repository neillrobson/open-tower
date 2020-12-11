package;

class House extends Entity {
    final type:HouseType;

    public function new(x:Float, y:Float, type:HouseType) {
        super(x, y, type.radius);

        this.type = type;
        this.anchorX = type.anchorX;
        this.anchorY = type.anchorY;
    }

    public override function init(island:Island, spriteSheet:SpriteSheet) {
        super.init(island, spriteSheet);
        tile.id = type.getImage(spriteSheet).id;
    }

    public function sell() {
        island.resources.add(WOOD, Std.int(type.wood * 3 / 4));
        island.resources.add(ROCK, Std.int(type.rock * 3 / 4));
        alive = false;
    }
}
