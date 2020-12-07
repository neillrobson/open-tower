package;

import openfl.display.Tilemap;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Game extends Sprite implements GameObject {
    public static final WIDTH = 512;
    public static final HEIGHT = 320;
    public static final TOOLBAR_HEIGHT = 40;

    public var spriteSheet:SpriteSheet;
    public var entityDisplayLayer:Tilemap;

    var isMouseOver = false;
    var scrolling = false;
    var xScrollStart = 0.0;

    var island:Island;

    var toolbar:Toolbar;

    var islandBitmap:Bitmap;
    var islandRotation = 0.0;
    var islandRotationSpeed = 0.0;

    public function new() {
        super();
        init();
    }

    function init() {
        addEventListener(MouseEvent.ROLL_OVER, onRollOver);
        addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
        addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);

        graphics.clear();
        graphics.beginFill(0x4379B7);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        toolbar = new Toolbar(WIDTH, TOOLBAR_HEIGHT);
        addChild(toolbar);

        var islandBitmapData = Assets.getBitmapData('assets/island.png');
        islandBitmap = new Bitmap(islandBitmapData);
        addChild(islandBitmap);

        spriteSheet = new SpriteSheet();
        entityDisplayLayer = new Tilemap(WIDTH, HEIGHT, spriteSheet.tileset, false);
        addChild(entityDisplayLayer);

        island = new Island(this, islandBitmapData);
    }

    public function update() {
        toolbar.update();

        islandRotation += islandRotationSpeed;
        islandRotationSpeed *= 0.7;

        // if (true) {
        //     islandRotationSpeed += 0.002;
        // }

        if (scrolling) {
            islandRotationSpeed += (mouseX - xScrollStart) / 10000;
        } else if (isMouseOver && mouseY > TOOLBAR_HEIGHT) {
            if (mouseX < 80)
                islandRotationSpeed -= 0.02;
            if (mouseX > WIDTH - 80)
                islandRotationSpeed += 0.02;
        }
    }

    public function render() {
        toolbar.render();

        var coordinateTransform = new Matrix();
        coordinateTransform.rotate(islandRotation);
        coordinateTransform.scale(1.5, 0.75);
        coordinateTransform.translate(WIDTH / 2, HEIGHT * 43 / 70);

        var islandTransformMatrix = new Matrix();
        islandTransformMatrix.translate(-islandBitmap.bitmapData.width / 2, -islandBitmap.bitmapData.height / 2);
        islandTransformMatrix.concat(coordinateTransform);
        islandBitmap.transform.matrix = islandTransformMatrix;

        for (tree in island.trees) {
            tree.updatePos(coordinateTransform);
        }

        entityDisplayLayer.sortTiles((t1, t2) -> {
            return t1.y - t2.y < 0 ? -1 : 1;
        });
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
}
