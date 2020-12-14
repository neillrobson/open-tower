package;

import event.ToolbarEvent;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Game extends Sprite {
    public static final WIDTH = 512;
    public static final HEIGHT = 320;
    public static final TOOLBAR_HEIGHT = 40;

    public var spriteSheet:SpriteSheet;
    public var entityDisplayLayer:Tilemap;

    public var coordinateTransform:Matrix = new Matrix();

    var islandBitmapTransform = new Matrix();

    public var gameTime(default, null) = 0.0;
    public var pauseTime(default, null) = 0.0;

    var titleScreen(default, set) = true;

    var isMouseOver = false;
    var scrolling = false;
    var xScrollStart = 0.0;

    public var island:Island;

    var toolbar:Toolbar;

    var islandBitmap:Bitmap;
    var islandRotation = 0.0;
    var islandRotationSpeed = 0.0;
    var islandRotationAcceleration = 0.0;

    var logo:Bitmap;
    var titleText:TextField;

    var selectedHouseType:HouseType;
    var cursor:Tile;

    public function new() {
        super();
        init();
    }

    function init() {
        addEventListener(MouseEvent.ROLL_OVER, onRollOver);
        addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
        addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
        addEventListener(MouseEvent.CLICK, onClick);

        graphics.clear();
        graphics.beginFill(0x4379B7);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        var islandBitmapData = Assets.getBitmapData('assets/island.png');
        islandBitmap = new Bitmap(islandBitmapData);
        addChild(islandBitmap);

        spriteSheet = new SpriteSheet();
        entityDisplayLayer = new Tilemap(WIDTH, HEIGHT, spriteSheet.tileset, false);
        addChild(entityDisplayLayer);

        // Don't add to the display list yet, because we're starting on the title screen.
        toolbar = new Toolbar(WIDTH, TOOLBAR_HEIGHT, this);
        toolbar.addEventListener(ToolbarEvent.HOUSE_SELECT, onHouseSelect);

        logo = new Bitmap(Assets.getBitmapData('assets/logo.png'));
        logo.x = (WIDTH - logo.bitmapData.width) / 2;
        logo.y = 16;
        addChild(logo);

        var font = Assets.getFont('assets/nokiafc22.ttf');
        var textFormat = new TextFormat(font.fontName, 8, 0xFFFFFF, true);

        titleText = new TextField();
        titleText.text = "Click to start the game";
        titleText.defaultTextFormat = textFormat;
        titleText.selectable = false;
        titleText.width = titleText.textWidth;
        titleText.x = (WIDTH - titleText.width) / 2;
        titleText.y = HEIGHT - 16;
        addChild(titleText);

        island = new Island(this, islandBitmapData);

        // Don't add cursor yet; we're starting on title screen
        cursor = new Tile();
    }

    public function update() {
        if (titleScreen) {
            pauseTime += Main.SECONDS_PER_TICK;

            titleText.alpha = Std.int(pauseTime * 2) % 2;
        } else {
            gameTime += Main.SECONDS_PER_TICK;

            toolbar.update();
            island.update();
        }

        updateIslandRotation();
        updateCursor();
    }

    function updateIslandRotation() {
        islandRotation += islandRotationSpeed * Main.SECONDS_PER_TICK;
        islandRotationSpeed += islandRotationAcceleration * Main.SECONDS_PER_TICK;

        if (titleScreen) {
            islandRotationAcceleration = 1.2;
        } else {
            if (scrolling) {
                islandRotationAcceleration = (mouseX - xScrollStart) / 20;
            } else if (isMouseOver && mouseY > TOOLBAR_HEIGHT) {
                if (mouseX < 40)
                    islandRotationAcceleration = -8;
                else if (mouseX > WIDTH - 40)
                    islandRotationAcceleration = 8;
                else
                    islandRotationAcceleration = 0;
            } else {
                islandRotationAcceleration = 0;
            }
        }

        islandRotationAcceleration -= 5 * islandRotationSpeed;
    }

    /**
        @param elapsed Milliseconds since last tick/update
    **/
    public function render(elapsed:Float = 0.0) {
        var rot = islandRotation + islandRotationSpeed * elapsed / 1000;

        updateTransforms(rot);
        repositionEntities();

        island.render(rot);
    }

    /**
        @param rot Rotation of the island view in radians
    **/
    function updateTransforms(rot:Float) {
        coordinateTransform.identity();
        coordinateTransform.rotate(rot);
        coordinateTransform.scale(1.5, 0.75);
        coordinateTransform.translate(WIDTH / 2, HEIGHT * 43 / 70);

        islandBitmapTransform.identity();
        islandBitmapTransform.translate(-islandBitmap.bitmapData.width / 2,
            -islandBitmap.bitmapData.height / 2);
        islandBitmapTransform.concat(coordinateTransform);
        islandBitmap.transform.matrix = islandBitmapTransform;
    }

    function repositionEntities() {
        for (e in island.entities) {
            e.updatePos(coordinateTransform);
        }

        entityDisplayLayer.sortTiles((t1, t2) -> {
            return t1.y - t2.y < 0 ? -1 : 1;
        });
        // Move cursor to end of display list
        entityDisplayLayer.setTileIndex(cursor, entityDisplayLayer.numTiles - 1);
    }

    function updateCursor() {
        if (!titleScreen) {
            if (selectedHouseType != null) {
                if (island.canPlaceHouse(mouseX, mouseY, selectedHouseType)) {
                    cursor.x = mouseX - selectedHouseType.anchorX;
                    cursor.y = mouseY - selectedHouseType.anchorY;
                    cursor.alpha = 1;
                } else {
                    cursor.alpha = 0;
                }
            } else {
                var e = island.getEntityAtMouse(mouseX, mouseY, e -> Std.isOfType(e, House));
                if (e != null) {
                    cursor.x = mouseX - 8;
                    cursor.y = mouseY - 8;
                    cursor.alpha = 1;
                } else {
                    cursor.alpha = 0;
                }
            }
        }
    }

    function onRollOut(event) {
        isMouseOver = false;
    }

    function onRollOver(event) {
        isMouseOver = true;
    }

    function onMiddleMouseDown(event) {
        scrolling = true;
        xScrollStart = mouseX;
    }

    function onMiddleMouseUp(event) {
        scrolling = false;
    }

    function onClick(event) {
        if (titleScreen) {
            titleScreen = false;
            return;
        }

        if (selectedHouseType != null) {
            island.placeHouse(mouseX, mouseY, selectedHouseType);
        } else {
            var e = island.getEntityAtMouse(mouseX, mouseY, e -> Std.isOfType(e, House));
            if (e != null) {
                cast(e, House).sell();
            }
        }
    }

    function onHouseSelect(event:ToolbarEvent) {
        if (event.selection >= 0) {
            selectedHouseType = HouseType.houseTypes[event.selection];
            cursor.id = selectedHouseType.getImage(spriteSheet).id;
        } else {
            selectedHouseType = null;
            cursor.id = spriteSheet.deleteButton.id;
        }
    }

    function set_titleScreen(ts:Bool):Bool {
        if (ts) {
            removeChild(toolbar);
            entityDisplayLayer.removeTile(cursor);
            addChild(logo);
            addChild(titleText);
        } else {
            addChild(toolbar);
            entityDisplayLayer.addTile(cursor);
            removeChild(logo);
            removeChild(titleText);
        }

        return titleScreen = ts;
    }
}
