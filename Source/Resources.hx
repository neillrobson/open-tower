package;

enum Resource {
    WOOD;
    ROCK;
    FOOD;
    SEED;
}

class Resources {
    public var wood = 100;
    public var rock = 100;
    public var food = 100;

    public function new() {}

    public function add(r:Resource, count:Int) {
        switch (r) {
            case WOOD:
                wood += count;
            case ROCK:
                rock += count;
            case FOOD:
                food += count;
            default:
        }
    }

    public function charge(house:HouseType) {
        wood -= house.wood;
        rock -= house.rock;
        food -= house.food;
    }

    public function canAfford(house:HouseType) {
        if (wood < house.wood)
            return false;
        if (rock < house.rock)
            return false;
        if (food < house.food)
            return false;
        return true;
    }
}
