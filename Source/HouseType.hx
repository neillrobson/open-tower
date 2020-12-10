package;

class HouseType {
    private static var id = 0;

    public static final houseTypes:Array<HouseType> = new Array();

    public static final MASON = new HouseType(1, "Mason", 10, 0, 15, 0);
    public static final WOODCUTTER = new HouseType(2, "Woodcutter", 10, 15, 0, 0);
    public static final PLANTER = new HouseType(0, "Planter", 10, 30, 15, 10);
    public static final FARM = new HouseType(6, "Farmer", 10, 30, 30, 0);
    public static final WINDMILL = new HouseType(7, "Miller", 8, 15, 15, 0);
    public static final GUARDPOST = new HouseType(5, "Guardpost", 3, 0, 30, 0);
    public static final BARRACKS = new HouseType(3, "Barracks", 10, 15, 50, 0);
    public static final RESIDENCE = new HouseType(4, "Residence", 10, 30, 30, 30);

    public final spriteIndex:Int;
    public final radius:Int;
    public final wood:Int;
    public final rock:Int;
    public final food:Int;
    public final name:String;

    private function new(spriteIndex:Int, name:String, radius:Int, wood:Int, rock:Int, food:Int) {
        this.spriteIndex = spriteIndex;
        this.radius = radius;
        this.wood = wood;
        this.rock = rock;
        this.food = food;
        this.name = name;
        houseTypes[id++] = this;
    }

    public function getImage(spriteSheet:SpriteSheet) {
        return spriteSheet.houses[spriteIndex % 2 + 1][Std.int(spriteIndex / 2)];
    }
}
