package;

import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;

class Toolbar extends Sprite implements GameObject {
    var gameTime = 0;
    var timeText:TextField;

    public function new(width:Int, height:Int) {
        super();
        init(width, height);
    }

    function init(width, height) {
        graphics.beginFill(0x87ADFF);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();

        timeText = new TextField();
        timeText.x = 4;
        timeText.y = 4;
        timeText.width = 400;
        timeText.defaultTextFormat = new TextFormat(null, 20, 0xFFFFFF, true);
        timeText.selectable = false;
        addChild(timeText);
    }

    public function update() {
        ++gameTime;
    }

    public function render() {
        var seconds = Std.int(gameTime * Main.SECONDS_PER_TICK);
        var minutes = Std.int(seconds / 60);
        var hours = Std.int(minutes / 60);
        seconds %= 60;
        minutes %= 60;

        var timeString = 'Time: ${hours > 0 ? hours + ":" : ""}';
        timeString += '${minutes < 10 ? "0" : ""}${minutes}:';
        timeString += '${seconds < 10 ? "0" : ""}${seconds}';

        timeText.text = timeString;
    }
}
