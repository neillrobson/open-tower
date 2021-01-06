package;

import Resources.Resource;

class Tree extends Entity {
    /** About eleven seconds per "sprite change" growth **/
    public static inline final GROW_SPEED = 11 * Main.TICKS_PER_SECOND;

    static inline final NUM_SPRITES = 16;

    /** There are sixteen tree sprites to account for **/
    static inline final MATURE_AGE = GROW_SPEED * (NUM_SPRITES - 1);

    /** About three seconds to harvest a fully-grown tree **/
    static inline final HARVEST_TIME = 3 * Main.TICKS_PER_SECOND;

    static inline final HARVEST_PER_TICK = Std.int(MATURE_AGE / HARVEST_TIME);

    /** Try to grow a new tree once every seventeen minutes or so **/
    static inline final SPREAD_INTERVAL = 1000 * Main.TICKS_PER_SECOND;

    var random = new Random();

    private var age(default, set):Int;
    private var stamina:Int;
    private var spreadDelay:Int;

    // TODO: Variable yield based on maturity?
    // private var yield:Int;

    public function new(x:Float, y:Float, age:Int) {
        super(x, y, 4);
        this.stamina = this.age = age;
        spreadDelay = Std.int(Math.random() * SPREAD_INTERVAL);
        sprite.originX = 4;
        sprite.originY = 16;
    }

    override public function update() {
        if (age < MATURE_AGE) {
            ++age;
            ++stamina;
        } else if (--spreadDelay <= 0) {
            var xp = x + random.floatNormal() * 8;
            var yp = y + random.floatNormal() * 8;
            var tree = new Tree(xp, yp, 0);
            if (island.isFree(tree.x, tree.y, tree.r)) {
                island.addEntity(tree);
                spreadDelay += SPREAD_INTERVAL;
            }
        }
    }

    function set_age(age:Int) {
        sprite.id = Global.spriteSheet.trees[(NUM_SPRITES - 1) - Std.int(age / GROW_SPEED)];
        return this.age = age;
    }

    override function givesResource(r:Resource):Bool {
        return (age / GROW_SPEED > 6) && r == Resource.WOOD;
    }

    override function gatherResource(r:Resource):Bool {
        stamina -= HARVEST_PER_TICK;
        if (stamina <= 0) {
            die();
            return true;
        }
        return false;
    }
}
