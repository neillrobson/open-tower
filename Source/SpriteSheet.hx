package;

import openfl.geom.Point;
import openfl.display.BitmapData;
import haxe.ds.IntMap;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import openfl.display.Tileset;

typedef TileData = {id:Int, bitmapData:BitmapData};

class SpriteSheet {
    public final tileset:Tileset;

    public final trees:Array<TileData>;
    public final houses:Array<Array<TileData>>;
    public final towerTop:TileData;
    public final towerMid:TileData;
    public final towerBot:TileData;
    public final deleteButton:TileData;

    private var bitmapDatas:IntMap<BitmapData> = new IntMap();

    // public final farmPlots:Array<Int>;
    // public final rocks:Array<Int>;
    // public final carriedResources:Array<Int>;
    // public final peons:Array<Array<Int>>;
    // public final smoke:Array<Int>;
    // public final infoPuffs:Array<Int>;
    // public final helpButton:Int;
    // public final soundButtons:Array<Int>;

    public function new() {
        tileset = new Tileset(Assets.getBitmapData('assets/sheet.png'));

        towerTop = makeTileData(new Rectangle(0, 0, 32, 16));
        towerMid = makeTileData(new Rectangle(0, 16, 32, 8));
        towerBot = makeTileData(new Rectangle(0, 24, 32, 8));

        trees = new Array();
        for (i in 0...16) {
            trees[i] = makeTileData(new Rectangle(32 + 8 * i, 0, 8, 16));
        }

        houses = new Array();
        for (i in 0...3) {
            houses[i] = new Array();
            for (j in 0...8) {
                houses[i][j] = makeTileData(new Rectangle(160 + i * 16, j * 16, 16, 16));
            }
        }

        deleteButton = makeTileData(new Rectangle(32 + 16 * 8 + 3 * 16, 0, 16, 16));
    }

    private function makeTileData(rect:Rectangle):TileData {
        var id = tileset.addRect(rect);
        var bitmapData = new BitmapData(cast rect.width, cast rect.height);
        bitmapData.copyPixels(tileset.bitmapData, rect, new Point());
        return {
            id: id,
            bitmapData: bitmapData
        };
    }
}
