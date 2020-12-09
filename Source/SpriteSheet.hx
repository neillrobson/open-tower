package;

import openfl.geom.Point;
import openfl.display.BitmapData;
import haxe.ds.IntMap;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import openfl.display.Tileset;

class SpriteSheet {
    public final tileset:Tileset;

    public final trees:Array<Int>;
    public final houses:Array<Array<Int>>;
    public final towerTop:Int;
    public final towerMid:Int;
    public final towerBot:Int;
    public final deleteButton:Int;

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

        towerTop = tileset.addRect(new Rectangle(0, 0, 32, 16));
        towerMid = tileset.addRect(new Rectangle(0, 16, 32, 8));
        towerBot = tileset.addRect(new Rectangle(0, 24, 32, 8));

        trees = new Array<Int>();
        for (i in 0...16) {
            trees[i] = tileset.addRect(new Rectangle(32 + 8 * i, 0, 8, 16));
        }

        houses = new Array();
        for (i in 0...3) {
            houses[i] = new Array();
            for (j in 0...8) {
                houses[i][j] = tileset.addRect(new Rectangle(160 + i * 16, j * 16, 16, 16));
            }
        }

        deleteButton = tileset.addRect(new Rectangle(32 + 16 * 8 + 3 * 16, 0, 16, 16));
    }

    public function getBitmapData(i:Int):BitmapData {
        if (bitmapDatas.exists(i))
            return bitmapDatas.get(i);
        var rect = tileset.getRect(i);
        var bitmapData = new BitmapData(cast rect.width, cast rect.height);
        bitmapData.copyPixels(tileset.bitmapData, rect, new Point());
        bitmapDatas.set(i, bitmapData);
        return bitmapData;
    }
}
