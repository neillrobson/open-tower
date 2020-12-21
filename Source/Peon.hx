package;

class Peon extends Entity {
    static final animSteps = [0, 1, 0, 2];
    static final animDirs = [2, 0, 3, 1];

    public var job(default, set):Job;

    var type:Int;

    public var rot:Float;

    var moveTick:Float;
    var wanderTime:Int = 0;

    override public function new(x:Float, y:Float, type:Int, island:Island,
            spriteSheet:SpriteSheet) {
        super(x, y, 1, island, spriteSheet);
        this.type = type;

        rot = Math.random() * 2 * Math.PI;
        moveTick = Math.random() * 12;

        tile.originX = 4;
        tile.originY = 8;
    }

    override function update() {
        super.update();

        // Calculate speed and direction.
        // If arrived at job, don't move; instead, do a job.arrived() tick
        var speed = 1;
        if (wanderTime == 0 && job != null && job.hasTarget()) {
            var rd = job.target.r + r;
            rot = Math.atan2(job.target.y - y, job.target.x - x);

            if (distance(job.target) < rd * rd) {
                job.arrived();
                speed = 0;
            }
        } else {
            rot += (Math.random() - 0.5) * Math.random() * 2;
        }

        if (wanderTime > 0)
            --wanderTime;

        var xt = x + Math.cos(rot) * speed * 0.4;
        var yt = y + Math.sin(rot) * speed * 0.4;

        // If we can't move to the designated space, let the job know that we've
        // collided with something, and do a brief random walk to get around the
        // obstacle
        if (island.isFree(xt, yt, r, this)) {
            x = xt;
            y = yt;
        } else {
            if (job != null) {
                var collided = island.getEntityAt(xt, yt, r, null, this);
                if (collided != null) {
                    job.collide(collided);
                } else {
                    job.cantReach();
                }
            }
            rot = Math.random() * 2 * Math.PI;
            wanderTime = Std.int(Math.random() * 30) + 3;
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

    function set_job(job:Job):Job {
        this.job = job;
        if (job != null)
            job.init(island, this);
        return job;
    }
}
