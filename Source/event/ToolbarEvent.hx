package event;

import openfl.events.EventType;
import openfl.events.Event;

class ToolbarEvent extends Event {
    public static inline final HOUSE_SELECT:EventType<ToolbarEvent> = "houseSelect";

    public final selection:Int;

    public function new(type:EventType<ToolbarEvent>, selection:Int, bubbles:Bool = false, cancelable:Bool = false) {
        super(type, bubbles, cancelable);

        this.selection = selection;
    }

    public override function clone():Event {
        return new ToolbarEvent(type, selection, bubbles, cancelable);
    }

    public override function toString():String {
        return __formatToString("ToolbarEvent", ["type", "selection", "bubbles", "cancelable"]);
    }
}
