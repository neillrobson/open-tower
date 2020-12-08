package;

import openfl.display.BitmapData;

class Island {
    private var game:Game;
    private var image:BitmapData;

    private var random:Random = new Random();

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
            addForest(x, y);
        }
    }

    public function update() {}

    public function render() {}

    function addForest(x0:Float, y0:Float) {
        for (_ in 0...200) {
            var x = x0 + random.floatNormal() * 12;
            var y = y0 + random.floatNormal() * 12;
            var tree = new Tree(x, y);
            if (isFree(tree.x, tree.y, tree.r)) {
                addEntity(tree);
            }
        }
    }

    function addEntity(e:Tree) {
        e.init(game.spriteSheet);
        game.entityDisplayLayer.addTile(e.tile);
        trees.push(e);
    }

    function isFree(x:Float, y:Float, r:Float):Bool {
        if (!isOnGround(x, y))
            return false;
        for (e in trees) {
            if (e.collides(x, y, r))
                return false;
        }
        return true;
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
