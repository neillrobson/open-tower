package;

import Resources.Resource;

class HouseType {
    private static var id = 0;

    public static final houseTypes:Array<HouseType> = new Array();

    public static final MASON = new HouseType(1, "Mason", 10, 8, 12, 0, 15, 0, Resource.ROCK);
    public static final WOODCUTTER = new HouseType(2, "Woodcutter", 10, 8, 12, 15, 0, 0,
        Resource.WOOD);
    public static final PLANTER = new HouseType(0, "Planter", 10, 8, 12, 30, 15, 10);
    public static final FARM = new HouseType(6, "Farmer", 10, 8, 12, 30, 30, 0);
    public static final WINDMILL = new HouseType(7, "Miller", 8, 7, 13, 15, 15, 0, Resource.FOOD);
    public static final GUARDPOST = new HouseType(5, "Guardpost", 3, 8, 14, 0, 30, 0);
    public static final BARRACKS = new HouseType(3, "Barracks", 10, 8, 12, 15, 50, 0);
    public static final RESIDENCE = new HouseType(4, "Residence", 10, 8, 12, 30, 30, 30);

    public final spriteIndex:Int;
    public final radius:Int;
    public final anchorX:Int;
    public final anchorY:Int;
    public final wood:Int;
    public final rock:Int;
    public final food:Int;
    public final name:String;
    public final acceptResource:Resource;

    private function new(spriteIndex:Int, name:String, radius:Int, anchorX:Int, anchorY:Int,
            wood:Int, rock:Int, food:Int, acceptResource:Resource = null) {
        this.spriteIndex = spriteIndex;
        this.radius = radius;
        this.anchorX = anchorX;
        this.anchorY = anchorY;
        this.wood = wood;
        this.rock = rock;
        this.food = food;
        this.name = name;
        this.acceptResource = acceptResource;
        houseTypes[id++] = this;
    }

    public function getImage(spriteSheet:SpriteSheet) {
        return spriteSheet.houses[spriteIndex % 2 + 1][Std.int(spriteIndex / 2)];
    }

    public function getCostString() {
        var ret = '$name [';
        ret += '${wood > 0 ? ' wood: $wood' : ''}';
        ret += '${rock > 0 ? ' rock: $rock' : ''}';
        ret += '${food > 0 ? ' food: $food' : ''}';
        ret += ' ]';
        return ret;
    }

    public function getDescription() {
        switch (this) {
            case MASON:
                return "Gathers nearby stones; produces rock";
            case WOODCUTTER:
                return "Cuts down nearby trees; produces wood";
            case PLANTER:
                return "Plants new trees that can later be cut down";
            case FARM:
                return "Plants crops that can later be harvested";
            case WINDMILL:
                return "Gathers nearby grown crops; produces food";
            case GUARDPOST:
                return "Peons generally stay near these";
            default:
                return "**unknown**";
        }
    }
}
