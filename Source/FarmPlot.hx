package;

import Resources.Resource;

class FarmPlot extends Entity {
    static inline final GROW_SPEED = 7 * Main.TICKS_PER_SECOND;
    static inline final NUM_SPRITES = 8;
    static inline final MATURE_AGE = (NUM_SPRITES - 1) * GROW_SPEED;
    static inline final HARVEST_TIME = 1 * Main.TICKS_PER_SECOND;
    static inline final HARVEST_PER_TICK = Std.int(MATURE_AGE / HARVEST_TIME);

    var stamina:Int;
    var age(default, set):Int;

    var spriteIndex:Int;

    override public function new(x:Float, y:Float, age:Int) {
        super(x, y, 0); // We can "walk through" farm plots

        this.stamina = this.age = age;

        sprite.originX = 4;
        sprite.originY = 5;
    }

    override function update() {
        super.update();

        if (age < MATURE_AGE) {
            ++age;
            ++stamina;
        }
    }

    override function render() {
        super.render();
        sprite.id = spriteSheet.farmPlots[spriteIndex];
    }

    function set_age(age:Int) {
        spriteIndex = NUM_SPRITES - 1 - Std.int(age / GROW_SPEED);
        return this.age = age;
    }

    override function givesResource(r:Resource):Bool {
        return (age / GROW_SPEED > 6) && r == FOOD;
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
