package objects;

import flixel.util.FlxSpriteUtil;
import flixel.group.FlxSpriteGroup;

class CreditsTextBox extends FlxSpriteGroup
{
    public var isVisible:Bool = false;

    var defaultY:Float;

    var box:FlxSprite;

    var name:FlxText;
    var role:FlxText;

    var tween:FlxTweenManager;

    public var roleColor(default, set):FlxColor;
    function set_roleColor(color:FlxColor):FlxColor
    {
        if (role != null)
            role.color = color;

        return roleColor = color;
    }

    public function updateText(nameText:String, roleText:String):Void
    {
        if (!isVisible || name == null || role == null)
        {
            return;
        }

        name.text = nameText;

        role.text = roleText;
        role.x = name.x + name.fieldWidth + 5;
    }

    public function new(y:Float)
    {
        tween = new FlxTweenManager();

        box = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(1150, 250, FlxColor.TRANSPARENT), 0, 0, 1150, 250, 50, 50, FlxColor.BLACK);
        box.alpha = 0.5;
        box.antialiasing = ClientPrefs.data.antialiasing;
        defaultY = y - box.height / 2;

        name = new FlxText(25, 20, 0, "cock", 40);

        role = new FlxText(name.x + name.fieldWidth + 5, name.y + name.size - 25, 0, "coder", 25);
        roleColor = FlxColor.RED;

        super(FlxG.width / 2 - (box.width / 2), defaultY);

        group.alive = false;
        moves = false;

        add(box);
        add(name);
        add(role);
    }

    public function tweenText():FlxTween
    {
        if (!isVisible) return null;

        name.alpha = 0;
        name.visible = true;
        name.y = defaultY + 20;

        role.alpha = 0;
        role.visible = true;

        return tween.tween(name, {alpha:1, y: defaultY + 25}, 0.23, {
            ease: FlxEase.quadInOut,
            onUpdate: (twn:FlxTween) -> {
                role.y = name.y + name.size - 25;
                role.alpha = name.alpha;
            },
            startDelay: 0.02
        });
    }

    public function show():Void
    {
        isVisible = true;

        if (tween != null)
            tween.clear();

        box.visible = true;
        box.alpha = 0;
        box.y = defaultY - 5;

        name.alpha = 0;
        role.alpha = 0;

        tween.tween(box, {y: defaultY, alpha: 0.5}, 0.3, {
            ease: FlxEase.quadInOut,
        }).then(tweenText());
    }

    public function hide():Void
    {
        if (!isVisible) return;
        isVisible = false;

        if (tween != null)
            tween.clear();

        tween.tween(box, {y: defaultY - 5, alpha: 0}, 0.3, {
            ease: FlxEase.quadInOut
        });
        tween.tween(name, {alpha:0, y: defaultY - 20}, 0.3, {
            ease: FlxEase.quadInOut,
            onUpdate: (twn:FlxTween) -> {
                role.y = name.y + name.size - 25;
                role.alpha = name.alpha;
            },
            onComplete: (twn:FlxTween) -> {
                box.visible = false;
                name.visible = false;
                role.visible = false;
            }
        });
    }

    override function update(elapsed:Float)
    {
        tween.update(elapsed);
    }
}