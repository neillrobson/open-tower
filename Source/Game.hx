package;

import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Game extends Sprite implements GameObject {
    public static final WIDTH = 512;
    public static final HEIGHT = 320;
    public static final TOOLBAR_HEIGHT = 40;

    var toolbar:Toolbar;

    var island:Bitmap;
    var islandRotation = 0.0;
    var islandRotationSpeed = 0.0;

    var mouseStageX = -1.0;
    var mouseStageY = 0.0;
    var mousePos:TextField;

    public function new() {
        super();
        init();
    }

    function init() {
        addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

        graphics.clear();
        graphics.beginFill(0x4379B7);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        toolbar = new Toolbar(WIDTH, TOOLBAR_HEIGHT);
        addChild(toolbar);

        var islandBitmapData = Assets.getBitmapData('assets/island.png');
        island = new Bitmap(islandBitmapData);
        addChild(island);

        mousePos = new TextField();
        mousePos.x = 200;
        mousePos.y = 4;
        mousePos.width = 200;
        mousePos.defaultTextFormat = new TextFormat(null, 20, 0xFFFFFF, true);
        mousePos.selectable = false;
        addChild(mousePos);
    }

    public function update() {
        toolbar.update();

        islandRotation += islandRotationSpeed;
        islandRotationSpeed *= 0.7;

        // if (true) {
        //     islandRotationSpeed += 0.002;
        // }

        if (mouseStageX >= 0 && mouseStageY < stage.stageHeight && mouseStageY > 0) {
            if (mouseStageX < 80)
                islandRotationSpeed -= 0.02;
            if (mouseStageX > stage.stageWidth - 80)
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

        mousePos.text = 'X: $mouseStageX Y: $mouseStageY';
    }

    function onMouseMove(event:MouseEvent) {
        mouseStageX = event.stageX;
        mouseStageY = event.stageY;
    }
}
