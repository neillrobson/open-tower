package;

import haxe.ds.IntMap;
import openfl.geom.Point;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import openfl.display.Tileset;

class SpriteSheet {
    public final tileset:Tileset;

    public final trees:Array<Int>;
    public final rocks:Array<Int>;
    public final houses:Array<Array<Int>>;
    public final peons:Array<Array<Int>>;
    public final towerTop:Int;
    public final towerMid:Int;
    public final towerBot:Int;
    public final deleteButton:Int;
    public final carriedResources:Array<Int>;
    public final smoke:Array<Int>;
    public final healthBar:Array<Int>;
    public final farmPlots:Array<Int>;

    private var bitmapCache:IntMap<BitmapData> = new IntMap();

    // public final infoPuffs:Array<Int>;
    // public final helpButton:Int;
    // public final soundButtons:Array<Int>;

    public function new() {
        tileset = new Tileset(Assets.getBitmapData(AssetPaths.sheet__png));

        towerTop = tileset.addRect(new Rectangle(0, 0, 32, 16));
        towerMid = tileset.addRect(new Rectangle(0, 16, 32, 8));
        towerBot = tileset.addRect(new Rectangle(0, 24, 32, 8));

        trees = new Array();
        for (i in 0...16) {
            trees[i] = tileset.addRect(new Rectangle(32 + 8 * i, 0, 8, 16));
        }

        rocks = [];
        for (i in 0...4) {
            rocks[i] = tileset.addRect(new Rectangle(32 + 8 * (12 + i), 16, 8, 8));
        }

        houses = new Array();
        for (i in 0...3) {
            houses[i] = new Array();
            for (j in 0...8) {
                houses[i][j] = tileset.addRect(new Rectangle(160 + i * 16, j * 16, 16, 16));
            }
        }

        peons = new Array();
        for (i in 0...4) {
            peons[i] = new Array();
            for (j in 0...12) {
                peons[i][j] = tileset.addRect(new Rectangle(32 + 8 * j, 16 + 8 * i, 8, 8));
            }
        }

        deleteButton = tileset.addRect(new Rectangle(32 + 16 * 8 + 3 * 16, 0, 16, 16));

        carriedResources = new Array();
        for (i in 0...4) {
            carriedResources[i] = tileset.addRect(new Rectangle(32 + (12 + i) * 8, 4 * 8, 8, 8));
        }

        smoke = new Array();
        for (i in 0...5) {
            smoke[i] = tileset.addRect(new Rectangle(256 - 8, 8 * i, 8, 8));
        }

        healthBar = [];
        for (i in 0...2) {
            healthBar[i] = tileset.addRect(new Rectangle(256 - 32 + i, 0, 1, 1));
        }

        farmPlots = [];
        for (i in 0...8)
            farmPlots[i] = tileset.addRect(new Rectangle(32 + i * 8, 11 * 8, 8, 8));
    }

    public function getBitmapData(id:Int):BitmapData {
        if (bitmapCache.exists(id))
            return bitmapCache.get(id);

        var rect = tileset.getRect(id);
        var bitmapData = new BitmapData(cast rect.width, cast rect.height);
        bitmapData.copyPixels(tileset.bitmapData, rect, new Point());
        bitmapCache.set(id, bitmapData);
        return bitmapData;
    }
}
