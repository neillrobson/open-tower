package;

class Tree extends Entity {
    public static final GROW_SPEED = 320; // Every ten seconds or so

    // public static final SPREAD_INTERVAL = 30000; // Every 1000 seconds
    private var age:Int;

    // private var spreadDelay:Int;
    // private var stamina:Int;
    // private var yield:Int;

    public function new(x:Float, y:Float, age:Int) {
        super(x, y, 4);
        this.age = age;
    }

    public override function update() {
        if (age < 15 * GROW_SPEED) {
            ++age;
        }
    }

    public override function render() {
        tile.x = xr - 4;
        tile.y = yr - 16;
        tile.id = spriteSheet.trees[15 - Std.int(age / GROW_SPEED)].id;
    }
}
