package objects;

// THANK YOU FLIXEL FOR OPEN SOURCING YOURSELF
// MOST IDEAS TAKEN FROM HERE: https://github.com/HaxeFlixel/flixel/blob/master/flixel/ui/FlxButton.hx

class FreeplayCategory extends FlxSprite
{
    var _categoryText:FlxSprite = null;

    function updateTextPos():Void
    {
        if (_categoryText != null)
            _categoryText.setPosition(x + (width/2 - _categoryText.width / 2), y + height - _categoryText.height * 0.85);
    }

    @:noCompletion
    override function set_x(value:Float):Float
    {
        updateTextPos();
        return x = value;
    }

    @:noCompletion
    override function set_y(value:Float):Float
    {
        updateTextPos();
        return y = value;
    }

    @:noCompletion
	override function set_alpha(Alpha:Float):Float
	{
        if (_categoryText != null)
            _categoryText.alpha = Alpha;
        return super.set_alpha(Alpha);
	}

    override public function new(name:String)
    {
        super();
        loadGraphic(Paths.image('freeplaymenu/' + name));

        if (graphic == null)
            makeGraphic(350, 600, FlxColor.BLACK);
        else
        {
            _categoryText = new FlxSprite().loadGraphic(Paths.image('freeplaymenu/texts/' + name));
            _categoryText.setGraphicSize(Std.int(_categoryText.width * 0.7));
            _categoryText.updateHitbox();
            _categoryText.active = false;
            _categoryText.moves = false;
        }
    }

    override public function draw():Void
    {
        super.draw();
        if (visible && _categoryText != null)
            _categoryText.draw();
    }
}