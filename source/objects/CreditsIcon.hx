package objects;

class CreditsIcon extends FlxSprite {
    public var name:String;
    public var image:String;
    public var role:String;
    public var description:String;
    public var links:Array<String>;
    public var mainLink:Int = 0;
    public var pageColor:FlxColor;

    override public function new(name:String, image:String, role:String, description:String, links:Array<String>, mainLink:Int = 0, pageColor:FlxColor)
    {
        this.name = name;
        this.image = image;
        this.role = role;
        this.description = description;
        this.links = links;
        this.mainLink = mainLink;
        this.pageColor = pageColor;

        super(0, 0, Paths.image('credits/$image'));

        alpha = 0.5;
        if (graphic == null)
            loadGraphic(Paths.image('credits/missing_icon'));
    }

    public function getMainLink():String
    {
        return links[mainLink];
    }
}