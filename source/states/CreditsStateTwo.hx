package states;

import sys.io.File;
import sys.FileSystem;
import objects.CreditsIcon;
import haxe.ds.IntMap;
import flixel.FlxObject;
import objects.CreditsTextBox;

class CreditsStateTwo extends MusicBeatState
{
    var curSelected:Int = 0;
    // var curSequence:Int = 0;

    var cooldownTimer:Float = 0.3; // Since the state was just switched we don't want the player to immediately spam and stuff.
    var spamChain:Float = 0;

    var sequences:IntMap<String> = new IntMap<String>();

    function getCategory(id:Int):String
    {
        return sequences.get(id);
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

        pushModCreditsToList('btoad-fnf');
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

    function changeSelection(by:Int=0)
    {
        doIconAnim(iconArray[curSelected]);
        curSelected = (curSelected + by + iconArray.length) % iconArray.length;

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

        var curCategory:String = getCategory(curSelected);
        if (curCategory != null && curCategory != categoryText.text)
        {
            categoryText.text = curCategory;

            FlxTween.cancelTweensOf(categoryText);
            categoryText.y = 25;
            categoryText.alpha = 0;
            FlxTween.tween(categoryText, {y: 30, alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
        }


        leftArrow.visible = (curSelected != 0);
        rightArrow.visible = (curSelected != iconArray.length-1);

        cooldownTimer = 0;
    }

    function pushModCreditsToList(folder:String)
    {
        var creditsFile:String = "";
        if(folder != null && folder.trim().length > 0)
            creditsFile = Paths.mods(folder + '/data/credits.txt');
        else
            creditsFile = Paths.mods('data/credits.txt');

        if (FileSystem.exists(creditsFile))
        {
            var textFile:Array<String> = File.getContent(creditsFile).split('\n');
            var prevSequence:String = null;

            for(i => line in textFile)
            {
                var arr:Array<String> = line.replace('\\n', '\n').split("::");

                if (arr.length == 1) // This is a simple check to see if its a new team or shit
                {
                    sequences.set(iconArray.length, arr[0]);
                    if (prevSequence != null)
                        sequences.set(iconArray.length-1, prevSequence);
                    prevSequence = arr[0];
                    continue;
                }

                var icon:CreditsIcon = new CreditsIcon(arr[0], arr[1], arr[2], arr[3], FlxColor.fromString(arr[4]));
                icon.cameras = [camIcons];

                iconArray.push(icon);
                add(icon);
            }
            sequences.set(iconArray.length-1, prevSequence);
        }
    }

    override function update(elapsed:Float)
    {
        cooldownTimer += elapsed;

        if (controls.UI_LEFT_P)
        {
            changeSelection(-1);
            leftArrow.animation.play('press');
        }
        if (controls.UI_RIGHT_P)
        {
            changeSelection(1);
            rightArrow.animation.play('press');
        }

        if (controls.UI_LEFT_R)
			leftArrow.animation.play('idle');
        
		if (controls.UI_RIGHT_R)
			rightArrow.animation.play('idle');

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