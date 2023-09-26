package states;

import flixel.FlxObject;
import haxe.Json;
import haxe.ds.IntMap;
import sys.FileSystem;
import sys.io.File;
import objects.CreditsIcon;
import objects.CreditsTextBox;

typedef IconData = {
    var name:String;
    var image:String;
    var role:String;
    var description:String;
    var links:Array<String>;
    var mainLink:Int;
    var color:String;
}

typedef CreditsFile = {
    var categoryOrder:Array<String>;
    var categoryData:Array<Array<IconData>>;
}

class CreditsStateTwo extends MusicBeatState
{
    var curIcon:CreditsIcon;

    var curSelected(default, set):Int = 0;
    function set_curSelected(val:Int)
    {
        if (iconArray.length > 0)
            curIcon = iconArray[val];
        return curSelected = val;
    }

    var curSequence(get, never):String;

    var cooldownTimer:Float = 0.3; // Since the state was just switched we don't want the player to immediately spam and stuff.
    var spamChain:Float = 0;

    var sequences:IntMap<String> = new IntMap<String>();

    @:noCompletion function get_curSequence():String {
        return sequences.get(curSelected);
    }

    var camIcons:FlxCamera;
    var camIconFollow:FlxObject;

    var bg:FlxSprite;
    var textBox:CreditsTextBox;
    var iconArray:Array<CreditsIcon> = [];
    var categoryText:Alphabet;

    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    override function create()
    {
        if(FlxG.sound.music == null) {
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        }

        for (file in FileSystem.readDirectory(Paths.getPath("images/credits/social_media")))
        {
            if (file.endsWith(".png"))
                Paths.image('credits/social_media/${file.replace(".png", "")}'); // Precaching social media icons.
        }

        camIconFollow = new FlxObject();
        add(camIconFollow);

        camIcons = new FlxCamera();
        camIcons.bgColor.alpha = 0;
        camIcons.follow(camIconFollow, LOCKON, (1 / FlxG.updateFramerate) * 9 / (FlxG.updateFramerate / 60));
        camIcons.targetOffset.set(FlxG.width/2, FlxG.height/2);

        FlxG.cameras.add(camIcons, false);

        bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
        add(bg);

        categoryText = new Alphabet(FlxG.width/2, 30, "COEDERS");
        categoryText.alignment = CENTERED;
        add(categoryText);

        textBox = new CreditsTextBox(FlxG.height / 1.25);
        textBox.roleColor = FlxColor.BLACK;
        add(textBox);

        loadCredits();

        leftArrow = new FlxSprite(15, 230);
        leftArrow.frames = Paths.getSparrowAtlas("campaign_menu_UI_assets");
        leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
        leftArrow.animation.play("idle");
        leftArrow.scrollFactor.set(0, 0);
        leftArrow.cameras = [camIcons];
        add(leftArrow);

        rightArrow = new FlxSprite(FlxG.width - 15, 230);
        rightArrow.loadGraphicFromSprite(leftArrow);
        rightArrow.x -= rightArrow.width;
        rightArrow.animation.addByPrefix('idle', "arrow right");
		rightArrow.animation.addByPrefix('press', "arrow push right");
        rightArrow.animation.play("idle");
        rightArrow.scrollFactor.set(0, 0);
        rightArrow.cameras = [camIcons];
        add(rightArrow);

        changeSelection();
        super.create();

        FlxG.mouse.visible = true;
    }

    function doIconAnim(spr:FlxSprite, alpha:Float = 0.5, scale:Float = 1)
    {
        if ((spr == null) || (spr.alpha == alpha && spr.scale.x == scale))
            return;

        FlxTween.cancelTweensOf(spr);
        FlxTween.tween(spr, {alpha:alpha, "scale.x": scale, "scale.y": scale}, 0.25, {ease:FlxEase.quadInOut});
    }

    var bgColorTwn:FlxTween;
    var prevColor:FlxColor;

