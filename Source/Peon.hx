package;

class Peon extends Entity {
    static final animSteps = [0, 1, 0, 2];
    static final animDirs = [2, 0, 3, 1];

    var type:Int;

    var rot:Float;
    var moveTick:Float;

    override public function new(x:Float, y:Float, type:Int) {
        super(x, y, 1);
        this.type = type;

        rot = Math.random() * 2 * Math.PI;
        moveTick = Math.random() * 12;
    }

    override function init(island:Island, spriteSheet:SpriteSheet) {
        super.init(island, spriteSheet);
        tile.originX = 4;
        tile.originY = 8;
    }

    override function update() {
        super.update();

        var speed = 0.5;

        var xt = x + Math.cos(rot) * speed;
        var yt = y + Math.sin(rot) * speed;

        if (island.isFreeExcept(xt, yt, r, this)) {
            x = xt;
            y = yt;
        } else {
            rot += Math.PI * 1.1;
        }

        moveTick += speed;
    }

    /** Non-negative residue **/
    inline function mod(x:Int, m:Int) {
        return (x % m + m) % m;
    }

    override function render() {
        super.render();

        var rotStep = mod(Math.round(4 * (rot + island.rot) / (2 * Math.PI)), 4);
        var animStep = animSteps[mod(Math.floor(moveTick / 4), 4)];

        tile.id = spriteSheet.peons[type][animDirs[rotStep] * 3 + animStep].id;
    }
}
