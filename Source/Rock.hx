package;

import Resources.Resource;

class Rock extends Entity {
    static inline final INITIAL_STANIMA = 5000;

    var stanima = INITIAL_STANIMA;
    var life = 16;

    public function new(x:Float, y:Float, spriteSheet:SpriteSheet) {
        super(x, y, 5, spriteSheet);

        sprite.originX = 4;
        sprite.originY = 6;
        sprite.id = spriteSheet.rocks[Std.int(Math.random() * 4)].id;
    }

    override function gatherResource(r:Resource):Bool {
        stanima -= 64;
        if (stanima <= 0) {
            stanima += INITIAL_STANIMA;
            if (--life == 0)
                die();
            return true;
        }
        return false;
    }

    override function givesResource(r:Resource):Bool {
        return r == ROCK;
    }
}
