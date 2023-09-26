package objects;

import flixel.util.FlxSpriteUtil;
import flixel.group.FlxSpriteGroup;

class CreditsTextBox extends FlxSpriteGroup
{
    public var links:FlxTypedSpriteGroup<SocialMediaIcon>;
    public var isVisible(default, null):Bool = false;

    var defaultY:Float;

    var box:FlxSprite;

    var name:FlxText;
    var role:FlxText;
    var description:FlxText;

    var tween:FlxTweenManager;

    public var roleColor(default, set):FlxColor;
    function set_roleColor(color:FlxColor):FlxColor
    {
        if (role != null)
            role.color = color;

        return roleColor = color;
    }

    public function updateText(nameText:String, roleText:String, descriptionText:String):Void
    {
        if (!isVisible || name == null || role == null || descriptionText == null)
            return;

        name.text = nameText;
        description.text = descriptionText;

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

        description = new FlxText(name.x, name.y + 70, 980, "look who's looking thru source code!", 27);
        description.color = FlxColor.WHITE;

        links = new FlxTypedSpriteGroup<SocialMediaIcon>(box.width - 126, 20);
        links.group.active = false;
        links.active = false;

        super(FlxG.width / 2 - (box.width / 2), defaultY);

        group.alive = false;
        moves = false;

        add(box);
        add(name);
        add(role);
        add(description);
        add(links);
    }

    public function tweenText():FlxTween
    {
        if (!isVisible)
            return null;

        name.alpha = role.alpha = 0;
        name.visible = role.visible = true;

        name.y = defaultY + 20;

        return tween.tween(name, {alpha:1, y: defaultY + 25}, 0.23, {
            ease: FlxEase.quadInOut,
            onUpdate: (twn:FlxTween) -> {
                role.y = name.y + name.size - 25;
                role.alpha = name.alpha;
            },
            startDelay: 0.02
        });
    }

    public function tweenIcons():FlxTween
    {
        if (!isVisible)
            return null;

        links.alpha = description.alpha = 0;
        links.visible = description.visible = true;

        links.y = defaultY + 15;

        return tween.tween(links, {alpha:1, y: defaultY + 20}, 0.23, {
            ease: FlxEase.quadInOut,
            onUpdate: (twn:FlxTween) -> {
                description.y = links.y + 70;
                description.alpha = links.alpha;
            },
            startDelay: 0.02
        });
    }

    public function show():Void
    {
        isVisible = true;

        if (tween != null)
            tween.clear();

        box.alpha = name.alpha = role.alpha = 0;
        box.visible = true;
        box.y = defaultY - 5;

        tween.tween(box, {y: defaultY, alpha: 0.5}, 0.3, {
            ease: FlxEase.quadInOut,
        }).then(tweenText()).then(tweenIcons());
    }

    public function hide():Void
    {
        if (!isVisible) return;
        isVisible = false;

        if (tween != null)
            tween.clear();

        tween.tween(box, {y: defaultY - 5, alpha: 0}, 0.3, {
            ease: FlxEase.quadInOut,
        });
        tween.tween(name, {alpha:0, y: defaultY - 20}, 0.3, {
            ease: FlxEase.quadInOut,
            onUpdate: (twn:FlxTween) -> {
                role.y = name.y + name.size - 25;
                links.y = name.y + 5;
                description.y = name.y + 70;

                role.alpha = description.alpha = links.alpha = name.alpha;
            },
            onComplete: (twn:FlxTween) -> {
                box.visible = name.visible = role.visible = links.visible = description.visible = false;
            }
        });
    }

    public function reloadIcons(iconLinks:Array<String>)
    {
        if (!isVisible)
            return;

        links.group.kill();
    
        for (i => link in iconLinks)
        {
            var curLink:SocialMediaIcon = addLink(link);

            curLink.setPosition(links.x + i%2 * 58, links.y + Math.floor(i/2)*58);
            if (i == iconLinks.length-1 && (iconLinks.length-1)%2 == 0)
                curLink.x += 58;
        }
    }

    function addLink(link:String):SocialMediaIcon {
        var icon:SocialMediaIcon = links.recycle(SocialMediaIcon);
        icon.setup(link);
        links.add(icon);
        return icon;
    }

    override function update(elapsed:Float)
    {
        tween.update(elapsed);
        links.group.update(elapsed);
    }
}