package;

import Peon.PeonType;
import Resources.Resource;
import openfl.display.Tile;

class Tower extends Entity {
    static inline final STANIMA_PER_LEVEL = 4096;

    var towerMids:Array<Tile> = [];
    var towerTopWall:Tile;
    var towerTop:Tile;

    public var height(default, set):Int;

    var stanima = STANIMA_PER_LEVEL;

    override public function new(x:Float, y:Float, island:Island, spriteSheet:SpriteSheet) {
        super(x, y, 16, island, spriteSheet);

        sprite.originX = 16;

        var towerBot = new Tile(spriteSheet.towerBot.id);
        sprite.addTile(towerBot);
        towerTopWall = new Tile(spriteSheet.towerMid.id);
        sprite.addTile(towerTopWall);
        towerTop = new Tile(spriteSheet.towerTop.id);
        sprite.addTile(towerTop);

        height = 80;
    }

    override function update() {
        super.update();

        // TODO: Add minimum monster count
        // if (Math.random() < 0.01) {
        //     var xp = x + (Math.random() * 2 - 1) * (r + 5);
        //     var yp = y + (Math.random() * 2 - 1) * (r + 5);
        //     var monster = new Peon(xp, yp, PeonType.MONSTER, island, spriteSheet);
        //     if (island.isFree(monster.x, monster.y, monster.r)) {
        //         island.addEntity(monster);
        //     }
        // }
    }

    override function givesResource(r:Resource):Bool {
        return r == ROCK;
    }

    override function gatherResource(r:Resource):Bool {
        stanima -= 64;
        if (stanima <= 0) {
            stanima += STANIMA_PER_LEVEL;
            if (--height <= 4) {
                alive = false;
            }
            return true;
        }
        return false;
    }

    function set_height(height:Int) {
        var numMids = Std.int(height / 8);
        var oldNumMids = Std.int(this.height / 8);

        if (numMids > towerMids.length) {
            for (i in towerMids.length...numMids)
                addMid(i);
        }

        if (numMids < oldNumMids) {
            for (i in numMids...oldNumMids) {
                sprite.removeTile(towerMids[i]);
            }
        } else if (numMids > oldNumMids) {
            for (i in oldNumMids...numMids)
                sprite.addTileAt(towerMids[i], sprite.numTiles - 2);
        }

        towerTopWall.y = -height - 1;
        towerTop.y = -height - 8;
        sprite.setTileIndex(towerTopWall, sprite.numTiles - 2);
        sprite.setTileIndex(towerTop, sprite.numTiles - 1);

        this.height = height;
        return height;
    }

    function addMid(i:Int) {
        var towerMid = new Tile(spriteSheet.towerMid.id, 0, -8 * (i + 1));
        towerMids.push(towerMid);
        sprite.addTile(towerMid);
    }
}
