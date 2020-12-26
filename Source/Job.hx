package;

import event.JobEvent;
import openfl.events.EventDispatcher;
import Resources.Resource;

class Job extends EventDispatcher {
    static inline final BASE_BORE_TIME = 16 * Main.TICKS_PER_SECOND;

    var island:Island;
    var peon:Peon;
    var boreTime:Int = BASE_BORE_TIME;

    public var target:Entity;

    public function new(island:Island, peon:Peon) {
        super();

        this.island = island;
        this.peon = peon;
    }

    public function isValidTarget(e:Entity):Bool {
        return false;
    }

    public function update() {
        if (boreTime > 0 && --boreTime == 0)
            peon.job = null;
    }

    public function arrived() {
        peon.job = null;
    }

    /**
        Do a limited target search and return true if a target either already
        exists or has been found by the search.
    **/
    public function hasTarget():Bool {
        var e = peon.getRandomTarget(5, 60, isValidTarget);
        if (e != null && isValidTarget(e)) {
            if (target == null || e.distance(peon) < target.distance(peon)) {
                target = e;
            }
        }
        if (target != null && !target.alive)
            target = null;
        return target != null;
    }

    public function collide(e:Entity) {
        if (isValidTarget(e)) {
            target = e;
        } else {
            cantReach();
        }
    }

    public function cantReach() {}
}

class Gather extends Job {
    var hasResource = false;
    var resource:Resource;
    var returnTo:House;

    public function new(island:Island, peon:Peon, resource:Resource, returnTo:House) {
        super(island, peon);
        this.resource = resource;
        this.returnTo = returnTo;
    }

    override function isValidTarget(e:Entity):Bool {
        if (!hasResource && e.givesResource(resource))
            return true;
        if (hasResource && e.acceptsResource(resource))
            return true;
        return false;
    }

    override function arrived() {
        if (target != null) {
            if (!hasResource && target.givesResource(resource) && target.gatherResource(resource)) {
                hasResource = true;
                dispatchEvent(new JobEvent(JobEvent.CHANGE_CARRIED, resource));
                target = returnTo;
                peon.rot += Math.PI;
                boreTime = 2 * Job.BASE_BORE_TIME;
            } else if (hasResource && target.acceptsResource(resource)
                && target.submitResource(resource)) {
                hasResource = false;
                dispatchEvent(new JobEvent(JobEvent.CHANGE_CARRIED, null));
                target = null;
                island.resources.add(resource, 1);
                peon.job = null;
            }
        }
    }
}

class Build extends Job {
    public function new(island:Island, peon:Peon, target:House) {
        super(island, peon);
        this.target = target;
    }

    override function isValidTarget(e:Entity):Bool {
        return e == target;
    }

    override function arrived() {
        if ((cast target).build())
            peon.job = null;
    }
}

class Goto extends Job {
    public function new(island:Island, peon:Peon, target:Entity) {
        super(island, peon);
        this.target = target;
    }

    override function isValidTarget(e:Entity):Bool {
        return e == target;
    }
}
