package;

import openfl.Lib;
import openfl.events.Event;
import openfl.display.Sprite;

class Main extends Sprite {
    public static inline final TICKS_PER_SECOND = 30;
    public static inline final MAX_TICKS_PER_FRAME = 10;
    public static inline final SECONDS_PER_TICK = 1 / TICKS_PER_SECOND;
    public static inline final MILLISECONDS_PER_TICK = 1000 / TICKS_PER_SECOND;

    /** Milliseconds since last frame render **/
    var lastTime = -1.0;

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

        #if debug
        addChild(new InfoDebug());
        #end

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
        var elapsedTime = Lib.getTimer();

        if (lastTime < 0) {
            lastTime = elapsedTime;
            game.update();
        } else if (elapsedTime - lastTime > MILLISECONDS_PER_TICK) {
            var count = 0;

            while (elapsedTime - lastTime > MILLISECONDS_PER_TICK) {
                if (count > MAX_TICKS_PER_FRAME) {
                    lastTime = elapsedTime;
                    break;
                }

                game.update();
                lastTime += MILLISECONDS_PER_TICK;
                ++count;
            }
        }

        game.render(elapsedTime - lastTime);
    }
}
