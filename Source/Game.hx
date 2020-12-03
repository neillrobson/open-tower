package;

import openfl.display.Sprite;

class Game extends Sprite {
    static final WIDTH = 512;
    static final HEIGHT = 320;
    static final TOOLBAR_HEIGHT = 40;

    public function new() {
        super();
        init();
    }

    function init() {
        graphics.clear();

        // Main game area
        graphics.beginFill(0x4379B7);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        // Toolbar
        graphics.beginFill(0x87ADFF);
        graphics.drawRect(0, 0, WIDTH, TOOLBAR_HEIGHT);
        graphics.endFill();
    }
}
