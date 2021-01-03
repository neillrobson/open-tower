/**
    Everything in this class comes from HaxeFlixel's FlxRandom.
    https://github.com/HaxeFlixel/flixel/blob/dev/flixel/math/FlxRandom.hx
**/

package;

class Random {
    /**
     * The global base random number generator seed (for deterministic behavior in recordings and saves).
     * If you want, you can set the seed with an integer between 1 and 2,147,483,647 inclusive.
     * Altering this yourself may break recording functionality!
     */
    public var initialSeed(default, set):Int = 1;

    /**
     * Current seed used to generate new random numbers. You can retrieve this value if,
     * for example, you want to store the seed that was used to randomly generate a level.
     */
    public var currentSeed(get, set):Int;

    /**
     * Returns the internal seed as an integer.
     */
    inline function get_currentSeed():Int {
        return Std.int(internalSeed);
    }

    /**
     * Sets the internal seed to an integer value.
     */
    inline function set_currentSeed(NewSeed:Int):Int {
        return Std.int(internalSeed = rangeBound(NewSeed));
    }

    /**
     * Internal function to update the current seed whenever the initial seed is reset,
     * and keep the initial seed's value in range.
     */
    inline function set_initialSeed(NewSeed:Int):Int {
        return initialSeed = currentSeed = rangeBound(NewSeed);
    }

    /**
     * Create a new FlxRandom object.
     *
     * @param	InitialSeed  The first seed of this FlxRandom object. If ignored, a random seed will be generated.
     */
    public function new(?InitialSeed:Int) {
        if (InitialSeed != null) {
            initialSeed = InitialSeed;
        } else {
            resetInitialSeed();
        }
    }

    /**
     * Function to easily set the global seed to a new random number.
     * Please note that this function is not deterministic!
     * If you call it in your game, recording may not function as expected.
     *
     * @return  The new initial seed.
     */
    public inline function resetInitialSeed():Int {
        return initialSeed = rangeBound(Std.int(Math.random() * MODULUS));
    }

    /**
     * Internal shared function to ensure an arbitrary value is in the valid range of seed values.
     */
    static inline function rangeBound(Value:Int):Int {
        return Std.int(bound(Value, 1, MODULUS - 1));
    }

    /**
     * Bound a number by a minimum and maximum. Ensures that this number is
     * no smaller than the minimum, and no larger than the maximum.
     * Leaving a bound `null` means that side is unbounded.
     *
     * @param	Value	Any number.
     * @param	Min		Any number.
     * @param	Max		Any number.
     * @return	The bounded value of the number.
     */
    public static inline function bound(Value:Float, ?Min:Float, ?Max:Float):Float {
        var lowerBound:Float = (Min != null && Value < Min) ? Min : Value;
        return (Max != null && lowerBound > Max) ? Max : lowerBound;
    }

    /**
     * Constants used in the pseudorandom number generation equation.
     * These are the constants suggested by the revised MINSTD pseudorandom number generator,
     * and they use the full range of possible integer values.
     *
     * @see http://en.wikipedia.org/wiki/Linear_congruential_generator
     * @see Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988).
     *      "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
     */
    static inline var MULTIPLIER:Float = 48271.0;

    static inline var MODULUS:Int = 2147483647;

    /**
     * The actual internal seed. Stored as a Float value to prevent inaccuracies due to
     * integer overflow in the generate() equation.
     */
    var internalSeed:Float = 1;

    // helper variables for floatNormal -- it produces TWO random values with each call so we have to store some state outside the function
    var _hasFloatNormalSpare:Bool = false;
    var _floatNormalRand1:Float = 0;
    var _floatNormalRand2:Float = 0;
    var _twoPI:Float = Math.PI * 2;
    var _floatNormalRho:Float = 0;

    /**
     * Returns a pseudorandom float value in a statistical normal distribution centered on Mean with a standard deviation size of StdDev.
     * (This uses the Box-Muller transform algorithm for gaussian pseudorandom numbers)
     *
     * Normal distribution: 68% values are within 1 standard deviation, 95% are in 2 StdDevs, 99% in 3 StdDevs.
     * See this image: https://github.com/HaxeFlixel/flixel-demos/blob/dev/Performance/FlxRandom/normaldistribution.png
     *
     * @param	Mean		The Mean around which the normal distribution is centered
     * @param	StdDev		Size of the standard deviation
     */
    public function floatNormal(Mean:Float = 0, StdDev:Float = 1):Float {
        if (_hasFloatNormalSpare) {
            _hasFloatNormalSpare = false;
            var scale:Float = StdDev * _floatNormalRho;
            return Mean + scale * _floatNormalRand2;
        }

        _hasFloatNormalSpare = true;

        var theta:Float = _twoPI * (generate() / MODULUS);
        _floatNormalRho = Math.sqrt(-2 * Math.log(1 - (generate() / MODULUS)));
        var scale:Float = StdDev * _floatNormalRho;

        _floatNormalRand1 = Math.cos(theta);
        _floatNormalRand2 = Math.sin(theta);

        return Mean + scale * _floatNormalRand1;
    }

    /**
     * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
     * Also updates the internal seed, which will then be used to generate the next pseudorandom number.
     *
     * @return  A new pseudorandom number.
     */
    inline function generate():Float {
        return internalSeed = (internalSeed * MULTIPLIER) % MODULUS;
    }
}
