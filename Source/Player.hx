package;

import openfl.display.Sprite;

class Player extends Sprite
{
    public var index(default, null): Int;
    public var boundingBoxes(default, null): Array<Rect>;
    public var boardSize(default, set): Vec2;
    public var boundsThickness(default, set): Float;

    private var _totalPlayers: Int;

    public function new(playerIndex:Int, totalPlayerCount:Int)
    {
        super();
        index = playerIndex;
        _totalPlayers = totalPlayerCount;
        boardSize = new Vec2(1, 1);
        boundsThickness = 10;
    }

    public function set_boardSize(size: Vec2): Vec2
    {
        boardSize = size;
        updateBounds();
        return boardSize;
    }

    public function set_boundsThickness(thickness: Float): Float
    {
        boundsThickness = thickness;
        updateBounds();
        return boundsThickness;
    }

    private function updateBounds(): Void
    {
        var totalPerimeter = boardSize.x * 2 + boardSize.y * 2;

        var playerPerimeterStart = (index / _totalPlayers) * totalPerimeter;
        var playerPerimeterEnd = ((index + 1) / _totalPlayers) * totalPerimeter;

        var incriments =
        [
            new Vec2(0, boardSize.y * 0.5),
            new Vec2(0, 0),
            new Vec2(boardSize.x, 0),
            new Vec2(boardSize.x, boardSize.y),
            new Vec2(0, boardSize.y),
            new Vec2(0, boardSize.y * 0.5),
        ];

        var total = 0;
        for (i in 0...incriments.length)
        {
        }
    }
}
