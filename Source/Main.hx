package;

import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.Sprite;

class Main extends Sprite {
    var bSprite:Sprite;

    public function new() {
        super();

        var width = stage.stageWidth;
        var height = stage.stageHeight;

        graphics.beginFill(0x4379B7);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();

        var bitmapData = Assets.getBitmapData('assets/logo.png');
        var bitmap = new Bitmap(bitmapData);
        bSprite = new Sprite();
        bSprite.addChild(bitmap);
        bSprite.addEventListener(MouseEvent.CLICK, startAnimation);
        addChild(bSprite);
    }

    function fadeBitmap(event) {
        bSprite.alpha -= 0.05;
        if (bSprite.alpha <= 0) {
            bSprite.removeEventListener(Event.ENTER_FRAME, fadeBitmap);
        }
    }

    function startAnimation(event) {
        bSprite.addEventListener(Event.ENTER_FRAME, fadeBitmap);
    }
}
