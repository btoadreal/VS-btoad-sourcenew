package states;

import objects.FreeplayCategory as Category;
import backend.WeekData;

using StringTools;

class FreeplayCategoryState extends MusicBeatState
{
    private var categories(default, null):Array<String> = ["Story", "Freeplay", "Bonus"];
    private var categoryGroup:FlxTypedGroup<Category>;
    private var bg:FlxSprite;

    private static var curSelection:Int = 0;

    public static var previousCategory:String = null;

    override function create()
    {
        bg = new FlxSprite(0, 0, Paths.image("menuBGMagenta"));
        categoryGroup = new FlxTypedGroup<Category>(10);

        WeekData.reloadWeekFiles(false);

        add(bg);
        add(categoryGroup);

        for (category in categories)
        {
            var spr:Category = new Category(category);
            categoryGroup.add(spr);
        }

        centerCategories();
        changeSelection();
        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.UI_LEFT_P)
            changeSelection(-1);
        if (controls.UI_RIGHT_P)
            changeSelection(1);
        if (controls.ACCEPT)
            categorySelected();
        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
            MusicBeatState.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }

    function centerCategories(multiplier:Float = 1.1)
    {
        var half:Float = categories.length / 2;
        for (i => spr in categoryGroup.members)
        {
            spr.screenCenter(XY);
            spr.x = FlxMath.bound(spr.x - (half - i) * (spr.width*multiplier) + spr.width*(multiplier/2), 25, FlxG.width - (spr.width + 25));
        }
    }

    function changeSelection(amount:Int=0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        curSelection = (curSelection + amount + categories.length) % categories.length;

        for (k => spr in categoryGroup.members)
        {
            spr.alpha = (curSelection == k ? 1 : 0.5);
        }
    }

    function categorySelected()
    {
        previousCategory = categories[curSelection];
        MusicBeatState.switchState(new FreeplayState(listWeeks(previousCategory)));
    }

    public static function listWeeks(?category:String):Array<String>
    {
        if (category == null) // Checking if a category was specified to load.
            category = previousCategory;
        if (category == null) // No category loaded? Just return all weeks to prevent crashes.
            return WeekData.weeksList;

        var loadWeeks:Array<String> = [];

        switch(category)
        {
            case "Story":
                for (name in WeekData.weeksList)
                {
                    if (name.toLowerCase().startsWith("story"))
                        loadWeeks.push(name);
                }
            default:
                loadWeeks.push(category);
        }
        return loadWeeks;
    }
}