package;

import openfl.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

typedef LineBallCollision =
{
    var hit : Bool;
    var normal : Vec2;
};

class Board extends Sprite
{
    public function new(playerCount:Int, width:Float, height:Float)
    {
        super();
        mouseChildren = false;

        _players = new Array<Player>();
        for (i in 0...playerCount)
        {
            var player = new Player(i, playerCount);
            _players.push(player);
            addChild(player);
        }

        _balls = new Array<Ball>();

        var ball = new Ball();
        ball.radius = 30;
        ball.position = new Vec2(500, 500);
        ball.velocity = new Vec2(300, 300);
        _balls.push(ball);
        addChild(ball);

        _lines = new Array<Line>();

        _touches = new Map<Int, Line>();

        _lastUpdate = haxe.Timer.stamp();

        setSize(width, height);

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        if (Multitouch.supportsTouchEvents)
        {
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        }
        else
        {
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
    }

    public function setSize(width:Float, height:Float)
    {
        if (width == _width && height == _height)
        {
            return;
        }

        _width = width;
        _height = height;
        graphics.clear();
        graphics.beginFill(0, 0.0);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();

        for (i in 0..._players.length)
        {
            _players[i].boardSize = new Vec2(width, height);
            _players[i].boundsThickness = 10;
        }
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

    private static function checkBallBoxCollision(ball: Ball, box: Rect): Bool
    {
        var circleDist = Vec2.abs(Vec2.sub(ball.position, box.position));

        if (circleDist.x > (box.size.x * 0.5 + ball.radius) ||
            circleDist.y > (box.size.y * 0.5 + ball.radius))
        {
            return false;
        }

        if (circleDist.x <= (box.size.x * 0.5 ) ||
            circleDist.y <= (box.size.y * 0.5))
        {
            return true;
        }

        var cornerDist = Vec2.distance(circleDist, Vec2.mulScalar(box.size, 0.5));
        return cornerDist <= ball.radius;
    }

    private function onEnterFrame(event:Event):Void
    {
        var curTime = haxe.Timer.stamp();
        var dt = curTime - _lastUpdate;
        _lastUpdate = curTime;

        // Remove timed out lines
        var i = 0;
        while (i < _lines.length)
        {
            var line = _lines[i];
            if (line.finished())
            {
                _lines.remove(line);
            }
            i++;
        }

        var i = 0;
        while (i < _balls.length)
        {
            var ball = _balls[i];

            // Collide against lines
            var j = 0;
            while (j < _lines.length)
            {
                var line = _lines[j];

                // Bounce balls off this line if they're coliding and going
                // towards the line
                var collision = checkLineBallCollision(ball, line);
                if (collision.hit && Vec2.dot(collision.normal, ball.velocity) < 0)
                {
                    ball.velocity = Vec2.negate(Vec2.reflect(ball.velocity, collision.normal));

                    // Increase the ball speed after each bounce
                    ball.velocity = Vec2.mulScalar(ball.velocity, _ballBoundSpeedMult);

                    removeChild(line);
                    _lines.remove(line);
                }
                else
                {
                    j++;
                }
            }

            // Collide against player bounds
            for (j in 0..._players.length)
            {
                var player = _players[j];
                for (k in 0...player.boundingBoxes.length)
                {
                    var box = player.boundingBoxes[k];
                    if (checkBallBoxCollision(ball, box))
                    {
                        trace("hit");
                    }
                }
            }

            // Bounce ball off the wall
            if (ball.position.x < ball.radius)
            {
                ball.velocity.x = Math.abs(ball.velocity.x);
            }
            else if (ball.position.x > _width - ball.radius)
            {
                ball.velocity.x = -Math.abs(ball.velocity.x);
            }

            if (ball.position.y < ball.radius)
            {
                ball.velocity.y = Math.abs(ball.velocity.y);
            }
            else if (ball.position.y > _height - ball.radius)
            {
                ball.velocity.y = -Math.abs(ball.velocity.y);
            }

            // Update position from velocity
            ball.position = Vec2.add(ball.position, Vec2.mulScalar(ball.velocity, dt));

            i++;
        }
    }

    private function onMouseDown(event:MouseEvent):Void
    {
        onInputBegin(-1, new Vec2(event.stageX, event.stageY));
    }

    private function onMouseMove(event:MouseEvent):Void
    {
        onInputMove(-1, new Vec2(event.stageX, event.stageY));
    }

    private function onMouseUp(event:MouseEvent):Void
    {
        onInputEnd(-1, new Vec2(event.stageX, event.stageY));
    }

    private function onTouchBegin(event:TouchEvent):Void
    {
        onInputBegin(event.touchPointID, new Vec2(event.stageX, event.stageY));
    }

    private function onTouchMove(event:TouchEvent):Void
    {
        onInputMove(event.touchPointID, new Vec2(event.stageX, event.stageY));
    }

    private function onTouchEnd(event:TouchEvent):Void
    {
        onInputEnd(event.touchPointID, new Vec2(event.stageX, event.stageY));
    }

    private function onInputBegin(id:Int, pos:Vec2)
    {
        if (_touches.exists(id))
        {
            return;
        }

        var line = new Line();
        line.radius = 15;
        line.position = pos.copy();
        line.extent = new Vec2(0, 0);
        _touches.set(id, line);
        addChild(line);
    }

    private function onInputMove(id:Int, pos:Vec2)
    {
        if (!_touches.exists(id))
        {
            return;
        }

        var line = _touches.get(id);
        line.extent = Vec2.sub(pos, line.position);
    }

    private function onInputEnd(id:Int, pos:Vec2)
    {
        if (!_touches.exists(id))
        {
            return;
        }

        var line = _touches.get(id);
        line.extent = Vec2.sub(pos, line.position);
        line.finalize(5);
        _lines.push(line);
        _touches.remove(id);
    }

    private static var _ballBoundSpeedMult:Float = 1.1;

    private var _width:Float;
    private var _height:Float;

    private var _players: Array<Player>;

    private var _balls:Array<Ball>;
    private var _lines:Array<Line>;

    private var _touches:Map<Int, Line>;

    private var _lastUpdate:Float;
}
