package;

import event.ToolbarEvent;
import openfl.Assets;
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
    var populationText:TextField;
    var warriorText:TextField;
    var woodText:TextField;
    var rockText:TextField;
    var foodText:TextField;

    var selectedHouseMarker:Shape;

    public function new(width:Int, height:Int, game:Game) {
        super();
        this.game = game;
        init(width, height);
    }

    function init(width, height) {
        addEventListener(ToolbarEvent.HOUSE_SELECT, onHouseSelect);
        var margin = 2;

        graphics.beginFill(0x87ADFF);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();

        var font = Assets.getFont('assets/nokiafc22.ttf');
        var textFormat = new TextFormat(font.fontName, 8, 0xFFFFFF, true);

        timeText = new TextField();
        timeText.x = margin;
        timeText.y = margin;
        timeText.defaultTextFormat = textFormat;
        timeText.selectable = false;
        addChild(timeText);

        populationText = new TextField();
        populationText.text = "Population: 10 / 10";
        populationText.x = margin;
        populationText.y = margin + 12;
        populationText.defaultTextFormat = textFormat;
        populationText.selectable = false;
        addChild(populationText);

        warriorText = new TextField();
        warriorText.text = "Warriors: 0 / 0";
        warriorText.x = margin;
        warriorText.y = margin + 24;
        warriorText.defaultTextFormat = textFormat;
        warriorText.selectable = false;
        addChild(warriorText);

        woodText = new TextField();
        woodText.text = "Wood: 9999";
        woodText.defaultTextFormat = textFormat;
        woodText.selectable = false;
        woodText.x = game.width - woodText.textWidth - 8;
        woodText.y = margin;
        addChild(woodText);

        rockText = new TextField();
        rockText.text = "Rock: 9999";
        rockText.defaultTextFormat = textFormat;
        rockText.selectable = false;
        rockText.x = game.width - rockText.textWidth - 8;
        rockText.y = margin + 12;
        addChild(rockText);

        foodText = new TextField();
        foodText.text = "Food: 9999";
        foodText.defaultTextFormat = textFormat;
        foodText.selectable = false;
        foodText.x = game.width - foodText.textWidth - 8;
        foodText.y = margin + 24;
        addChild(foodText);

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
            houseButton.addEventListener(MouseEvent.CLICK, event -> dispatchEvent(new ToolbarEvent(ToolbarEvent.HOUSE_SELECT, i)));
            addChild(houseButton);
        }

        selectedHouseMarker = new Shape();
        selectedHouseMarker.y = 2;
        selectedHouseMarker.graphics.lineStyle(1, 0xFFFFFF);
        selectedHouseMarker.graphics.drawRect(0, 0, 20, 20);
        addChild(selectedHouseMarker);

        dispatchEvent(new ToolbarEvent(ToolbarEvent.HOUSE_SELECT, -1));
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

        woodText.text = 'Wood: ${game.island.resources.wood}';
        rockText.text = 'Rock: ${game.island.resources.rock}';
        foodText.text = 'Food: ${game.island.resources.food}';
    }

    function onHouseSelect(event:ToolbarEvent) {
        selectedHouseMarker.x = getHouseXCoord(event.selection);
    }
}
