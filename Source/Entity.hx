package;

import openfl.geom.Point;
import openfl.geom.Matrix;
import openfl.display.Tile;

class Entity {
    public var x:Float;
    public var y:Float;
    public var r:Float;

    public var xr:Float;
    public var yr:Float;

    public var spriteSheet:SpriteSheet;
    public var tile = new Tile();

    public function new(x:Float, y:Float, r:Float) {
        this.x = x;
        this.y = y;
        this.r = r;
    }

    public function init(spriteSheet:SpriteSheet) {
        this.spriteSheet = spriteSheet;
    }

    public function updatePos(coordinateTransform:Matrix) {
        var newPoint = coordinateTransform.transformPoint(new Point(x, y));
        xr = newPoint.x;
        yr = newPoint.y;
    }

    public function update() {}

    public function render() {}

    public function collidesWith(e:Entity) {
        return collides(e.x, e.y, e.r);
    }

    public function collides(ex:Float, ey:Float, er:Float) {
        var xd = x - ex;
        var yd = y - ey;
        return (xd * xd + yd * yd) < (r * r + er * er);
    }
}
