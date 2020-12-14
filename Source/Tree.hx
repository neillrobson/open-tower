package;

class Tree extends Entity {
    // TODO: Make these constants independent of tick rate
    public static final GROW_SPEED = 320; // Every ten seconds or so

    // public static final SPREAD_INTERVAL = 30000; // Every 1000 seconds
    private var age(default, set):Int;

    // private var spreadDelay:Int;
    // private var stamina:Int;
    // private var yield:Int;

    public function new(x:Float, y:Float, age:Int) {
        super(x, y, 4);
        this.age = age;
        anchorX = 4;
        anchorY = 16;
    }

    override function init(island:Island, spriteSheet:SpriteSheet) {
        super.init(island, spriteSheet);
        set_age(age);
    }

    override public function update() {
        if (age < 15 * GROW_SPEED) {
            ++age;
        }
    }

    function set_age(newAge:Int) {
        if (inited)
            tile.id = spriteSheet.trees[15 - Std.int(newAge / GROW_SPEED)].id;
        return age = newAge;
    }
}
