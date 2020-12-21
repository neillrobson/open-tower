package;

import Resources.Resource;
import openfl.geom.Point;
import openfl.geom.Matrix;
import openfl.display.Tile;

typedef TargetFilter = Entity->Bool;

class Entity {
    public var x:Float;
    public var y:Float;
    public var r:Float;

    final spriteSheet:SpriteSheet;
    final island:Island;

    public var tile = new Tile();

    public var alive = true;

    public function new(x:Float, y:Float, r:Float, island:Island, spriteSheet:SpriteSheet) {
        this.x = x;
        this.y = y;
        this.r = r;
        this.island = island;
        this.spriteSheet = spriteSheet;
    }

    public function updatePos(coordinateTransform:Matrix) {
        var newPoint = coordinateTransform.transformPoint(new Point(x, y));
        tile.x = newPoint.x;
        tile.y = newPoint.y;
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

    /**
        @param searchRadius How large the circle is within which entities are considered.
        @param centerPointRadius How far away from this entity's origin point can the center of the search circle be.
    **/
    public function getRandomTarget(searchRadius:Float, centerPointRadius:Float,
            filter:TargetFilter):Entity {
        var xt = x + (Math.random() * 2 - 1) * centerPointRadius;
        var yt = y + (Math.random() * 2 - 1) * centerPointRadius;
        return island.getEntityAt(xt, yt, searchRadius, filter);
    }

    /**
        Returns the SQUARED distance between two entities. Only to be used for
        comparison purposes.
    **/
    public function distance(e:Entity) {
        var xd = x - e.x;
        var yd = y - e.y;
        return xd * xd + yd * yd;
    }

    public function givesResource(r:Resource):Bool {
        return false;
    }

    public function acceptsResource(r:Resource):Bool {
        return false;
    }

    public function gatherResource(r:Resource):Bool {
        return false;
    }

    public function submitResource(r:Resource):Bool {
        return false;
    }
}
