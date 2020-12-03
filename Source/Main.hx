package;

import haxe.Timer;
import openfl.events.Event;
import openfl.display.Sprite;

class Main extends Sprite {
    public static final TICKS_PER_SECOND = 30;
    public static final MAX_TICKS_PER_FRAME = 10;
    public static final SECONDS_PER_TICK = 1 / TICKS_PER_SECOND;

    var lastTime = -1.0;

    var tickCount = 0;
    var frames = 0;

    var game:Game;

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
        game = new Game();
        addChild(game);

        onResize(null);
    }

    function onResize(event) {
        game.scaleX = game.scaleY = 1;
        var newScaleX:Float = stage.stageWidth / Game.WIDTH;
        var newScaleY:Float = stage.stageHeight / Game.HEIGHT;
        game.scaleX = game.scaleY = Math.min(newScaleX, newScaleY);
        game.x = (stage.stageWidth - Game.WIDTH * game.scaleX) / 2;
        game.y = (stage.stageHeight - Game.HEIGHT * game.scaleY) / 2;
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

        game.update();

        if (tickCount % TICKS_PER_SECOND == 0) {
            trace('$frames fps');
            frames = 0;
        }
    }

    function render() {
        ++frames;

        game.render();
    }
}
