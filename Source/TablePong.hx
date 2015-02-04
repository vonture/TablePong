package;

import openfl.display.Sprite;
import openfl.display.FPS;
import flash.events.Event;

class TablePong extends Sprite
{
    public function new()
    {
        super();

        _board = new Board(stage.stageWidth, stage.stageHeight);
        addChild(_board);

        _fps = new FPS();
        addChild(_fps);

        stage.frameRate = 60;

        stage.addEventListener(Event.RESIZE, onStageResize);
    }

    private function onStageResize(event:Event):Void
    {
        _board.setSize(stage.stageWidth, stage.stageHeight);
    }

    private var _board:Board;
    private var _fps:FPS;
}