package;

import openfl.geom.Point;
import openfl.geom.Matrix;
import openfl.display.Tile;

class Tree {
    var x:Float;
    var y:Float;

    public var tile:Tile;

    public function new(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }

    /**
        We would probably want to keep the sprite sheet around to change the
        tree's image based on its growth state.
    **/
    public function init(spriteSheet:SpriteSheet) {
        tile = new Tile(spriteSheet.trees[0]);
    }

    public function updatePos(coordinateTransform:Matrix) {
        var newPoint = coordinateTransform.transformPoint(new Point(x, y));
        tile.x = newPoint.x - 4;
        tile.y = newPoint.y - 16;
    }
}
