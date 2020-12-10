package;

class House extends Entity {
    final type:HouseType;

    public function new(x:Float, y:Float, type:HouseType) {
        this.type = type;
        super(x, y, type.radius);
    }

    public override function render() {
        tile.x = xr - 8;
        tile.y = yr - 12;
        tile.id = type.getImage(spriteSheet).id;
    }
}
