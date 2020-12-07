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

    var isMouseOver = false;
    var scrolling = false;
    var xScrollStart = 0.0;

    var spriteSheet:SpriteSheet;
    var entityDisplayLayer:Tilemap;

    var trees:Array<Tree> = new Array();

    var toolbar:Toolbar;

    var island:Bitmap;
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
        island = new Bitmap(islandBitmapData);
        addChild(island);

        spriteSheet = new SpriteSheet();
        entityDisplayLayer = new Tilemap(WIDTH, HEIGHT, spriteSheet.tileset, false);
        addChild(entityDisplayLayer);

        var tree = new Tree(100, 100);
        tree.init(spriteSheet);
        entityDisplayLayer.addTile(tree.tile);
        trees.push(tree);
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
        islandTransformMatrix.translate(-island.bitmapData.width / 2, -island.bitmapData.height / 2);
        islandTransformMatrix.concat(coordinateTransform);
        island.transform.matrix = islandTransformMatrix;

        for (tree in trees) {
            tree.updatePos(coordinateTransform);
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
}
