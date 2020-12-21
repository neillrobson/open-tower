package;

import Entity.TargetFilter;
import openfl.geom.Point;
import openfl.display.BitmapData;

/**
    The island coordinates run from -128 to 127 in the X and Y directions. The
    axes are "left-handed," meaning that the positive Y axis descends down the
    screen and (more importantly) positive angles will rotate objects clockwise.
**/
class Island {
    private static final xStart = 40;
    private static final yStart = -60;

    private var game:Game;
    private var image:BitmapData;

    private var random:Random = new Random();

    public var rot:Float;

    public var entities:Array<Entity> = new Array();
    public var resources:Resources = new Resources();

    public function new(game:Game, image:BitmapData) {
        this.game = game;
        this.image = image;
        init();
    }

    public function init() {
        var start = new House(xStart, yStart, HouseType.GUARDPOST);
        addEntity(start);
        start.complete();

        var peonCount = 0;
        while (peonCount < 10) {
            var x = xStart + Math.random() * 32 - 16;
            var y = yStart + Math.random() * 32 - 16;
            var p = new Peon(x, y, 0);

            if (isFree(p.x, p.y, p.r)) {
                addEntity(p);
                ++peonCount;
            }
        }

        for (_ in 0...20) {
            var x = Math.random() * 256 - 128;
            var y = Math.random() * 256 - 128;
            if (x > 0 && y < 0) {
                if (Math.random() < 0.5)
                    x = -x;
                else
                    y = -y;
            }
            addForest(x, y);
        }
    }

    public function update() {
        for (e in entities) {
            e.update();
            if (!e.alive) {
                removeEntity(e);
            }
        }
    }

    /**
        @param rot The rotation of the island view in radians.
    **/
    public function render(rot:Float) {
        this.rot = rot;

        for (e in entities)
            e.render();
    }

    function addForest(x0:Float, y0:Float) {
        for (_ in 0...200) {
            var x = x0 + random.floatNormal() * 12;
            var y = y0 + random.floatNormal() * 12;
            var tree = new Tree(x, y, Math.floor(Math.random() * 16 * Tree.GROW_SPEED));
            if (isFree(tree.x, tree.y, tree.r)) {
                addEntity(tree);
            }
        }
    }

    function addEntity(e:Entity) {
        e.init(this, game.spriteSheet);
        game.entityDisplayLayer.addTile(e.tile);
        entities.push(e);
    }

    function removeEntity(e:Entity) {
        game.entityDisplayLayer.removeTile(e.tile);
        entities.remove(e);
    }

    public function getEntityAt(x:Float, y:Float, r:Float, accept:TargetFilter,
            exception:Entity = null):Entity {
        var minDist = Math.POSITIVE_INFINITY;
        var minDistEntity:Entity = null;

        for (e in entities) {
            if (e == exception)
                continue;
            if (accept != null && !accept(e))
                continue;

            if (e.collides(x, y, r)) {
                var dist = Math.pow(e.x - x, 2) + Math.pow(e.y - y, 2);
                if (dist < minDist) {
                    minDist = dist;
                    minDistEntity = e;
                }
            }
        }

        return minDistEntity;
    }

    public function getEntityAtMouse(xm:Float, ym:Float, accept:TargetFilter):Entity {
        var gameCoord = game.coordinateTransform.clone().invert().transformPoint(new Point(xm, ym));
        return getEntityAt(gameCoord.x, gameCoord.y, 8, accept, null);
    }

    public function canPlaceHouse(xm:Float, ym:Float, type:HouseType) {
        if (!resources.canAfford(type))
            return false;
        var gameCoord = game.coordinateTransform.clone().invert().transformPoint(new Point(xm, ym));
        var house = new House(gameCoord.x, gameCoord.y, type);
        return isFree(house.x, house.y, house.r);
    }

    public function placeHouse(xm:Float, ym:Float, type:HouseType) {
        if (!resources.canAfford(type))
            return;
        var gameCoord = game.coordinateTransform.clone().invert().transformPoint(new Point(xm, ym));
        var house = new House(gameCoord.x, gameCoord.y, type);

        if (isFree(house.x, house.y, house.r)) {
            addEntity(house);
            resources.charge(type);
        }
    }

    public function isFree(x:Float, y:Float, r:Float, except:Entity = null):Bool {
        if (!isOnGround(x, y))
            return false;
        for (e in entities) {
            if (e != except && e.collides(x, y, r))
                return false;
        }
        return true;
    }

    function isOnGround(x:Float, y:Float):Bool {
        var xPixel = Math.round(x + 128);
        var yPixel = Math.round(y + 128);
        if (xPixel < 0 || yPixel < 0 || xPixel >= 256 || yPixel >= 256) {
            return false;
        }
        return image.getPixel32(xPixel, yPixel) >>> 24 > 128;
    }
}
