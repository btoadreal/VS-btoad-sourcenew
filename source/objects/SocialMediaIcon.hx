package objects;

class SocialMediaIcon extends FlxSprite
{
    var link:String;

    public function new(x:Float, y:Float, link:String)
    {
        super(0, 0);
        setup(link);
    }

    public function setup(link:String)
    {
        if (this.link == link) // We don't needa do this tedious process again if we already have the same thing!
            return;

        this.link = link;
        loadGraphic(Paths.image('credits/social_media/${CoolUtil.getDomainName(link)}'));
        scale.set(0.6, 0.6);
        updateHitbox();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera))
            CoolUtil.browserLoad(link);
    }
}