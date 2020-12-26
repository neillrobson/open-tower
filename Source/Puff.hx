package;

import openfl.display.Tile;

class Puff {
    public var tile = new Tile();

    final spriteSheet:SpriteSheet;

    final lifeTime:Float;
    var life = 0.0;

    final xSpeed = 1.0;

    var ySpeed = -9.0;
    var yAccel = 0.0;

    public function new(x:Float, y:Float, spriteSheet:SpriteSheet) {
        this.spriteSheet = spriteSheet;

        tile.x = x;
        tile.y = y;
        tile.originX = 4;
        tile.originY = 4;

        lifeTime = 3 + Math.random() * 2;
    }

    public function update() {
        life += Main.SECONDS_PER_TICK;

        tile.x += xSpeed * Main.SECONDS_PER_TICK;

        tile.y += ySpeed * Main.SECONDS_PER_TICK;
        ySpeed += yAccel * Main.SECONDS_PER_TICK;
        yAccel = -1 * ySpeed;

        var age = Std.int(life * 6 / lifeTime);
        if (age <= 4)
            tile.id = spriteSheet.smoke[age].id;
        else
            tile.alpha = 0;
    }

    public function alive() {
        return life < lifeTime;
    }
}
