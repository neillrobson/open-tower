package;

class Tree extends Entity {
    public function new(x:Float, y:Float) {
        super(x, y, 4);
    }

    public override function render() {
        tile.x = xr - 4;
        tile.y = yr - 16;
        tile.id = spriteSheet.trees[0];
    }
}
