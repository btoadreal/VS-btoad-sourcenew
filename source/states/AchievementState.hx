package states;

import flixel.util.FlxSpriteUtil;
import backend.Achievements;
import objects.AttachedAchievement;

class AchievementState extends MusicBeatState
{
	private var menuBG:FlxSprite;
	private var achievementBody:FlxSprite;
	private var achievementTitle:FlxSprite;

	private var arrowUp:FlxSprite;
	private var arrowDn:FlxSprite;

	public var achievementIcon:FlxSprite;
	public var achievementDesc:FlxText;
	public var achievementComment:FlxText;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		var uiTex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		for (achieve in Achievements.list)
			Paths.image('achievements/${achieve.saveName}');
		Paths.image('achievements/lockedachievement');

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		menuBG.active = false;
		menuBG.antialiasing = ClientPrefs.data.antialiasing;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		add(menuBG);

		achievementBody = new FlxSprite(FlxG.width * 0.15).makeGraphic(Std.int(FlxG.width * 0.4), Std.int(FlxG.height * 0.85), 0x00000000);
		achievementBody.active = false;
		achievementBody.antialiasing = ClientPrefs.data.antialiasing;
		add(achievementBody);

		FlxSpriteUtil.drawRoundRect(achievementBody, 0, 0, achievementBody.width, achievementBody.height, 45, 45, 0xA1000000, null, {smoothing: true});

		achievementBody.x = 90;
		achievementBody.screenCenter(Y);

		achievementIcon = new FlxSprite((achievementBody.x + achievementBody.width / 2),
			achievementBody.y + achievementBody.height * 0.15).loadGraphic(Paths.image('achievements/lockedachievement'));
        achievementIcon.scale.set(1.2, 1.2);
        achievementIcon.updateHitbox();
		achievementIcon.x -= achievementIcon.width / 2;
		achievementIcon.active = false;
		achievementIcon.antialiasing = ClientPrefs.data.antialiasing;
		add(achievementIcon);

		achievementDesc = new FlxText(achievementBody.x + 20, achievementBody.y + achievementBody.height * 0.5, achievementBody.width - 40, "test test hehe",
			20);
		achievementDesc.active = false;
		achievementDesc.font = Paths.font("vcr.ttf");
		achievementDesc.alignment = CENTER;
		add(achievementDesc);

		achievementComment = new FlxText(achievementBody.x + 20, achievementBody.y + achievementBody.height * 0.6, achievementBody.width - 40,
			"test test hehe", 24);
		achievementComment.active = false;
		achievementComment.font = Paths.font("vcr.ttf");
		achievementComment.alignment = CENTER;
		add(achievementComment);

		achievementTitle = new FlxSprite();
		achievementTitle.active = false;
		achievementTitle.antialiasing = ClientPrefs.data.antialiasing;
		achievementTitle.frames = Paths.getSparrowAtlas('mainmenu/menu_Awards');
		achievementTitle.animation.addByPrefix("idle", 'awards white', 24);
		achievementTitle.animation.play('idle');
		achievementTitle.scale.x = achievementTitle.scale.y = achievementTitle.x
			+ (achievementTitle.width - achievementTitle.x) * (((FlxG.width + 40) - (achievementTitle.x + achievementTitle.width))
				- achievementTitle.x) / (achievementTitle.width - achievementTitle.x) / achievementTitle.width;
		achievementTitle.updateHitbox();
		achievementTitle.screenCenter();
		achievementTitle.x = FlxG.width * 0.5;
		add(achievementTitle);

		arrowUp = new FlxSprite();
        arrowUp.antialiasing = ClientPrefs.data.antialiasing;
		arrowUp.frames = uiTex;
		arrowUp.animation.addByPrefix('idle', "arrow left");
		arrowUp.animation.addByPrefix('press', "arrow push left");
		arrowUp.angle = 90;
		arrowUp.animation.play('idle');
		arrowUp.scale.set(0.8, 0.8);
		arrowUp.updateHitbox();
		arrowUp.setPosition(achievementBody.x + (achievementBody.width / 2) - arrowUp.width / 2, achievementBody.y - (arrowUp.height - 12)); // subtract 12 cuz hitboxes don't rotate?
		add(arrowUp);

		arrowDn = new FlxSprite();
        arrowDn.antialiasing = ClientPrefs.data.antialiasing;
		arrowDn.frames = uiTex;
		arrowDn.animation.addByPrefix('idle', "arrow right");
		arrowDn.animation.addByPrefix('press', "arrow push right");
		arrowDn.angle = 90;
		arrowDn.animation.play('idle');
		arrowDn.scale.set(0.8, 0.8);
		arrowDn.updateHitbox();
		arrowDn.setPosition(achievementBody.x + (achievementBody.width / 2) - arrowUp.width / 2, achievementBody.y + achievementBody.height - 12);
		add(arrowDn);

		changeSelection();
		super.create();
	}

	private var _curSelect:Int = 0;

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.UI_UP)
			arrowUp.animation.play('press');
		else
			arrowUp.animation.play('idle');
        
		if (controls.UI_DOWN)
			arrowDn.animation.play('press');
		else
			arrowDn.animation.play('idle');

		super.update(elapsed);
	}

	private function changeSelection(change:Int = 0):Void
	{
		if (change != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
		}

		_curSelect = FlxMath.wrap(_curSelect + change, 0, Achievements.list.length - 1);

		var unlocked:Bool = Achievements.isUnlocked(Achievements.list[_curSelect].saveName);

		if (unlocked)
			achievementIcon.loadGraphic(Paths.image('achievements/${Achievements.list[_curSelect].saveName}'));
		else
			achievementIcon.loadGraphic(Paths.image('achievements/lockedachievement'));
		achievementDesc.text = Achievements.list[_curSelect].description;
		achievementComment.text = (unlocked ? Achievements.list[_curSelect].comment : "???");

		achievementComment.y = Math.max(achievementBody.y + achievementBody.height * 0.6, achievementDesc.y + achievementDesc.height + 10);
	}
}
