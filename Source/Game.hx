package;

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

        graphics.clear();
        graphics.beginFill(0x4379B7);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        toolbar = new Toolbar(WIDTH, TOOLBAR_HEIGHT);
        addChild(toolbar);

        var islandBitmapData = Assets.getBitmapData('assets/island.png');
        island = new Bitmap(islandBitmapData);
        addChild(island);
    }

    public function update() {
        toolbar.update();

        islandRotation += islandRotationSpeed;
        islandRotationSpeed *= 0.7;

        // if (true) {
        //     islandRotationSpeed += 0.002;
        // }

        if (isMouseOver && mouseY > TOOLBAR_HEIGHT) {
            if (mouseX < 80)
                islandRotationSpeed -= 0.02;
            if (mouseX > WIDTH - 80)
                islandRotationSpeed += 0.02;
        }
    }

    public function render() {
        toolbar.render();

        var islandTransformMatrix = new Matrix();
        islandTransformMatrix.translate(-island.bitmapData.width / 2, -island.bitmapData.height / 2);
        islandTransformMatrix.rotate(islandRotation);
        islandTransformMatrix.scale(1.5, 0.75);
        islandTransformMatrix.translate(WIDTH / 2, HEIGHT * 43 / 70);
        island.transform.matrix = islandTransformMatrix;
    }

    function onRollOut(event) {
        isMouseOver = false;
    }

    function onRollOver(event) {
        isMouseOver = true;
    }
}
