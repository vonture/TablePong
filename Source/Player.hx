package;

import openfl.display.Sprite;

class Player extends Sprite
{
    public var index(default, null): Int;
    public var boundingBoxes(default, null): Array<Rect>;
    public var boardSize(default, set): Vec2;
    public var boundsThickness(default, set): Float;

    private var _totalPlayers: Int;
    private var _color: Int;

    public function new(playerIndex:Int, totalPlayerCount:Int)
    {
        super();

        var colors =
        [
            0xFF0000,
            0xFFFF00,
            0xFF00FF,
            0x00FF00,
            0x00FFFF,
            0x0000FF,
        ];
        _color = colors[playerIndex];

        index = playerIndex;
        boardSize = new Vec2(0, 0);
        boundsThickness = 10;
        _totalPlayers = totalPlayerCount;
    }

    public function set_boardSize(size: Vec2): Vec2
    {
        if (boardSize != size)
        {
            boardSize = size;
            updateBounds();
        }
        return boardSize;
    }

    public function set_boundsThickness(thickness: Float): Float
    {
        if (boundsThickness != thickness)
        {
            boundsThickness = thickness;
            updateBounds();
        }
        return boundsThickness;
    }

    private function draw():Void
    {
        graphics.clear();

        graphics.beginFill(_color, alpha);

        for (i in 0...boundingBoxes.length)
        {
            var box = boundingBoxes[i];
            graphics.drawRect(box.position.x, box.position.y, box.size.x, box.size.y);
        }

        graphics.endFill();
    }

    private function updateBounds(): Void
    {
        boundingBoxes = new Array<Rect>();

        if (boardSize == null || boardSize.x == 0 || boardSize.y == 0 ||
            boundsThickness == Math.NaN)
        {
            return;
        }

        var totalPerimeter = boardSize.x * 2 + boardSize.y * 2;

        var playerPerimeterStart = (index / _totalPlayers) * totalPerimeter;
        var playerPerimeterEnd = ((index + 1) / _totalPlayers) * totalPerimeter;

        var edges =
        [
            new Vec2(0, boardSize.y * 0.5),
            new Vec2(0, 0),
            new Vec2(boardSize.x, 0),
            new Vec2(boardSize.x, boardSize.y),
            new Vec2(0, boardSize.y),
            new Vec2(0, boardSize.y * 0.5),
        ];

        var total = 0.0;
        for (i in 0...(edges.length - 1))
        {
            var edge = Vec2.sub(edges[i+1], edges[i]);

            var startDist = total;
            var endDist = startDist + edge.length;
            total += edge.length;

            if (playerPerimeterStart > endDist)
            {
                continue;
            }
            if (playerPerimeterEnd < startDist)
            {
                break;
            }

            var dir = Vec2.normalize(edge);

            var startOffset = Math.max(playerPerimeterStart - startDist, 0);
            var endOffset = Math.min(playerPerimeterEnd - startDist, edge.length);

            var startPt = Vec2.add(edges[i], Vec2.mulScalar(dir, startOffset));
            var endPt = Vec2.add(edges[i], Vec2.mulScalar(dir, endOffset));

            if (edge.x == 0)
            {
                // vertical
                var pos = new Vec2(startPt.x - boundsThickness, Math.min(startPt.y, endPt.y));
                var size = new Vec2(boundsThickness * 2, Math.abs(startPt.y - endPt.y));
                boundingBoxes.push(new Rect(pos, size));
            }
            else
            {
                // horizontal
                var pos = new Vec2(Math.min(startPt.x, endPt.x), startPt.y - boundsThickness);
                var size = new Vec2(Math.abs(startPt.x - endPt.x), boundsThickness * 2);
                boundingBoxes.push(new Rect(pos, size));
            }
        }

        draw();
    }
}
