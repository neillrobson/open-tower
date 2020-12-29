package;

import openfl.geom.Point;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import openfl.display.Tileset;

typedef TileData = {id:Int, bitmapData:BitmapData};

class SpriteSheet {
    public final tileset:Tileset;

    public final trees:Array<TileData>;
    public final rocks:Array<TileData>;
    public final houses:Array<Array<TileData>>;
    public final peons:Array<Array<TileData>>;
    public final towerTop:TileData;
    public final towerMid:TileData;
    public final towerBot:TileData;
    public final deleteButton:TileData;
    public final carriedResources:Array<TileData>;
    public final smoke:Array<TileData>;
    public final healthBar:Array<TileData>;

    // public final farmPlots:Array<TileData>;
    // public final infoPuffs:Array<TileData>;
    // public final helpButton:TileData;
    // public final soundButtons:Array<TileData>;

    public function new() {
        tileset = new Tileset(Assets.getBitmapData('assets/sheet.png'));

        towerTop = makeTileData(new Rectangle(0, 0, 32, 16));
        towerMid = makeTileData(new Rectangle(0, 16, 32, 8));
        towerBot = makeTileData(new Rectangle(0, 24, 32, 8));

        trees = new Array();
        for (i in 0...16) {
            trees[i] = makeTileData(new Rectangle(32 + 8 * i, 0, 8, 16));
        }

        rocks = [];
        for (i in 0...4) {
            rocks[i] = makeTileData(new Rectangle(32 + 8 * (12 + i), 16, 8, 8));
        }

        houses = new Array();
        for (i in 0...3) {
            houses[i] = new Array();
            for (j in 0...8) {
                houses[i][j] = makeTileData(new Rectangle(160 + i * 16, j * 16, 16, 16));
            }
        }

        peons = new Array();
        for (i in 0...4) {
            peons[i] = new Array();
            for (j in 0...12) {
                peons[i][j] = makeTileData(new Rectangle(32 + 8 * j, 16 + 8 * i, 8, 8));
            }
        }

        deleteButton = makeTileData(new Rectangle(32 + 16 * 8 + 3 * 16, 0, 16, 16));

        carriedResources = new Array();
        for (i in 0...4) {
            carriedResources[i] = makeTileData(new Rectangle(32 + (12 + i) * 8, 4 * 8, 8, 8));
        }

        smoke = new Array();
        for (i in 0...5) {
            smoke[i] = makeTileData(new Rectangle(256 - 8, 8 * i, 8, 8));
        }

        healthBar = [];
        for (i in 0...2) {
            healthBar[i] = makeTileData(new Rectangle(256 - 32 + i, 0, 1, 1));
        }
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
