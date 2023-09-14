package states;

import sys.io.File;
import sys.FileSystem;
import objects.CreditsIcon;
import haxe.ds.IntMap;
import flixel.FlxObject;
import objects.CreditsTextBox;

typedef CreditsData = {
    var category:String;
    var users:Array<CreditsUser>;
}

typedef CreditsUser = {
    var name:String;
    var icon:String;
    var description:String;
    var color:String;
    var url:String;
}

class CreditsStateTwo extends MusicBeatState
{
    var curSelected:Int = 0;
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

        for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
        // pushModCreditsToList('btoad-fnf');
        updateIconAlignment();

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
    }

    function doIconAnim(spr:FlxSprite, alpha:Float = 0.5, scale:Float = 1)
    {
        if (spr.alpha == alpha && spr.scale.x == scale)
            return;

        FlxTween.cancelTweensOf(spr);
        FlxTween.tween(spr, {alpha:alpha, "scale.x": scale, "scale.y": scale}, 0.25, {ease:FlxEase.quadInOut});
    }

    function updateIconAlignment():Void
    {
        for (i => icon in iconArray)
            icon.setPosition(FlxG.width/2 + (i - 7/2) * 160, 230 - Math.abs(i%2-1) * 60);
    }

    var bgColorTwn:FlxTween;

    function changeSelection(by:Int=0)
    {
        doIconAnim(iconArray[curSelected]);
        curSelected = flixel.math.FlxMath.wrap(curSelected+by, 0, iconArray.length-1);

        var curIcon:FlxSprite = iconArray[curSelected];
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
            textBox.tweenText();
        else
            textBox.show();

        textBox.updateText(iconArray[curSelected].name, "coeder");

        if (curSequence != null && curSequence != categoryText.text)
        {
            categoryText.text = curSequence;
            FlxTween.cancelTweensOf(categoryText);
            categoryText.y = 25;
            categoryText.alpha = 0;
            FlxTween.tween(categoryText, {y: 30, alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
        }

        if (bgColorTwn != null) bgColorTwn.cancel();

        bgColorTwn = FlxTween.color(bg, 0.8, bg.color, iconArray[curSelected].pageColor, {ease: FlxEase.sineIn});

        leftArrow.visible = (curSelected != 0);
        rightArrow.visible = (curSelected != iconArray.length-1);

        cooldownTimer = 0;
    }

    function pushModCreditsToList(?folder:String)
    {
        var parsedData:Array<CreditsData> = [null];

        var creditsFile:String = "";
        if(folder != null && folder.trim().length > 0)
            creditsFile = Paths.mods('${folder}/data/credits.json');
        else
            creditsFile = Paths.mods('data/credits.json');

        if (FileSystem.exists(creditsFile))
        {
            parsedData = haxe.Json.parse(File.getContent(creditsFile)).credits;
            var prevSequence:String = null;

            for (data in parsedData)
            {
                sequences.set(iconArray.length-1, data.category);
                if (prevSequence != null)
                    sequences.set(iconArray.length-1, prevSequence);

                for (user in data.users) {
                    var icon:CreditsIcon = new CreditsIcon(user.name, user.icon, user.description, user.url, FlxColor.fromString(user.color));
                    icon.camera = camIcons;
                    iconArray.push(icon);
                    add(icon);
                }

                prevSequence = data.category;
            }

            sequences.set(iconArray.length-1, prevSequence);
        }
    }

    override function update(elapsed:Float)
    {
        cooldownTimer += elapsed;

        if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
        {
            changeSelection(controls.UI_RIGHT_P ? 1 : -1);
            (controls.UI_RIGHT_P ? rightArrow : leftArrow).animation.play('press');
        }

        if (controls.UI_LEFT_R || controls.UI_RIGHT_R)
			(controls.UI_RIGHT_R ? rightArrow : leftArrow).animation.play('idle');

        if (controls.BACK)
            #if FREEPLAY
            MusicBeatState.switchState(new FreeplayState());
            #else
            MusicBeatState.switchState(new MainMenuState());
            #end

        if (cooldownTimer >= 0.2)
        {
            spamChain = 0;

            if (!textBox.isVisible && cooldownTimer >= 0.3)
            {
                textBox.show();
                textBox.updateText(iconArray[curSelected].name, "coeder");
            }
        }

        super.update(elapsed);
    }
}