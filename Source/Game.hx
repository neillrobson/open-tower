package;

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

    final main:Main;

    var titleScreen = true;

    var isMouseOver = false;
    var scrolling = false;
    var xScrollStart = 0.0;

    public var island:Island;

    var toolbar:Toolbar;

    var islandBitmap:Bitmap;
    var islandRotation = 0.0;
    var islandRotationSpeed = 0.0;

    var logo:Bitmap;
    var titleText:TextField;

    var cursor:Tile;

    public function new(main:Main) {
        super();
        this.main = main;
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

        toolbar = new Toolbar(WIDTH, TOOLBAR_HEIGHT, this);
        addChild(toolbar);

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

        cursor = new Tile(spriteSheet.deleteButton.id);
        entityDisplayLayer.addTile(cursor);
    }

    public function update() {
        if (!titleScreen) {
            toolbar.update();
            island.update();
        }

        islandRotation += islandRotationSpeed;
        islandRotationSpeed *= 0.7;

        if (titleScreen) {
            islandRotationSpeed += 0.002;
        } else {
            if (scrolling) {
                islandRotationSpeed += (mouseX - xScrollStart) / 10000;
            } else if (isMouseOver && mouseY > TOOLBAR_HEIGHT) {
                if (mouseX < 40)
                    islandRotationSpeed -= 0.02;
                if (mouseX > WIDTH - 40)
                    islandRotationSpeed += 0.02;
            }
        }
    }

    public function render(alpha:Float = 0.0) {
        if (titleScreen) {
            toolbar.alpha = 0;
        } else {
            toolbar.alpha = 1;
            toolbar.render();
        }

        coordinateTransform.identity();
        coordinateTransform.rotate(islandRotation + islandRotationSpeed * alpha);
        coordinateTransform.scale(1.5, 0.75);
        coordinateTransform.translate(WIDTH / 2, HEIGHT * 43 / 70);

        var islandTransformMatrix = new Matrix();
        islandTransformMatrix.translate(-islandBitmap.bitmapData.width / 2, -islandBitmap.bitmapData.height / 2);
        islandTransformMatrix.concat(coordinateTransform);
        islandBitmap.transform.matrix = islandTransformMatrix;

        for (e in island.entities) {
            e.updatePos(coordinateTransform);
            e.render();
        }

        entityDisplayLayer.sortTiles((t1, t2) -> {
            return t1.y - t2.y < 0 ? -1 : 1;
        });
        entityDisplayLayer.addTile(cursor); // Move cursor to end of display list

        if (titleScreen) {
            cursor.alpha = 0;
        } else {
            if (toolbar.selectedHouseType >= 0) {
                var type = HouseType.houseTypes[toolbar.selectedHouseType];
                if (island.canPlaceHouse(mouseX, mouseY, type)) {
                    cursor.id = type.getImage(spriteSheet).id;
                    cursor.x = mouseX - type.anchorX;
                    cursor.y = mouseY - type.anchorY;
                    cursor.alpha = 1;
                } else {
                    cursor.alpha = 0;
                }
            } else {
                var e = island.getEntityAtMouse(mouseX, mouseY, e -> Std.isOfType(e, House));
                if (e != null) {
                    cursor.id = spriteSheet.deleteButton.id;
                    cursor.x = mouseX - 8;
                    cursor.y = mouseY - 8;
                    cursor.alpha = 1;
                } else {
                    cursor.alpha = 0;
                }
            }
        }

        if (titleScreen) {
            logo.alpha = 1;
            titleText.alpha = Std.int(main.tickCount / 15) % 2;
        } else {
            logo.alpha = 0;
            titleText.alpha = 0;
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

        if (toolbar.selectedHouseType >= 0) {
            island.placeHouse(mouseX, mouseY, HouseType.houseTypes[toolbar.selectedHouseType]);
        } else {
            var e = island.getEntityAtMouse(mouseX, mouseY, e -> Std.isOfType(e, House));
            if (e != null) {
                cast(e, House).sell();
            }
        }
    }
}
