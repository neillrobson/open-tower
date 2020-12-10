package;

import openfl.Lib;
import openfl.text.TextField;
import openfl.events.Event;
import openfl.text.TextFormat;
import openfl.system.System;
import haxe.Timer;

class InfoDebug extends TextField {
    private var memPeak:Float = 0;
    private var timer:Int = 4;
    private var times:Array<Float>;

    public var tL:Int = 60;

    public function new(inCol:Int = 16777215) {
        super();
        times = [];
        selectable = false;
        defaultTextFormat = new TextFormat("_sans", 15, inCol);
        width = 150 * 4;
        height = 70;
        y = Lib.current.stage.stageHeight - 20;
        Lib.current.addChild(this);
        addEventListener(Event.ENTER_FRAME, this_onEnterFrame);
    }

    @:noCompletion private function this_onEnterFrame(event:Event):Void {
        x = 0;
        y = Lib.current.stage.stageHeight - 20;
        if (timer == 0) {
            timer = 4;
            var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
            if (mem > memPeak)
                memPeak = mem;
            // elasped
            // GET framerate
            var now = Timer.stamp();
            times.push(now);

            while (times[0] < now - 1)
                times.shift();
            tL = times.length * timer;

            text = "fps " + tL + " el " + Math.round((tL / Lib.current.stage.frameRate) * 10) / 10 + " mem " + mem + "  mx " + memPeak;
        }
        timer += -1;
    }
}
