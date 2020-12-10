package;

class House extends Entity {
    final type:HouseType;

    public function new(x:Float, y:Float, type:HouseType) {
        super(x, y, type.radius);

        this.type = type;
        this.anchorX = type.anchorX;
        this.anchorY = type.anchorY;
    }

    public override function init(spriteSheet:SpriteSheet) {
        super.init(spriteSheet);
        tile.id = type.getImage(spriteSheet).id;
    }
}