    function changeSelection(by:Int=0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        doIconAnim(curIcon);
        curSelected = FlxMath.wrap(curSelected+by, 0, iconArray.length-1);

        doIconAnim(curIcon, 1, 1.3);

        camIconFollow.x = 0;
        if (curSelected > iconArray.length - 5)
            camIconFollow.x = iconArray[iconArray.length-1].x + 80 - 1150;
        else if (curSelected > 3)
            camIconFollow.x = curIcon.x - FlxG.width/2 + curIcon.width/2;

        spamChain += Math.abs(by);

        if (spamChain > 1)
            textBox.hide();
        else if (spamChain == 1)
        {
            textBox.tweenText();
            textBox.tweenIcons();
        }
        else
            textBox.show();

        textBox.updateText(curIcon.name, curIcon.role, curIcon.description);
        textBox.reloadIcons(curIcon.links);

        if (curSequence != null && curSequence != categoryText.text)
        {
            categoryText.text = curSequence;
            FlxTween.cancelTweensOf(categoryText);
            categoryText.y = 25;
            categoryText.alpha = 0;
            FlxTween.tween(categoryText, {y: 30, alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
        }

        if (curIcon.pageColor != prevColor)
        {
            if (bgColorTwn != null) 
                bgColorTwn.cancel();

            bgColorTwn = FlxTween.color(bg, 0.5, bg.color, curIcon.pageColor, {
                ease: FlxEase.quadInOut,
                onComplete: (twn:FlxTween) -> {
                    bgColorTwn = null;
                }
            });

            prevColor = curIcon.pageColor;
        }

        leftArrow.visible = (curSelected != 0);
        rightArrow.visible = (curSelected != iconArray.length-1);

        cooldownTimer = 0;
    }

    function loadCredits():Void
    {
        var creditsFile:String = Paths.json('credits');

        if (FileSystem.exists(creditsFile))
        {
            var json:CreditsFile = cast Json.parse(File.getContent(creditsFile));
            var prevSequence:String = null;

            for(i => categoryName in json.categoryOrder)
            {
                var curCategory:Array<IconData> = json.categoryData[i];
                sequences.set(iconArray.length, categoryName);

                if (prevSequence != null)
                    sequences.set(iconArray.length-1, prevSequence);
                prevSequence = categoryName;

                for (icon in curCategory)
                {
                    var icon:CreditsIcon = new CreditsIcon(icon.name, icon.image, icon.role, icon.description, icon.links, icon.mainLink, FlxColor.fromString(icon.color));
                    icon.cameras = [camIcons];
                    icon.setPosition(FlxG.width/2 + (iconArray.length - 7/2) * 160, 230 - Math.abs(iconArray.length%2-1) * 60);

                    iconArray.push(icon);
                    add(icon);
                }
            }

            sequences.set(iconArray.length-1, prevSequence);
        }
    }

    var holdTime:Float = 0;
    override function update(elapsed:Float)
    {
        cooldownTimer += elapsed;

        if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
        {
            changeSelection(controls.UI_RIGHT_P ? 1 : -1);
            (controls.UI_RIGHT_P ? rightArrow : leftArrow).animation.play('press');
            holdTime = 0;
        }

        if(controls.UI_LEFT || controls.UI_RIGHT)
        {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                changeSelection((checkNewHold - checkLastHold) * (controls.UI_LEFT ? -1 : 1));
        }

        if (controls.UI_LEFT_R || controls.UI_RIGHT_R)
			(controls.UI_RIGHT_R ? rightArrow : leftArrow).animation.play('idle');

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
            #if FREEPLAY
            MusicBeatState.switchState(new FreeplayState());
            #else
            MusicBeatState.switchState(new MainMenuState());
            #end
        }

        if (controls.ACCEPT)
            CoolUtil.browserLoad(curIcon.getMainLink());

        if (cooldownTimer >= 0.2)
        {
            spamChain = 0;

            if (!textBox.isVisible && cooldownTimer >= 0.3)
            {
                textBox.show();
                textBox.updateText(curIcon.name, curIcon.role, curIcon.description);
                textBox.reloadIcons(curIcon.links);
            }
        }

        super.update(elapsed);
    }
}