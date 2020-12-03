package;

import openfl.geom.Matrix;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.text.TextFormat;
import openfl.text.TextField;
import haxe.Timer;
import openfl.events.Event;
import openfl.display.Sprite;

class Main extends Sprite {
    static final TICKS_PER_SECOND = 30;
    static final MAX_TICKS_PER_FRAME = 10;
    static final SECONDS_PER_TICK = 1 / TICKS_PER_SECOND;

    var lastTime = -1.0;

    var gameTime = 0;
    var tickCount = 0;
    var frames = 0;
    var timeText:TextField;

    var island:Bitmap;
    var islandRotation = 0.0;
    var islandRotationSpeed = 0.0;

    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    function onAddedToStage(event) {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        init();
        addEventListener(Event.RESIZE, onResize);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    function init() {
        onResize(null);

        var islandBitmapData = Assets.getBitmapData('assets/island.png');
        island = new Bitmap(islandBitmapData);
        addChild(island);

        timeText = new TextField();
        timeText.x = 4;
        timeText.y = 4;
        timeText.width = 400;
        timeText.defaultTextFormat = new TextFormat(null, 20, 0xFFFFFF, true);
        timeText.selectable = false;
        addChild(timeText);
    }

    function onResize(event) {
        graphics.beginFill(0x4379B7);
        graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        graphics.endFill();

        graphics.beginFill(0x87ADFF);
        graphics.drawRect(0, 0, stage.stageWidth, 40);
        graphics.endFill();
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
        ++tickCount;
        ++gameTime;

        islandRotation += islandRotationSpeed;
        islandRotationSpeed *= 0.7;

        if (true) {
            islandRotationSpeed += 0.002;
        }

        if (tickCount % TICKS_PER_SECOND == 0) {
            trace('$frames fps');
            frames = 0;
        }
    }

    function render() {
        ++frames;

        var seconds = Std.int(gameTime * SECONDS_PER_TICK);
        var minutes = Std.int(seconds / 60);
        var hours = Std.int(minutes / 60);
        seconds %= 60;
        minutes %= 60;

        var timeString = 'Time: ${hours > 0 ? hours + ":" : ""}';
        timeString += '${minutes < 10 ? "0" : ""}${minutes}:';
        timeString += '${seconds < 10 ? "0" : ""}${seconds}';

        var islandTransformMatrix = new Matrix();
        islandTransformMatrix.translate(-island.bitmapData.width / 2, -island.bitmapData.height / 2);
        islandTransformMatrix.rotate(islandRotation);
        islandTransformMatrix.scale(1.5, 0.75);
        islandTransformMatrix.translate(stage.stageWidth / 2, stage.stageHeight / 2);
        island.transform.matrix = islandTransformMatrix;

        timeText.text = timeString;
    }
}
