package;

import openfl.display.Shape;
import openfl.events.MouseEvent;
import openfl.display.Bitmap;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;

class Toolbar extends Sprite {
    var game:Game;
    var gameTime = 0;

    var timeText:TextField;

    var selectedHouseType = 0;
    var selectedHouseMarker:Shape;

    public function new(width:Int, height:Int, game:Game) {
        super();
        this.game = game;
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

        var spriteSheet = game.spriteSheet;

        for (i in -1...HouseType.houseTypes.length) {
            var x = getHouseXCoord(i);
            var y = 2;

            var houseButton = new Sprite();
            houseButton.x = x;
            houseButton.y = y;

            // Give the button a full twenty-pixel square size
            var boundingBox = new Shape();
            boundingBox.graphics.beginFill(0, 0);
            boundingBox.graphics.drawRect(0, 0, 20, 20);
            houseButton.addChild(boundingBox);

            var img;
            if (i == -1) {
                img = new Bitmap(spriteSheet.deleteButton.bitmapData);
            } else {
                img = new Bitmap(HouseType.houseTypes[i].getImage(spriteSheet).bitmapData);
            }
            img.x = img.y = 2;
            houseButton.addChild(img);
            houseButton.addEventListener(MouseEvent.CLICK, event -> selectedHouseType = i);
            addChild(houseButton);
        }

        selectedHouseMarker = new Shape();
        selectedHouseMarker.y = 2;
        selectedHouseMarker.graphics.lineStyle(1, 0xFFFFFF);
        selectedHouseMarker.graphics.drawRect(0, 0, 20, 20);
        addChild(selectedHouseMarker);
    }

    private function getHouseXCoord(type):Int {
        return (type + 1) * 20 + Std.int((width - (HouseType.houseTypes.length + 1) * 20) / 2);
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

        selectedHouseMarker.x = getHouseXCoord(selectedHouseType);
    }
}
