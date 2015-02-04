package;

import flash.geom.Matrix;

class Vec2
{
    public var x: Float;
    public var y: Float;
    public var length(get, set): Float;
    public var lengthSquared(get, null): Float;
    public var angle(get, set): Float;

    public function new (x:Float = 0, y:Float = 0)
    {
        this.x = x;
        this.y = y;
    }

    public inline function set(x:Float, y:Float)
    {
        this.x = x;
        this.y = y;
    }

    public inline function get_length(): Float
    {
        return Math.sqrt(lengthSquared);
    }

    public inline function set_length(v: Float): Float
    {
        var l = length;
        if (l == 0)
        {
            x = v;
        }
        else
        {
            x *= (v/l);
            y *= (v/l);
        }
        return v;
    }

    public inline function get_lengthSquared(): Float
    {
        return x*x + y*y;
    }

    public function get_angle(): Float
    {
        if (x == 0 && y == 0)
        {
            return 0.0;
        }
        return (2*Math.PI + Math.atan2(y, x)) % (2*Math.PI);
    }

    public function set_angle(v: Float): Float
    {
        var l = this.length;
        x = l*Math.cos(v);
        y = l*Math.sin(v);
        return v;
    }

    public static inline function normalize(a: Vec2, to: Float = 1.0): Vec2
    {
        var d = a.length;
        if (d > 0)
        {
            return mulScalar(a, to/d);
        }
        else
        {
            return a.copy();
        }
    }

    public static inline function negate(a: Vec2)
    {
        return new Vec2(-a.x, -a.y);
    }

    public static inline function mulScalar(a: Vec2, scalar: Float)
    {
        return new Vec2(a.x * scalar, a.y * scalar);
    }

    public static inline function mul(a: Vec2, b: Vec2)
    {
        return new Vec2(a.x * a.y, a.y * b.y);
    }

    public static inline function dot(a: Vec2, b: Vec2): Float
    {
        return a.x*b.x + a.y*b.y;
    }

    public static inline function lerp(a: Vec2, b: Vec2, t: Float): Vec2
    {
        return new Vec2(a.x + t * (b.x - a.x), a.y + t * (b.y - a.y));
    }

    public inline function copy(): Vec2
    {
        return new Vec2(x, y);
    }

    public inline function equals(o: Vec2): Bool
    {
        return x == o.x && y == o.y;
    }

    public inline function toString(): String
    {
        return "Vec2(" + x + "," + y + ")";
    }

    public inline function rotate(angle: Float)
    {
        var cs = Math.cos(angle);
        var sn = Math.sin(angle);
        var tmp = (x*cs - y*sn);
        y = (x*sn + y*cs);
        x = tmp;
    }

    public static inline function add(a: Vec2, b: Vec2)
    {
        return new Vec2(a.x + b.x, a.y + b.y);
    }

    public static inline function sub(a: Vec2, b: Vec2)
    {
        return new Vec2(a.x - b.x, a.y - b.y);
    }

    public static inline function cross(a: Vec2, b: Vec2): Float
    {
        return b.y*a.x - b.x*a.y;
    }

    public static inline function distance(a: Vec2, b: Vec2): Float
    {
        return sub(a, b).length;
    }

    public static inline function distanceSquared(a: Vec2, b: Vec2): Float
    {
        return sub(a, b).lengthSquared;
    }

    public static inline function anglebetween(a: Vec2, b: Vec2): Float
    {
        return Math.acos(dot(a, b)/(a.length*b.length));
    }

    // Reflect @v in plane whose normal is @plane.
    // Both V and V' are pointing outwards: V' = 2N.(V.N) - V
    // For in/out: V' = V - 2N(VN)
    public static inline function reflect(a: Vec2, plane: Vec2)
    {
        var nn = mulScalar(plane, 2*dot(a, plane));
        return new Vec2(nn.x - a.x, nn.y - a.y);
    }

    public inline function transform(m: Matrix)
    {
        x = x * m.a + y * m.c + m.tx;
        y = x * m.b + y * m.d + m.ty;
    }

    public inline function normal(): Vec2
    {
        return new Vec2(-y, x);
    }
}