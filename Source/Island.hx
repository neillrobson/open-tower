package;

import openfl.display.BitmapData;

class Island {
    private var game:Game;
    private var image:BitmapData;

    public var trees:Array<Tree> = new Array();

    public function new(game:Game, image:BitmapData) {
        this.game = game;
        this.image = image;
        init();
    }

    public function init() {
        for (_ in 0...20) {
            var x = Math.random() * 256 - 128;
            var y = Math.random() * 256 - 128;
            var tree = new Tree(x, y);
            if (isFree(tree.x, tree.y, tree.r)) {
                addEntity(tree);
            }
        }
    }

    public function update() {}

    public function render() {}

    function addEntity(e:Tree) {
        e.init(game.spriteSheet);
        game.entityDisplayLayer.addTile(e.tile);
        trees.push(e);
    }

    function isFree(x:Float, y:Float, r:Float):Bool {
        return isOnGround(x, y);
    }

    function isOnGround(x:Float, y:Float):Bool {
        var xPixel = Math.round(x + 128);
        var yPixel = Math.round(y + 128);
        if (xPixel < 0 || yPixel < 0 || xPixel >= 256 || yPixel >= 256) {
            return false;
        }
        return image.getPixel32(xPixel, yPixel) >>> 24 > 128;
    }
}
