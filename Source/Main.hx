package;

import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.Sprite;

class Main extends Sprite {
    var circle:Sprite;

    public function new() {
        super();
        var bitmapData = Assets.getBitmapData('assets/openfl.png');
        var bitmap = new Bitmap(bitmapData);
        addChild(bitmap);

        circle = new Sprite();
        circle.graphics.beginFill(0x990000);
        circle.graphics.drawCircle(50, 50, 50);
        circle.graphics.endFill();
        circle.addEventListener(MouseEvent.CLICK, startAnimation);

        addChild(circle);
    }

    function fadeCircle(event) {
        circle.alpha -= 0.05;
        if (circle.alpha <= 0) {
            circle.removeEventListener(Event.ENTER_FRAME, fadeCircle);
        }
    }

    function startAnimation(event) {
        circle.addEventListener(Event.ENTER_FRAME, fadeCircle);
    }
}
