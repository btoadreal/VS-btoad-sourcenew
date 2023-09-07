package objects;

class CreditsIcon extends FlxSprite {
    public var name:String;
    public var image:String;
    public var description:String;
    public var link:String;
    public var pageColor:FlxColor;

    override public function new(name:String, image:String, description:String, link:String, pageColor:FlxColor)
    {
        this.name = name;
        this.image = image;
        this.description = description;
        this.link = link;
        this.pageColor = pageColor;

        super(0, 0, Paths.image('credits/$image'));

        alpha = 0.5;
        if (graphic == null)
            loadGraphic(Paths.image('credits/missing_icon'));
    }
}