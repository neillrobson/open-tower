package;

import Resources.Resource;

class Tree extends Entity {
    public static final GROW_SPEED = 11 * Main.TICKS_PER_SECOND;

    // public static final SPREAD_INTERVAL = 1000 * Main.TICKS_PER_SECOND;
    private var age(default, set):Int;

    // private var spreadDelay:Int;
    // private var stamina:Int;
    // private var yield:Int;

    public function new(x:Float, y:Float, age:Int, island:Island, spriteSheet:SpriteSheet) {
        super(x, y, 4, island, spriteSheet);
        this.age = age;
        sprite.originX = 4;
        sprite.originY = 16;
    }

    override public function update() {
        if (age < 15 * GROW_SPEED) {
            ++age;
        }
    }

    function set_age(newAge:Int) {
        sprite.id = spriteSheet.trees[15 - Std.int(newAge / GROW_SPEED)].id;
        return age = newAge;
    }

    override function givesResource(r:Resource):Bool {
        return (age / GROW_SPEED > 6) && r == Resource.WOOD;
    }

    override function gatherResource(r:Resource):Bool {
        alive = false;
        return true;
    }
}
