package;

class Puff extends Entity {
    final lifeTime:Float;
    var life = 0.0;

    var xSpeed = 1.0;

    var z = 0.0;
    var zSpeed = 9.0;
    var zAccel = 0.0;

    override public function new(x:Float, y:Float, island:Island, spriteSheet:SpriteSheet) {
        super(x, y, -1, island, spriteSheet);
        lifeTime = 3 + Math.random() * 2;

        tile.originX = 4;
        tile.originY = 4;
    }

    override function update() {
        super.update();

        x += xSpeed * Main.SECONDS_PER_TICK;

        z += zSpeed * Main.SECONDS_PER_TICK;
        zSpeed += zAccel * Main.SECONDS_PER_TICK;
        zAccel = -1 * zSpeed;

        if ((life += Main.SECONDS_PER_TICK) >= lifeTime)
            alive = false;
    }

    override function render() {
        super.render();

        tile.x = x;
        tile.y = y - z;

        var age = Std.int(life * 6 / lifeTime);
        if (age <= 4)
            tile.id = spriteSheet.smoke[age].id;
        else
            tile.alpha = 0;
    }
}
