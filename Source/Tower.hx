package;

import Resources.Resource;
import openfl.display.Tile;

class Tower extends Entity {
    static inline final STANIMA_PER_LEVEL = 4096;

    var towerBot = new Tile();
    var towerMids:Array<Tile> = [];
    var towerTopWall = new Tile();
    var towerTop = new Tile();

    var towerMidSpriteId = 0;

    public var height(default, set):Int;

    var stanima = STANIMA_PER_LEVEL;
    var minMonsters = 3;

    override public function new(x:Float, y:Float) {
        super(x, y, 16);

        sprite.originX = 16;

        sprite.addTile(towerBot);
        sprite.addTile(towerTopWall);
        sprite.addTile(towerTop);

        height = 80;
    }

    override function init(island:Island) {
        super.init(island);

        towerBot.id = Global.spriteSheet.towerBot;
        towerTopWall.id = Global.spriteSheet.towerMid;
        towerTop.id = Global.spriteSheet.towerTop;

        towerMidSpriteId = Global.spriteSheet.towerMid;

        for (mid in towerMids)
            mid.id = towerMidSpriteId;
    }

    override function update() {
        super.update();

        if (Math.random() < 0.01 && island.monsterPopulation < minMonsters) {
            spawnMonster();
        }
    }

    function spawnMonster():Bool {
        var xp = x + (Math.random() * 2 - 1) * (r + 5);
        var yp = y + (Math.random() * 2 - 1) * (r + 5);
        var monster = new Peon(xp, yp, MONSTER);
        if (island.isFree(monster.x, monster.y, monster.r)) {
            island.addEntity(monster);
            return true;
        }
        return false;
    }

    override function givesResource(r:Resource):Bool {
        return r == ROCK;
    }

    override function gatherResource(r:Resource):Bool {
        stanima -= 64;
        if (stanima <= 0) {
            stanima += STANIMA_PER_LEVEL;

            while (!spawnMonster()) {}

            if (height % 20 == 0)
                ++minMonsters;

            if (--height <= 4)
                die();

            return true;
        }
        return false;
    }

    override function die() {
        super.die();
        island.won = true;
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
        var towerMid = new Tile(towerMidSpriteId, 0, -8 * (i + 1));
        towerMids.push(towerMid);
        sprite.addTile(towerMid);
    }
}
