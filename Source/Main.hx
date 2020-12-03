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
    static final WIDTH = 512;
    static final HEIGHT = 320;
    static final TOOLBAR_HEIGHT = 40;
    static final GAME_AREA_HEIGHT = HEIGHT - TOOLBAR_HEIGHT;

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

    var toolbar:Sprite;
    var gameArea:Sprite;

    public function new() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    function onAddedToStage(event) {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        init();
        stage.addEventListener(Event.RESIZE, onResize);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    function init() {
        toolbar = new Sprite();
        addChild(toolbar);

        gameArea = new Sprite();
        addChild(gameArea);

        var islandBitmapData = Assets.getBitmapData('assets/island.png');
        island = new Bitmap(islandBitmapData);
        // addChild(island);

        timeText = new TextField();
        timeText.x = 4;
        timeText.y = 4;
        timeText.width = 400;
        timeText.defaultTextFormat = new TextFormat(null, 20, 0xFFFFFF, true);
        timeText.selectable = false;
        // addChild(timeText);

        onResize(null);
    }

    function onResize(event) {
        toolbar.graphics.clear();
        toolbar.graphics.lineStyle(2);
        toolbar.graphics.beginFill(0x87ADFF);
        toolbar.graphics.drawRect(0, 0, stage.stageWidth, TOOLBAR_HEIGHT);
        toolbar.graphics.endFill();

        gameArea.graphics.clear();
        var newScaleX:Float = stage.stageWidth / WIDTH;
        var newScaleY:Float = (stage.stageHeight - TOOLBAR_HEIGHT) / GAME_AREA_HEIGHT;
        var newScale = Math.min(newScaleX, newScaleY);
        gameArea.graphics.lineStyle(2);
        gameArea.graphics.beginFill(0x4379B7);
        gameArea.graphics.drawRect(0, 0, WIDTH * newScale, GAME_AREA_HEIGHT * newScale);
        gameArea.graphics.endFill();
        gameArea.x = (stage.stageWidth - WIDTH * newScale) / 2;
        gameArea.y = TOOLBAR_HEIGHT + (stage.stageHeight - TOOLBAR_HEIGHT - GAME_AREA_HEIGHT * newScale) / 2;
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
        islandTransformMatrix.translate(width / 2, height / 2);
        island.transform.matrix = islandTransformMatrix;

        timeText.text = timeString;
    }
}
