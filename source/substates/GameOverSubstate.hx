package substates;

import objects.Character;
import flixel.FlxObject;
import flixel.math.FlxPoint;

import states.StoryMenuState;
import states.FreeplayState;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Character;

	var solidObj:FlxSprite;
	var camFollow:FlxObject;
	var playingDeathSound:Bool = false;

	var isEnding:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';

		var _song = PlayState.SONG;
		if(_song != null)
		{
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
			if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
			if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
		}
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnScripts('inGameOver', true);

		Conductor.songPosition = 0;

		solidObj = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		solidObj.alpha = 0;
		solidObj.scrollFactor.set();
		PlayState.instance.addBehindBF(solidObj);

		boyfriend = new Character(x, y, characterName, true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		PlayState.instance.addBehindBF(boyfriend);

		FlxG.sound.play(Paths.sound(deathSoundName));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);
		add(camFollow);

		FlxG.camera.focusOn(FlxPoint.get(camX, camY));

		FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.flash(0xFFFFFFFF, 0.6, function() {
			FlxTween.tween(solidObj, {alpha:0.7}, 0.5, {ease: FlxEase.sineInOut, startDelay: 0.25});
			FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.5, {ease: FlxEase.elasticInOut});
		});
	}

	public var startedDeath:Bool = false;
	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		boyfriend.update(elapsed);

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (!isEnding && controls.ACCEPT)
		{
			endGameOver();
		}

		if (controls.BACK)
		{
			#if desktop DiscordClient.resetClientID(); #end
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			Mods.loadTopMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
		}
		
		if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished)
		{
			if (startedDeath)
				boyfriend.playAnim('deathLoop');

			if (!playingDeathSound)
			{
				startedDeath = true;
				if (PlayState.SONG.stage == 'tank')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);
					
					// var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}
				else
					coolStartDeath();
			}
		}
		
		FlxG.camera.followLerp = FlxMath.bound(elapsed * 3 / (FlxG.updateFramerate / 60), 0, 1);

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endGameOver():Void
	{
		isEnding = true;
		boyfriend.playAnim('deathConfirm', true);
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music(endSoundName));
		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				MusicBeatState.resetState();
			});
		});
		PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
