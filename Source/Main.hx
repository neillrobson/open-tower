package;

import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.Sprite;

class Main extends Sprite {
    public function new() {
        super();
        var bitmapData = Assets.getBitmapData('assets/openfl.png');
        var bitmap = new Bitmap(bitmapData);
        addChild(bitmap);
    }
}
