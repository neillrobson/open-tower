package;

import Resources.Resource;

class Job {
    var island:Island;
    var peon:Peon;

    public var target:Entity;

    public function init(island:Island, peon:Peon) {
        this.island = island;
        this.peon = peon;
    }

    public function isValidTarget(e:Entity):Bool {
        return false;
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

    public function new(resource:Resource, returnTo:House) {
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
                target = returnTo;
                peon.rot += Math.PI;
            } else if (hasResource && target.acceptsResource(resource)
                && target.submitResource(resource)) {
                hasResource = false;
                target = null;
                island.resources.add(resource, 1);
                peon.job = null;
            }
        }
    }
}
