package;

import openfl.display.Sprite;
import flash.events.Event;
import haxe.Timer;

class Line extends Sprite
{
    public var position(get,set):Vec2;
    public var extent(default,set):Vec2;
    public var radius(default,set):Float;

    private var _finalized:Bool;
    private var _timer:Float;
    private var _fadeStart:Float;

    private var _lastUpdate:Float;

    public function new()
    {
        super();

        extent = new Vec2(0, 0);
        radius = 1;

        _finalized = false;
        _timer = 0;
        _fadeStart = 0;

        _lastUpdate = haxe.Timer.stamp();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    public function set_position(pos:Vec2)
    {
        x = pos.x;
        y = pos.y;
        draw();
        return pos;
    }

    public function get_position():Vec2
    {
        return new Vec2(x, y);
    }

    public function set_extent(ext:Vec2)
    {
        extent = ext;
        draw();
        return extent;
    }

    public function set_radius(rad:Float)
    {
        radius = rad;
        draw();
        return radius;
    }

    public function finalize(duration:Float):Void
    {
        _finalized = true;
        _timer = duration;
        _fadeStart = Math.min(duration, 1.0);

        draw();
    }

    public function finished():Bool
    {
        return _finalized && _timer < 0;
    }

    private function draw():Void
    {
        var alpha = 0.0;
        if (_finalized)
        {
            if (_timer < _fadeStart)
            {
                alpha = Math.max(_timer, 0) / _fadeStart;
            }
            else
            {
                alpha = 1.0;
            }
        }
        else
        {
            alpha = 0.5;
        }

        graphics.clear();
        graphics.beginFill(0xFF0000, alpha);
        graphics.lineStyle(radius * 2, 0xFF0000, alpha);

        graphics.moveTo(0, 0);
        graphics.lineTo(extent.x, extent.y);

        graphics.endFill();
    }

    private function onAddedToStage(event:Event):Void
    {
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        draw();
    }

    private function onEnterFrame(event:Event):Void
    {
        var curTime = haxe.Timer.stamp();
        var dt = curTime - _lastUpdate;
        _lastUpdate = curTime;

        _timer -= dt;

        draw();
    }
}