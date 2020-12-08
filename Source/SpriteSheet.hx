package;

import openfl.geom.Rectangle;
import openfl.utils.Assets;
import openfl.display.Tileset;

class SpriteSheet {
    public final tileset:Tileset;

    public final trees:Array<Int>;
    public final towerTop:Int;
    public final towerMid:Int;
    public final towerBot:Int;

    // public final farmPlots:Array<Int>;
    // public final rocks:Array<Int>;
    // public final carriedResources:Array<Int>;
    // public final peons:Array<Array<Int>>;
    // public final smoke:Array<Int>;
    // public final infoPuffs:Array<Int>;
    // public final houses:Array<Int>;
    // public final deleteButton:Int;
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
    }
}
