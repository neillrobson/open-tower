package;

import Resources.Resource;

class Tree extends Entity {
    /** About eleven seconds per "sprite change" growth **/
    public static inline final GROW_SPEED = 11 * Main.TICKS_PER_SECOND;

    /** There are sixteen tree sprites to account for **/
    static inline final MATURE_AGE = GROW_SPEED * 15;

    /** About three seconds to harvest a fully-grown tree **/
    static inline final HARVEST_TIME = 3 * Main.TICKS_PER_SECOND;

    static inline final HARVEST_PER_TICK = Std.int(MATURE_AGE / HARVEST_TIME);

    // public static final SPREAD_INTERVAL = 1000 * Main.TICKS_PER_SECOND;
    private var age(default, set):Int;
    private var stamina:Int;

    // private var spreadDelay:Int;
    // private var yield:Int;

    public function new(x:Float, y:Float, age:Int, island:Island, spriteSheet:SpriteSheet) {
        super(x, y, 4, island, spriteSheet);
        this.stamina = this.age = age;
        sprite.originX = 4;
        sprite.originY = 16;
    }

    override public function update() {
        if (age < MATURE_AGE) {
            ++age;
            ++stamina;
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
        stamina -= HARVEST_PER_TICK;
        if (stamina <= 0) {
            alive = false;
            return true;
        }
        return false;
    }
}
