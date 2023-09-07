package backend;

typedef Achievement = {
	var name:String;
	var description:String;
	var saveName:String;
	var hidden:Bool;
	@:optional var comment:String;
}

class Achievements {

	private static var _unlockStatus:Map<String, Bool> = new Map<String, Bool>();
	public static var list:Array<Achievement> = [
		create('Freaky on a Friday Night', 'Play on a Friday... Night.', 'friday_night_play', true, "WOWOWO COMMENT COMMENT"),
		create('BeatToad', 'Beat Week btoad on Hard with no Misses.', 'story1Btoad_nomiss'),
		create('What a Funkin\' Disaster!', 'Complete a Song with a rating lower than 20%.', 'ur_bad'),
		create('Perfectionist', 'Complete a Song with a rating of 100%.', 'ur_good'),
		create('Oversinging Much...?', 'Hold down a note for 10 seconds.', 'oversinging'),
		create('Hyperactive', 'Finish a Song without going Idle.', 'hype'),
		create('Just the Two of Us', 'Finish a Song pressing only two keys.', 'two_keys'),
		create('Toaster Gamer', 'Have you tried to run the game on a toaster?', 'toastie'),
		create('Debugger', 'Beat the "Test" Stage from the Chart Editor.', 'debugger', true)
	];

	public static function create(name:String, description:String, saveName:String, ?hidden:Bool = false, ?comment:String):Achievement
	{
		_unlockStatus.set(saveName, false);

		return {
			name: name,
			description: description,
			saveName: saveName,
			hidden: hidden,
			comment: comment
		};
	}

	public static function unlock(name:String):Void {
		trace('Completed achievement "$name"');
		_unlockStatus.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isUnlocked(name:String):Null<Bool>
	{
		return _unlockStatus.get(name);
	}

	public static function getAchievementIndex(name:String):Int {
		for (i => achievement in list)
		{
			if (achievement.saveName == name)
				return i;
		}
		return -1;
	}

	public static function get(name:String):Achievement {
		for (achievement in list)
		{
			if (achievement.saveName == name)
				return achievement;
		}
		return null;
	}

	public static function load():Void {
		if(FlxG.save.data != null && FlxG.save.data.achievementsMap != null) {
			_unlockStatus = FlxG.save.data.achievementsMap;
		}
	}

	public static function save():Void {
		FlxG.save.data.achievementsMap = _unlockStatus;
	}
}