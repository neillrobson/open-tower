package;

import Entity.TargetFilter;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
    The island coordinates run from -128 to 127 in the X and Y directions. The
    axes are "left-handed," meaning that the positive Y axis descends down the
    screen and (more importantly) positive angles will rotate objects clockwise.
**/
class Island {
    public static inline final FOOD_PER_PEON = 5;
    public static inline final WOOD_PER_WARRIOR = 5;

    private static final xStart = 40;
    private static final yStart = -60;

    private var game:Game;
    private var image:BitmapData;
    private var tower:Tower;

    private var random:Random = new Random();

    public var won = false;

    public var rot:Float;

    public var entities:Array<Entity> = new Array();
    public var resources:Resources = new Resources();

    public var population:Int = 0;
    public var populationCap:Int = 10;
    public var warriorPopulation:Int = 0;
    public var warriorPopulationCap:Int = 0;
    public var monsterPopulation:Int = 0;

    public var canMakePeon(get, null):Bool;
    public var canMakeWarrior(get, null):Bool;

    public function new(game:Game, image:BitmapData) {
        this.game = game;
        this.image = image;
        init();
    }

    public function init() {
        var start = new House(xStart, yStart, HouseType.GUARDPOST);
        addEntity(start);
        start.complete();

        tower = new Tower(-xStart, -yStart);
        addEntity(tower);

        var peonCount = 0;
        while (peonCount < 10) {
            var x = xStart + Math.random() * 32 - 16;
            var y = yStart + Math.random() * 32 - 16;
            var p = new Peon(x, y, PEON);

            if (isFree(p.x, p.y, p.r)) {
                addEntity(p);
                ++peonCount;
            }
        }

        for (_ in 0...7) {
            var x = Math.random() * 256 - 128;
            var y = Math.random() * 256 - 128;
            if (x > 0 && y < 0) {
                if (Math.random() < 0.5)
                    x = -x;
                else
                    y = -y;
            }
            addRocks(x, y);
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

        #if debug
        game.addEventListener(MouseEvent.RIGHT_CLICK, event -> {
            while (!tower.gatherResource(ROCK))
                continue;
        });
        #end
    }

    public function update() {
        for (e in entities) {
            e.update();
            if (!e.alive) {
                removeEntity(e);
            }
        }

        if (won) {
            won = false;
            game.win();
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

    function addRocks(x0:Float, y0:Float) {
        for (_ in 0...100) {
            var x = x0 + random.floatNormal() * 6;
            var y = y0 + random.floatNormal() * 6;
            var rock = new Rock(x, y);
            if (isFree(rock.x, rock.y, rock.r)) {
                addEntity(rock);
            }
        }
    }

    public function addEntity(e:Entity) {
        game.entityDisplayLayer.addTile(e.sprite);
        e.init(this);
        entities.push(e);
    }

    public function removeEntity(e:Entity) {
        game.entityDisplayLayer.removeTile(e.sprite);
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
            Assets.getSound(AssetPaths.plant__wav).play();
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

    public function get_canMakePeon():Bool {
        return population < populationCap && resources.food >= FOOD_PER_PEON;
    }

    public function get_canMakeWarrior():Bool {
        return warriorPopulation < warriorPopulationCap && resources.wood >= WOOD_PER_WARRIOR;
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
