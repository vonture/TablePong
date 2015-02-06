package;

import openfl.display.Sprite;
import flash.events.Event;

class Ball extends Sprite
{
    public var radius(default,set):Float;

    public var position(get,set):Vec2;
    public var velocity(default,default):Vec2;

    private var _color: Int;

    public function new()
    {
        super();

        radius = 5;

        _color = 0x54F226;

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

    public function set_radius(rad:Float)
    {
        radius = rad;
        draw();
        return radius;
    }

    private function draw():Void
    {
        graphics.clear();
        graphics.beginFill(_color);
        graphics.drawCircle(0, 0, radius);
        graphics.endFill();
    }

    private function onAddedToStage(event:Event):Void
    {
        draw();
    }
}
