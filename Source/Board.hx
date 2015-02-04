package;

import openfl.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Vector;

typedef LineBallCollision =
{
    var hit : Bool;
    var normal : Vec2;
};

class Board extends Sprite
{
    public function new(width:Float, height:Float)
    {
        super();

        _ball = new Ball();
        _ball.radius = 30;
        _ball.position = new Vec2(_width * 0.5, _height * 0.5);
        _ball.velocity = new Vec2(300, 300);

        addChild(_ball);

        _lines = new Vector<Line>();

        var line = new Line();
        line.radius = 15;
        line.position = new Vec2(900, 350);
        line.extent = new Vec2(150, 150);
        line.finalize(30);
        _lines.push(line);
        addChild(line);

        _lastUpdate = haxe.Timer.stamp();

        _background = new Sprite();
        _background.mouseChildren = false;
        addChild(_background);

        setSize(width, height);

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        _background.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    }

    public function setSize(width:Float, height:Float)
    {
        _width = width;
        _height = height;
        _background.graphics.clear();
        _background.graphics.beginFill(0, 0.0);
        _background.graphics.drawRect(0, 0, width, height);
        _background.graphics.endFill();
    }

    private function onAddedToStage(event:Event):Void
    {
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private static function checkLineBallCollision(ball:Ball, line:Line):LineBallCollision
    {
        // Compute the closest pont on the line and it's distance to the ball
        var a = line.position;
        var b = Vec2.add(line.position, line.extent);
        var p = ball.position;

        var lineLenSq = Vec2.distanceSquared(a, b);
        if (lineLenSq == 0)
        {
            // v == w, bad line.
            return { hit: false, normal: new Vec2() };
        }

        var t = Vec2.dot(Vec2.sub(p, a), Vec2.sub(b, a)) / lineLenSq;
        var closest = new Vec2();
        if (t < 0)
        {
            closest = a.copy();
        }
        else if (t > 1)
        {
            closest = b.copy();
        }
        else
        {
            closest = Vec2.lerp(a, b, t);
        }

        var dist = Vec2.distance(closest, p);
        if (dist < ball.radius + line.radius)
        {
            return { hit: true, normal: Vec2.normalize(Vec2.sub(p, closest)) };
        }
        else
        {
            return { hit: false, normal: new Vec2() };
        }
    }

    private function onEnterFrame(event:Event):Void
    {
        var curTime = haxe.Timer.stamp();
        var dt = curTime - _lastUpdate;
        _lastUpdate = curTime;

        var i = 0;
        while (i < _lines.length)
        {
            if (_lines[i].finished())
            {
                removeChild(_lines[i]);
                _lines.splice(i, 1);
            }
            else
            {
                var line = _lines[i];

                // Bounce balls off this line
                var collision = checkLineBallCollision(_ball, line);
                if (collision.hit && Vec2.dot(collision.normal, _ball.velocity) < 0)
                {
                    _ball.velocity = Vec2.negate(Vec2.reflect(_ball.velocity, collision.normal));
                }

                i++;
            }
        }

        // Bounce ball off the wall
        if (_ball.position.x < _ball.radius)
        {
            _ball.velocity.x = Math.abs(_ball.velocity.x);
        }
        else if (_ball.position.x > _width - _ball.radius)
        {
            _ball.velocity.x = -Math.abs(_ball.velocity.x);
        }

        if (_ball.position.y < _ball.radius)
        {
            _ball.velocity.y = Math.abs(_ball.velocity.y);
        }
        else if (_ball.position.y > _height - _ball.radius)
        {
            _ball.velocity.y = -Math.abs(_ball.velocity.y);
        }

        _ball.position = Vec2.add(_ball.position, Vec2.mulScalar(_ball.velocity, dt));
    }

    private function onMouseMove(event:MouseEvent):Void
    {
        //_ball.x = event.stageX;
       // _ball.y = event.stageY;
    }

    private var _width:Float;
    private var _height:Float;

    private var _ball:Ball;
    private var _lines:Vector<Line>;

    private var _lastUpdate:Float;
    private var _background:Sprite;
}