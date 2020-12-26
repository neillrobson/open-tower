package event;

import Resources.Resource;
import openfl.events.EventType;
import openfl.events.Event;

class JobEvent extends Event {
    public static inline final CHANGE_CARRIED:EventType<JobEvent> = "changeCarried";

    public final carried:Resource;

    public function new(type:EventType<JobEvent>, carried:Resource, bubbles:Bool = false,
            cancelable:Bool = false) {
        super(type, bubbles, cancelable);

        this.carried = carried;
    }

    public override function clone():Event {
        return new JobEvent(type, carried, bubbles, cancelable);
    }

    public override function toString():String {
        return __formatToString("JobEvent", ["type", "carried", "bubbles", "cancelable"]);
    }
}
