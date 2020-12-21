package;

import openfl.display.Tile;
import openfl.display.TileContainer;

class Tower extends Entity {
    var container = new TileContainer();
    var towerMids:Array<Tile> = [];
    var towerTopWall:Tile;
    var towerTop:Tile;

    public var height(default, set):Int;

    override public function new(x:Float, y:Float, island:Island, spriteSheet:SpriteSheet) {
        super(x, y, 16, island, spriteSheet);
        tile = container;

        tile.originX = 16;

        var towerBot = new Tile(spriteSheet.towerBot.id);
        container.addTile(towerBot);
        towerTopWall = new Tile(spriteSheet.towerMid.id);
        container.addTile(towerTopWall);
        towerTop = new Tile(spriteSheet.towerTop.id);
        container.addTile(towerTop);

        height = 80;
    }

    override function render() {
        super.render();
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
                container.removeTile(towerMids[i]);
            }
        } else if (numMids > oldNumMids) {
            for (i in oldNumMids...numMids)
                container.addTileAt(towerMids[i], container.numTiles - 2);
        }

        towerTopWall.y = -height - 1;
        towerTop.y = -height - 8;
        container.setTileIndex(towerTopWall, container.numTiles - 2);
        container.setTileIndex(towerTop, container.numTiles - 1);

        this.height = height;
        return height;
    }

    function addMid(i:Int) {
        var towerMid = new Tile(spriteSheet.towerMid.id, 0, -8 * (i + 1));
        towerMids.push(towerMid);
        container.addTile(towerMid);
    }
}