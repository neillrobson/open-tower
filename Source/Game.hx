package;

import openfl.display.Sprite;

class Game extends Sprite implements GameObject {
    static final WIDTH = 512;
    static final HEIGHT = 320;
    static final TOOLBAR_HEIGHT = 40;

    var toolbar:Toolbar;

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

        toolbar = new Toolbar(WIDTH, TOOLBAR_HEIGHT);
        addChild(toolbar);
    }

    public function update() {
        toolbar.update();
    }

    public function render() {
        toolbar.render();
    }
}
