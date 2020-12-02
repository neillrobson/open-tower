package;

import openfl.text.TextFormat;
import openfl.text.TextField;
import haxe.Timer;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.Sprite;

class Main extends Sprite {
    static final TICKS_PER_SECOND = 30;
    static final MAX_TICKS_PER_FRAME = 10;
    static final SECONDS_PER_TICK = 1 / TICKS_PER_SECOND;

    var lastTime = -1.0;

    var gameTime = 0;
    var bSprite:Sprite;
    var timeText:TextField;

    public function new() {
        super();
        init();
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    function init() {
        var bitmapData = Assets.getBitmapData('assets/logo.png');
        var bitmap = new Bitmap(bitmapData);
        bSprite = new Sprite();
        bSprite.addChild(bitmap);
        bSprite.addEventListener(MouseEvent.CLICK, startAnimation);
        addChild(bSprite);

        timeText = new TextField();
        timeText.x = 300;
        timeText.y = 300;
        timeText.defaultTextFormat = new TextFormat("Verdana", 24, 0x000000, true);
        timeText.selectable = false;
        addChild(timeText);
    }

    function onEnterFrame(event) {
        var elapsedTime = Timer.stamp();

        if (lastTime < 0) {
            lastTime = elapsedTime;
            update();
        } else if (elapsedTime - lastTime > SECONDS_PER_TICK) {
            var count = 0;

            while (elapsedTime - lastTime > SECONDS_PER_TICK) {
                if (count > MAX_TICKS_PER_FRAME) {
                    lastTime = elapsedTime;
                    break;
                }

                update();
                lastTime += SECONDS_PER_TICK;
                ++count;
            }
        }

        render();
    }

    function update() {
        ++gameTime;
    }

    function render() {
        var seconds = Std.int(gameTime * SECONDS_PER_TICK);
        var minutes = Std.int(seconds / 60);
        var hours = Std.int(minutes / 60);
        seconds %= 60;
        minutes %= 60;

        var timeString = '${hours > 0 ? hours + ":" : ""}';
        timeString += '${minutes < 10 ? "0" : ""}${minutes}:';
        timeString += '${seconds < 10 ? "0" : ""}${seconds}';

        graphics.beginFill(0x4379B7);
        graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        graphics.endFill();

        timeText.text = timeString;
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
