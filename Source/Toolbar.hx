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
    static inline final MARGIN = 2;
    static inline final LINE_HEIGHT = 12;
    static inline final HOUSE_BUTTON_SIDE = 20;
    static inline final HOUSE_BUTTON_PADDING = 2;

    var game:Game;

    var timeText:TextField;
    var populationText:TextField;
    var warriorText:TextField;
    var woodText:TextField;
    var rockText:TextField;
    var foodText:TextField;

    var selectedHouseMarker:Shape;
    var houseCost:TextField;
    var houseDesc:TextField;

    public function new(width:Int, height:Int, game:Game) {
        super();
        this.game = game;
        init(width, height);
    }

    function init(width, height) {
        addEventListener(ToolbarEvent.HOUSE_SELECT, onHouseSelect);

        graphics.beginFill(0x87ADFF);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();

        var font = Assets.getFont('assets/nokiafc22.ttf');
        var textFormat = new TextFormat(font.fontName, 8, 0xFFFFFF, true);

        timeText = new TextField();
        timeText.x = MARGIN;
        timeText.y = MARGIN;
        timeText.defaultTextFormat = textFormat;
        timeText.selectable = false;
        addChild(timeText);

        populationText = new TextField();
        populationText.text = "Population: 10 / 10";
        populationText.x = MARGIN;
        populationText.y = MARGIN + LINE_HEIGHT;
        populationText.defaultTextFormat = textFormat;
        populationText.selectable = false;
        addChild(populationText);

        warriorText = new TextField();
        warriorText.text = "Warriors: 0 / 0";
        warriorText.x = MARGIN;
        warriorText.y = MARGIN + 2 * LINE_HEIGHT;
        warriorText.defaultTextFormat = textFormat;
        warriorText.selectable = false;
        addChild(warriorText);

        woodText = new TextField();
        woodText.text = "Wood: 9999";
        woodText.defaultTextFormat = textFormat;
        woodText.selectable = false;
        woodText.x = game.width - woodText.textWidth - MARGIN;
        woodText.y = MARGIN;
        addChild(woodText);

        rockText = new TextField();
        rockText.text = "Rock: 9999";
        rockText.defaultTextFormat = textFormat;
        rockText.selectable = false;
        rockText.x = game.width - rockText.textWidth - MARGIN;
        rockText.y = MARGIN + LINE_HEIGHT;
        addChild(rockText);

        foodText = new TextField();
        foodText.text = "Food: 9999";
        foodText.defaultTextFormat = textFormat;
        foodText.selectable = false;
        foodText.x = game.width - foodText.textWidth - MARGIN;
        foodText.y = MARGIN + 2 * LINE_HEIGHT;
        addChild(foodText);

        var spriteSheet = game.spriteSheet;

        for (i in -1...HouseType.houseTypes.length) {
            var x = getHouseXCoord(i);

            var houseButton = new Sprite();
            houseButton.x = x;
            houseButton.y = MARGIN;

            // Give the button a full twenty-pixel square size
            var boundingBox = new Shape();
            boundingBox.graphics.beginFill(0, 0);
            boundingBox.graphics.drawRect(0, 0, HOUSE_BUTTON_SIDE, HOUSE_BUTTON_SIDE);
            houseButton.addChild(boundingBox);

            var img;
            if (i == -1) {
                img = new Bitmap(spriteSheet.getBitmapData(spriteSheet.deleteButton));
            } else {
                img = new Bitmap(spriteSheet.getBitmapData(HouseType.houseTypes[i].getImage(spriteSheet)));
            }
            img.x = img.y = HOUSE_BUTTON_PADDING;
            houseButton.addChild(img);
            houseButton.addEventListener(MouseEvent.CLICK,
                event -> dispatchEvent(new ToolbarEvent(ToolbarEvent.HOUSE_SELECT, i)));
            addChild(houseButton);
        }

        selectedHouseMarker = new Shape();
        selectedHouseMarker.y = MARGIN;
        selectedHouseMarker.graphics.lineStyle(1, 0xFFFFFF);
        selectedHouseMarker.graphics.drawRect(0, 0, HOUSE_BUTTON_SIDE, HOUSE_BUTTON_SIDE);
        addChild(selectedHouseMarker);

        houseCost = new TextField();
        houseCost.text = "Sell Building";
        houseCost.defaultTextFormat = textFormat;
        houseCost.selectable = false;
        houseCost.y = MARGIN + 2 * LINE_HEIGHT;
        addChild(houseCost);

        houseDesc = new TextField();
        houseDesc.text = "Returns 75% of wood and rock used";
        houseDesc.defaultTextFormat = textFormat;
        houseDesc.selectable = false;
        houseDesc.y = MARGIN + 3 * LINE_HEIGHT;
        addChild(houseDesc);

        dispatchEvent(new ToolbarEvent(ToolbarEvent.HOUSE_SELECT, -1));
    }

    private function getHouseXCoord(type):Int {
        return (type
            + 1) * HOUSE_BUTTON_SIDE
            + Std.int((width - (HouseType.houseTypes.length + 1) * HOUSE_BUTTON_SIDE) / 2);
    }

    public function update() {
        var seconds = Std.int(game.gameTime);
        var minutes = Std.int(seconds / 60);
        var hours = Std.int(minutes / 60);
        seconds %= 60;
        minutes %= 60;

        var timeString = 'Time: ${hours > 0 ? hours + ":" : ""}';
        timeString += '${minutes < 10 ? "0" : ""}${minutes}:';
        timeString += '${seconds < 10 ? "0" : ""}${seconds}';

        timeText.text = timeString;

        // TODO: Make resource and population text updates event-based
        woodText.text = 'Wood: ${game.island.resources.wood}';
        rockText.text = 'Rock: ${game.island.resources.rock}';
        foodText.text = 'Food: ${game.island.resources.food}';

        populationText.text = 'Population: ${game.island.population} / ${game.island.populationCap}';
        warriorText.text = 'Warriors: ${game.island.warriorPopulation} / ${game.island.warriorPopulationCap}';
    }

    function onHouseSelect(event:ToolbarEvent) {
        selectedHouseMarker.x = getHouseXCoord(event.selection);

        if (event.selection >= 0) {
            var type = HouseType.houseTypes[event.selection];

            houseCost.text = type.getCostString();
            houseDesc.text = type.getDescription();
        } else {
            houseCost.text = "Sell Building";
            houseDesc.text = "Returns 75% of wood and rock used";
        }

        houseCost.width = houseCost.textWidth;
        houseDesc.width = houseDesc.textWidth;
        houseCost.x = selectedHouseMarker.x + HOUSE_BUTTON_SIDE / 2 - houseCost.textWidth / 2;
        houseDesc.x = selectedHouseMarker.x + HOUSE_BUTTON_SIDE / 2 - houseDesc.textWidth / 2;
    }
}
