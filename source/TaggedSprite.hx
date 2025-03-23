package;

import flixel.FlxSprite;

class TaggedSprite extends FlxSprite
{
    public var tag:String;
    public var canBeHit:Bool;
    public var strumTime:Float; 
    
    public function new(x:Float, y:Float, strumTime:Float)
    {
        super(x, y);
        tag = "";
        this.strumTime = strumTime;
        canBeHit = false;
    }
}
