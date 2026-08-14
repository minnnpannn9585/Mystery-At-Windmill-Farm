(function (global, factory) {
	typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports) :
	typeof define === 'function' && define.amd ? define(['exports'], factory) :
	(global = typeof globalThis !== 'undefined' ? globalThis : global || self, factory(global.stark_websdk = {}));
})(this, (function (exports) { 'use strict';

	var commonjsGlobal = typeof globalThis !== 'undefined' ? globalThis : typeof window !== 'undefined' ? window : typeof global !== 'undefined' ? global : typeof self !== 'undefined' ? self : {};

	function getAugmentedNamespace(n) {
	  if (n.__esModule) return n;
	  var f = n.default;
		if (typeof f == "function") {
			var a = function a () {
				if (this instanceof a) {
	        return Reflect.construct(f, arguments, this.constructor);
				}
				return f.apply(this, arguments);
			};
			a.prototype = f.prototype;
	  } else a = {};
	  Object.defineProperty(a, '__esModule', {value: true});
		Object.keys(n).forEach(function (k) {
			var d = Object.getOwnPropertyDescriptor(n, k);
			Object.defineProperty(a, k, d.get ? d : {
				enumerable: true,
				get: function () {
					return n[k];
				}
			});
		});
		return a;
	}

	var long = Long;

	/**
	 * wasm optimizations, to do native i64 multiplication and divide
	 */
	var wasm = null;

	try {
	  wasm = new WebAssembly.Instance(new WebAssembly.Module(new Uint8Array([
	    0, 97, 115, 109, 1, 0, 0, 0, 1, 13, 2, 96, 0, 1, 127, 96, 4, 127, 127, 127, 127, 1, 127, 3, 7, 6, 0, 1, 1, 1, 1, 1, 6, 6, 1, 127, 1, 65, 0, 11, 7, 50, 6, 3, 109, 117, 108, 0, 1, 5, 100, 105, 118, 95, 115, 0, 2, 5, 100, 105, 118, 95, 117, 0, 3, 5, 114, 101, 109, 95, 115, 0, 4, 5, 114, 101, 109, 95, 117, 0, 5, 8, 103, 101, 116, 95, 104, 105, 103, 104, 0, 0, 10, 191, 1, 6, 4, 0, 35, 0, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 126, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 127, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 128, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 129, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11, 36, 1, 1, 126, 32, 0, 173, 32, 1, 173, 66, 32, 134, 132, 32, 2, 173, 32, 3, 173, 66, 32, 134, 132, 130, 34, 4, 66, 32, 135, 167, 36, 0, 32, 4, 167, 11
	  ])), {}).exports;
	} catch (e) {
	  // no wasm support :(
	}

	/**
	 * Constructs a 64 bit two's-complement integer, given its low and high 32 bit values as *signed* integers.
	 *  See the from* functions below for more convenient ways of constructing Longs.
	 * @exports Long
	 * @class A Long class for representing a 64 bit two's-complement integer value.
	 * @param {number} low The low (signed) 32 bits of the long
	 * @param {number} high The high (signed) 32 bits of the long
	 * @param {boolean=} unsigned Whether unsigned or not, defaults to signed
	 * @constructor
	 */
	function Long(low, high, unsigned) {

	    /**
	     * The low 32 bits as a signed value.
	     * @type {number}
	     */
	    this.low = low | 0;

	    /**
	     * The high 32 bits as a signed value.
	     * @type {number}
	     */
	    this.high = high | 0;

	    /**
	     * Whether unsigned or not.
	     * @type {boolean}
	     */
	    this.unsigned = !!unsigned;
	}

	// The internal representation of a long is the two given signed, 32-bit values.
	// We use 32-bit pieces because these are the size of integers on which
	// Javascript performs bit-operations.  For operations like addition and
	// multiplication, we split each number into 16 bit pieces, which can easily be
	// multiplied within Javascript's floating-point representation without overflow
	// or change in sign.
	//
	// In the algorithms below, we frequently reduce the negative case to the
	// positive case by negating the input(s) and then post-processing the result.
	// Note that we must ALWAYS check specially whether those values are MIN_VALUE
	// (-2^63) because -MIN_VALUE == MIN_VALUE (since 2^63 cannot be represented as
	// a positive number, it overflows back into a negative).  Not handling this
	// case would often result in infinite recursion.
	//
	// Common constant values ZERO, ONE, NEG_ONE, etc. are defined below the from*
	// methods on which they depend.

	/**
	 * An indicator used to reliably determine if an object is a Long or not.
	 * @type {boolean}
	 * @const
	 * @private
	 */
	Long.prototype.__isLong__;

	Object.defineProperty(Long.prototype, "__isLong__", { value: true });

	/**
	 * @function
	 * @param {*} obj Object
	 * @returns {boolean}
	 * @inner
	 */
	function isLong(obj) {
	    return (obj && obj["__isLong__"]) === true;
	}

	/**
	 * Tests if the specified object is a Long.
	 * @function
	 * @param {*} obj Object
	 * @returns {boolean}
	 */
	Long.isLong = isLong;

	/**
	 * A cache of the Long representations of small integer values.
	 * @type {!Object}
	 * @inner
	 */
	var INT_CACHE = {};

	/**
	 * A cache of the Long representations of small unsigned integer values.
	 * @type {!Object}
	 * @inner
	 */
	var UINT_CACHE = {};

	/**
	 * @param {number} value
	 * @param {boolean=} unsigned
	 * @returns {!Long}
	 * @inner
	 */
	function fromInt(value, unsigned) {
	    var obj, cachedObj, cache;
	    if (unsigned) {
	        value >>>= 0;
	        if (cache = (0 <= value && value < 256)) {
	            cachedObj = UINT_CACHE[value];
	            if (cachedObj)
	                return cachedObj;
	        }
	        obj = fromBits(value, (value | 0) < 0 ? -1 : 0, true);
	        if (cache)
	            UINT_CACHE[value] = obj;
	        return obj;
	    } else {
	        value |= 0;
	        if (cache = (-128 <= value && value < 128)) {
	            cachedObj = INT_CACHE[value];
	            if (cachedObj)
	                return cachedObj;
	        }
	        obj = fromBits(value, value < 0 ? -1 : 0, false);
	        if (cache)
	            INT_CACHE[value] = obj;
	        return obj;
	    }
	}

	/**
	 * Returns a Long representing the given 32 bit integer value.
	 * @function
	 * @param {number} value The 32 bit integer in question
	 * @param {boolean=} unsigned Whether unsigned or not, defaults to signed
	 * @returns {!Long} The corresponding Long value
	 */
	Long.fromInt = fromInt;

	/**
	 * @param {number} value
	 * @param {boolean=} unsigned
	 * @returns {!Long}
	 * @inner
	 */
	function fromNumber(value, unsigned) {
	    if (isNaN(value))
	        return unsigned ? UZERO : ZERO;
	    if (unsigned) {
	        if (value < 0)
	            return UZERO;
	        if (value >= TWO_PWR_64_DBL)
	            return MAX_UNSIGNED_VALUE;
	    } else {
	        if (value <= -TWO_PWR_63_DBL)
	            return MIN_VALUE;
	        if (value + 1 >= TWO_PWR_63_DBL)
	            return MAX_VALUE;
	    }
	    if (value < 0)
	        return fromNumber(-value, unsigned).neg();
	    return fromBits((value % TWO_PWR_32_DBL) | 0, (value / TWO_PWR_32_DBL) | 0, unsigned);
	}

	/**
	 * Returns a Long representing the given value, provided that it is a finite number. Otherwise, zero is returned.
	 * @function
	 * @param {number} value The number in question
	 * @param {boolean=} unsigned Whether unsigned or not, defaults to signed
	 * @returns {!Long} The corresponding Long value
	 */
	Long.fromNumber = fromNumber;

	/**
	 * @param {number} lowBits
	 * @param {number} highBits
	 * @param {boolean=} unsigned
	 * @returns {!Long}
	 * @inner
	 */
	function fromBits(lowBits, highBits, unsigned) {
	    return new Long(lowBits, highBits, unsigned);
	}

	/**
	 * Returns a Long representing the 64 bit integer that comes by concatenating the given low and high bits. Each is
	 *  assumed to use 32 bits.
	 * @function
	 * @param {number} lowBits The low 32 bits
	 * @param {number} highBits The high 32 bits
	 * @param {boolean=} unsigned Whether unsigned or not, defaults to signed
	 * @returns {!Long} The corresponding Long value
	 */
	Long.fromBits = fromBits;

	/**
	 * @function
	 * @param {number} base
	 * @param {number} exponent
	 * @returns {number}
	 * @inner
	 */
	var pow_dbl = Math.pow; // Used 4 times (4*8 to 15+4)

	/**
	 * @param {string} str
	 * @param {(boolean|number)=} unsigned
	 * @param {number=} radix
	 * @returns {!Long}
	 * @inner
	 */
	function fromString$1(str, unsigned, radix) {
	    if (str.length === 0)
	        throw Error('empty string');
	    if (str === "NaN" || str === "Infinity" || str === "+Infinity" || str === "-Infinity")
	        return ZERO;
	    if (typeof unsigned === 'number') {
	        // For goog.math.long compatibility
	        radix = unsigned,
	        unsigned = false;
	    } else {
	        unsigned = !! unsigned;
	    }
	    radix = radix || 10;
	    if (radix < 2 || 36 < radix)
	        throw RangeError('radix');

	    var p;
	    if ((p = str.indexOf('-')) > 0)
	        throw Error('interior hyphen');
	    else if (p === 0) {
	        return fromString$1(str.substring(1), unsigned, radix).neg();
	    }

	    // Do several (8) digits each time through the loop, so as to
	    // minimize the calls to the very expensive emulated div.
	    var radixToPower = fromNumber(pow_dbl(radix, 8));

	    var result = ZERO;
	    for (var i = 0; i < str.length; i += 8) {
	        var size = Math.min(8, str.length - i),
	            value = parseInt(str.substring(i, i + size), radix);
	        if (size < 8) {
	            var power = fromNumber(pow_dbl(radix, size));
	            result = result.mul(power).add(fromNumber(value));
	        } else {
	            result = result.mul(radixToPower);
	            result = result.add(fromNumber(value));
	        }
	    }
	    result.unsigned = unsigned;
	    return result;
	}

	/**
	 * Returns a Long representation of the given string, written using the specified radix.
	 * @function
	 * @param {string} str The textual representation of the Long
	 * @param {(boolean|number)=} unsigned Whether unsigned or not, defaults to signed
	 * @param {number=} radix The radix in which the text is written (2-36), defaults to 10
	 * @returns {!Long} The corresponding Long value
	 */
	Long.fromString = fromString$1;

	/**
	 * @function
	 * @param {!Long|number|string|!{low: number, high: number, unsigned: boolean}} val
	 * @param {boolean=} unsigned
	 * @returns {!Long}
	 * @inner
	 */
	function fromValue(val, unsigned) {
	    if (typeof val === 'number')
	        return fromNumber(val, unsigned);
	    if (typeof val === 'string')
	        return fromString$1(val, unsigned);
	    // Throws for non-objects, converts non-instanceof Long:
	    return fromBits(val.low, val.high, typeof unsigned === 'boolean' ? unsigned : val.unsigned);
	}

	/**
	 * Converts the specified value to a Long using the appropriate from* function for its type.
	 * @function
	 * @param {!Long|number|string|!{low: number, high: number, unsigned: boolean}} val Value
	 * @param {boolean=} unsigned Whether unsigned or not, defaults to signed
	 * @returns {!Long}
	 */
	Long.fromValue = fromValue;

	// NOTE: the compiler should inline these constant values below and then remove these variables, so there should be
	// no runtime penalty for these.

	/**
	 * @type {number}
	 * @const
	 * @inner
	 */
	var TWO_PWR_16_DBL = 1 << 16;

	/**
	 * @type {number}
	 * @const
	 * @inner
	 */
	var TWO_PWR_24_DBL = 1 << 24;

	/**
	 * @type {number}
	 * @const
	 * @inner
	 */
	var TWO_PWR_32_DBL = TWO_PWR_16_DBL * TWO_PWR_16_DBL;

	/**
	 * @type {number}
	 * @const
	 * @inner
	 */
	var TWO_PWR_64_DBL = TWO_PWR_32_DBL * TWO_PWR_32_DBL;

	/**
	 * @type {number}
	 * @const
	 * @inner
	 */
	var TWO_PWR_63_DBL = TWO_PWR_64_DBL / 2;

	/**
	 * @type {!Long}
	 * @const
	 * @inner
	 */
	var TWO_PWR_24 = fromInt(TWO_PWR_24_DBL);

	/**
	 * @type {!Long}
	 * @inner
	 */
	var ZERO = fromInt(0);

	/**
	 * Signed zero.
	 * @type {!Long}
	 */
	Long.ZERO = ZERO;

	/**
	 * @type {!Long}
	 * @inner
	 */
	var UZERO = fromInt(0, true);

	/**
	 * Unsigned zero.
	 * @type {!Long}
	 */
	Long.UZERO = UZERO;

	/**
	 * @type {!Long}
	 * @inner
	 */
	var ONE = fromInt(1);

	/**
	 * Signed one.
	 * @type {!Long}
	 */
	Long.ONE = ONE;

	/**
	 * @type {!Long}
	 * @inner
	 */
	var UONE = fromInt(1, true);

	/**
	 * Unsigned one.
	 * @type {!Long}
	 */
	Long.UONE = UONE;

	/**
	 * @type {!Long}
	 * @inner
	 */
	var NEG_ONE = fromInt(-1);

	/**
	 * Signed negative one.
	 * @type {!Long}
	 */
	Long.NEG_ONE = NEG_ONE;

	/**
	 * @type {!Long}
	 * @inner
	 */
	var MAX_VALUE = fromBits(0xFFFFFFFF|0, 0x7FFFFFFF|0, false);

	/**
	 * Maximum signed value.
	 * @type {!Long}
	 */
	Long.MAX_VALUE = MAX_VALUE;

	/**
	 * @type {!Long}
	 * @inner
	 */
	var MAX_UNSIGNED_VALUE = fromBits(0xFFFFFFFF|0, 0xFFFFFFFF|0, true);

	/**
	 * Maximum unsigned value.
	 * @type {!Long}
	 */
	Long.MAX_UNSIGNED_VALUE = MAX_UNSIGNED_VALUE;

	/**
	 * @type {!Long}
	 * @inner
	 */
	var MIN_VALUE = fromBits(0, 0x80000000|0, false);

	/**
	 * Minimum signed value.
	 * @type {!Long}
	 */
	Long.MIN_VALUE = MIN_VALUE;

	/**
	 * @alias Long.prototype
	 * @inner
	 */
	var LongPrototype = Long.prototype;

	/**
	 * Converts the Long to a 32 bit integer, assuming it is a 32 bit integer.
	 * @returns {number}
	 */
	LongPrototype.toInt = function toInt() {
	    return this.unsigned ? this.low >>> 0 : this.low;
	};

	/**
	 * Converts the Long to a the nearest floating-point representation of this value (double, 53 bit mantissa).
	 * @returns {number}
	 */
	LongPrototype.toNumber = function toNumber() {
	    if (this.unsigned)
	        return ((this.high >>> 0) * TWO_PWR_32_DBL) + (this.low >>> 0);
	    return this.high * TWO_PWR_32_DBL + (this.low >>> 0);
	};

	/**
	 * Converts the Long to a string written in the specified radix.
	 * @param {number=} radix Radix (2-36), defaults to 10
	 * @returns {string}
	 * @override
	 * @throws {RangeError} If `radix` is out of range
	 */
	LongPrototype.toString = function toString(radix) {
	    radix = radix || 10;
	    if (radix < 2 || 36 < radix)
	        throw RangeError('radix');
	    if (this.isZero())
	        return '0';
	    if (this.isNegative()) { // Unsigned Longs are never negative
	        if (this.eq(MIN_VALUE)) {
	            // We need to change the Long value before it can be negated, so we remove
	            // the bottom-most digit in this base and then recurse to do the rest.
	            var radixLong = fromNumber(radix),
	                div = this.div(radixLong),
	                rem1 = div.mul(radixLong).sub(this);
	            return div.toString(radix) + rem1.toInt().toString(radix);
	        } else
	            return '-' + this.neg().toString(radix);
	    }

	    // Do several (6) digits each time through the loop, so as to
	    // minimize the calls to the very expensive emulated div.
	    var radixToPower = fromNumber(pow_dbl(radix, 6), this.unsigned),
	        rem = this;
	    var result = '';
	    while (true) {
	        var remDiv = rem.div(radixToPower),
	            intval = rem.sub(remDiv.mul(radixToPower)).toInt() >>> 0,
	            digits = intval.toString(radix);
	        rem = remDiv;
	        if (rem.isZero())
	            return digits + result;
	        else {
	            while (digits.length < 6)
	                digits = '0' + digits;
	            result = '' + digits + result;
	        }
	    }
	};

	/**
	 * Gets the high 32 bits as a signed integer.
	 * @returns {number} Signed high bits
	 */
	LongPrototype.getHighBits = function getHighBits() {
	    return this.high;
	};

	/**
	 * Gets the high 32 bits as an unsigned integer.
	 * @returns {number} Unsigned high bits
	 */
	LongPrototype.getHighBitsUnsigned = function getHighBitsUnsigned() {
	    return this.high >>> 0;
	};

	/**
	 * Gets the low 32 bits as a signed integer.
	 * @returns {number} Signed low bits
	 */
	LongPrototype.getLowBits = function getLowBits() {
	    return this.low;
	};

	/**
	 * Gets the low 32 bits as an unsigned integer.
	 * @returns {number} Unsigned low bits
	 */
	LongPrototype.getLowBitsUnsigned = function getLowBitsUnsigned() {
	    return this.low >>> 0;
	};

	/**
	 * Gets the number of bits needed to represent the absolute value of this Long.
	 * @returns {number}
	 */
	LongPrototype.getNumBitsAbs = function getNumBitsAbs() {
	    if (this.isNegative()) // Unsigned Longs are never negative
	        return this.eq(MIN_VALUE) ? 64 : this.neg().getNumBitsAbs();
	    var val = this.high != 0 ? this.high : this.low;
	    for (var bit = 31; bit > 0; bit--)
	        if ((val & (1 << bit)) != 0)
	            break;
	    return this.high != 0 ? bit + 33 : bit + 1;
	};

	/**
	 * Tests if this Long's value equals zero.
	 * @returns {boolean}
	 */
	LongPrototype.isZero = function isZero() {
	    return this.high === 0 && this.low === 0;
	};

	/**
	 * Tests if this Long's value equals zero. This is an alias of {@link Long#isZero}.
	 * @returns {boolean}
	 */
	LongPrototype.eqz = LongPrototype.isZero;

	/**
	 * Tests if this Long's value is negative.
	 * @returns {boolean}
	 */
	LongPrototype.isNegative = function isNegative() {
	    return !this.unsigned && this.high < 0;
	};

	/**
	 * Tests if this Long's value is positive.
	 * @returns {boolean}
	 */
	LongPrototype.isPositive = function isPositive() {
	    return this.unsigned || this.high >= 0;
	};

	/**
	 * Tests if this Long's value is odd.
	 * @returns {boolean}
	 */
	LongPrototype.isOdd = function isOdd() {
	    return (this.low & 1) === 1;
	};

	/**
	 * Tests if this Long's value is even.
	 * @returns {boolean}
	 */
	LongPrototype.isEven = function isEven() {
	    return (this.low & 1) === 0;
	};

	/**
	 * Tests if this Long's value equals the specified's.
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.equals = function equals(other) {
	    if (!isLong(other))
	        other = fromValue(other);
	    if (this.unsigned !== other.unsigned && (this.high >>> 31) === 1 && (other.high >>> 31) === 1)
	        return false;
	    return this.high === other.high && this.low === other.low;
	};

	/**
	 * Tests if this Long's value equals the specified's. This is an alias of {@link Long#equals}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.eq = LongPrototype.equals;

	/**
	 * Tests if this Long's value differs from the specified's.
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.notEquals = function notEquals(other) {
	    return !this.eq(/* validates */ other);
	};

	/**
	 * Tests if this Long's value differs from the specified's. This is an alias of {@link Long#notEquals}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.neq = LongPrototype.notEquals;

	/**
	 * Tests if this Long's value differs from the specified's. This is an alias of {@link Long#notEquals}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.ne = LongPrototype.notEquals;

	/**
	 * Tests if this Long's value is less than the specified's.
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.lessThan = function lessThan(other) {
	    return this.comp(/* validates */ other) < 0;
	};

	/**
	 * Tests if this Long's value is less than the specified's. This is an alias of {@link Long#lessThan}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.lt = LongPrototype.lessThan;

	/**
	 * Tests if this Long's value is less than or equal the specified's.
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.lessThanOrEqual = function lessThanOrEqual(other) {
	    return this.comp(/* validates */ other) <= 0;
	};

	/**
	 * Tests if this Long's value is less than or equal the specified's. This is an alias of {@link Long#lessThanOrEqual}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.lte = LongPrototype.lessThanOrEqual;

	/**
	 * Tests if this Long's value is less than or equal the specified's. This is an alias of {@link Long#lessThanOrEqual}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.le = LongPrototype.lessThanOrEqual;

	/**
	 * Tests if this Long's value is greater than the specified's.
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.greaterThan = function greaterThan(other) {
	    return this.comp(/* validates */ other) > 0;
	};

	/**
	 * Tests if this Long's value is greater than the specified's. This is an alias of {@link Long#greaterThan}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.gt = LongPrototype.greaterThan;

	/**
	 * Tests if this Long's value is greater than or equal the specified's.
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.greaterThanOrEqual = function greaterThanOrEqual(other) {
	    return this.comp(/* validates */ other) >= 0;
	};

	/**
	 * Tests if this Long's value is greater than or equal the specified's. This is an alias of {@link Long#greaterThanOrEqual}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.gte = LongPrototype.greaterThanOrEqual;

	/**
	 * Tests if this Long's value is greater than or equal the specified's. This is an alias of {@link Long#greaterThanOrEqual}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {boolean}
	 */
	LongPrototype.ge = LongPrototype.greaterThanOrEqual;

	/**
	 * Compares this Long's value with the specified's.
	 * @param {!Long|number|string} other Other value
	 * @returns {number} 0 if they are the same, 1 if the this is greater and -1
	 *  if the given one is greater
	 */
	LongPrototype.compare = function compare(other) {
	    if (!isLong(other))
	        other = fromValue(other);
	    if (this.eq(other))
	        return 0;
	    var thisNeg = this.isNegative(),
	        otherNeg = other.isNegative();
	    if (thisNeg && !otherNeg)
	        return -1;
	    if (!thisNeg && otherNeg)
	        return 1;
	    // At this point the sign bits are the same
	    if (!this.unsigned)
	        return this.sub(other).isNegative() ? -1 : 1;
	    // Both are positive if at least one is unsigned
	    return (other.high >>> 0) > (this.high >>> 0) || (other.high === this.high && (other.low >>> 0) > (this.low >>> 0)) ? -1 : 1;
	};

	/**
	 * Compares this Long's value with the specified's. This is an alias of {@link Long#compare}.
	 * @function
	 * @param {!Long|number|string} other Other value
	 * @returns {number} 0 if they are the same, 1 if the this is greater and -1
	 *  if the given one is greater
	 */
	LongPrototype.comp = LongPrototype.compare;

	/**
	 * Negates this Long's value.
	 * @returns {!Long} Negated Long
	 */
	LongPrototype.negate = function negate() {
	    if (!this.unsigned && this.eq(MIN_VALUE))
	        return MIN_VALUE;
	    return this.not().add(ONE);
	};

	/**
	 * Negates this Long's value. This is an alias of {@link Long#negate}.
	 * @function
	 * @returns {!Long} Negated Long
	 */
	LongPrototype.neg = LongPrototype.negate;

	/**
	 * Returns the sum of this and the specified Long.
	 * @param {!Long|number|string} addend Addend
	 * @returns {!Long} Sum
	 */
	LongPrototype.add = function add(addend) {
	    if (!isLong(addend))
	        addend = fromValue(addend);

	    // Divide each number into 4 chunks of 16 bits, and then sum the chunks.

	    var a48 = this.high >>> 16;
	    var a32 = this.high & 0xFFFF;
	    var a16 = this.low >>> 16;
	    var a00 = this.low & 0xFFFF;

	    var b48 = addend.high >>> 16;
	    var b32 = addend.high & 0xFFFF;
	    var b16 = addend.low >>> 16;
	    var b00 = addend.low & 0xFFFF;

	    var c48 = 0, c32 = 0, c16 = 0, c00 = 0;
	    c00 += a00 + b00;
	    c16 += c00 >>> 16;
	    c00 &= 0xFFFF;
	    c16 += a16 + b16;
	    c32 += c16 >>> 16;
	    c16 &= 0xFFFF;
	    c32 += a32 + b32;
	    c48 += c32 >>> 16;
	    c32 &= 0xFFFF;
	    c48 += a48 + b48;
	    c48 &= 0xFFFF;
	    return fromBits((c16 << 16) | c00, (c48 << 16) | c32, this.unsigned);
	};

	/**
	 * Returns the difference of this and the specified Long.
	 * @param {!Long|number|string} subtrahend Subtrahend
	 * @returns {!Long} Difference
	 */
	LongPrototype.subtract = function subtract(subtrahend) {
	    if (!isLong(subtrahend))
	        subtrahend = fromValue(subtrahend);
	    return this.add(subtrahend.neg());
	};

	/**
	 * Returns the difference of this and the specified Long. This is an alias of {@link Long#subtract}.
	 * @function
	 * @param {!Long|number|string} subtrahend Subtrahend
	 * @returns {!Long} Difference
	 */
	LongPrototype.sub = LongPrototype.subtract;

	/**
	 * Returns the product of this and the specified Long.
	 * @param {!Long|number|string} multiplier Multiplier
	 * @returns {!Long} Product
	 */
	LongPrototype.multiply = function multiply(multiplier) {
	    if (this.isZero())
	        return ZERO;
	    if (!isLong(multiplier))
	        multiplier = fromValue(multiplier);

	    // use wasm support if present
	    if (wasm) {
	        var low = wasm.mul(this.low,
	                           this.high,
	                           multiplier.low,
	                           multiplier.high);
	        return fromBits(low, wasm.get_high(), this.unsigned);
	    }

	    if (multiplier.isZero())
	        return ZERO;
	    if (this.eq(MIN_VALUE))
	        return multiplier.isOdd() ? MIN_VALUE : ZERO;
	    if (multiplier.eq(MIN_VALUE))
	        return this.isOdd() ? MIN_VALUE : ZERO;

	    if (this.isNegative()) {
	        if (multiplier.isNegative())
	            return this.neg().mul(multiplier.neg());
	        else
	            return this.neg().mul(multiplier).neg();
	    } else if (multiplier.isNegative())
	        return this.mul(multiplier.neg()).neg();

	    // If both longs are small, use float multiplication
	    if (this.lt(TWO_PWR_24) && multiplier.lt(TWO_PWR_24))
	        return fromNumber(this.toNumber() * multiplier.toNumber(), this.unsigned);

	    // Divide each long into 4 chunks of 16 bits, and then add up 4x4 products.
	    // We can skip products that would overflow.

	    var a48 = this.high >>> 16;
	    var a32 = this.high & 0xFFFF;
	    var a16 = this.low >>> 16;
	    var a00 = this.low & 0xFFFF;

	    var b48 = multiplier.high >>> 16;
	    var b32 = multiplier.high & 0xFFFF;
	    var b16 = multiplier.low >>> 16;
	    var b00 = multiplier.low & 0xFFFF;

	    var c48 = 0, c32 = 0, c16 = 0, c00 = 0;
	    c00 += a00 * b00;
	    c16 += c00 >>> 16;
	    c00 &= 0xFFFF;
	    c16 += a16 * b00;
	    c32 += c16 >>> 16;
	    c16 &= 0xFFFF;
	    c16 += a00 * b16;
	    c32 += c16 >>> 16;
	    c16 &= 0xFFFF;
	    c32 += a32 * b00;
	    c48 += c32 >>> 16;
	    c32 &= 0xFFFF;
	    c32 += a16 * b16;
	    c48 += c32 >>> 16;
	    c32 &= 0xFFFF;
	    c32 += a00 * b32;
	    c48 += c32 >>> 16;
	    c32 &= 0xFFFF;
	    c48 += a48 * b00 + a32 * b16 + a16 * b32 + a00 * b48;
	    c48 &= 0xFFFF;
	    return fromBits((c16 << 16) | c00, (c48 << 16) | c32, this.unsigned);
	};

	/**
	 * Returns the product of this and the specified Long. This is an alias of {@link Long#multiply}.
	 * @function
	 * @param {!Long|number|string} multiplier Multiplier
	 * @returns {!Long} Product
	 */
	LongPrototype.mul = LongPrototype.multiply;

	/**
	 * Returns this Long divided by the specified. The result is signed if this Long is signed or
	 *  unsigned if this Long is unsigned.
	 * @param {!Long|number|string} divisor Divisor
	 * @returns {!Long} Quotient
	 */
	LongPrototype.divide = function divide(divisor) {
	    if (!isLong(divisor))
	        divisor = fromValue(divisor);
	    if (divisor.isZero())
	        throw Error('division by zero');

	    // use wasm support if present
	    if (wasm) {
	        // guard against signed division overflow: the largest
	        // negative number / -1 would be 1 larger than the largest
	        // positive number, due to two's complement.
	        if (!this.unsigned &&
	            this.high === -2147483648 &&
	            divisor.low === -1 && divisor.high === -1) {
	            // be consistent with non-wasm code path
	            return this;
	        }
	        var low = (this.unsigned ? wasm.div_u : wasm.div_s)(
	            this.low,
	            this.high,
	            divisor.low,
	            divisor.high
	        );
	        return fromBits(low, wasm.get_high(), this.unsigned);
	    }

	    if (this.isZero())
	        return this.unsigned ? UZERO : ZERO;
	    var approx, rem, res;
	    if (!this.unsigned) {
	        // This section is only relevant for signed longs and is derived from the
	        // closure library as a whole.
	        if (this.eq(MIN_VALUE)) {
	            if (divisor.eq(ONE) || divisor.eq(NEG_ONE))
	                return MIN_VALUE;  // recall that -MIN_VALUE == MIN_VALUE
	            else if (divisor.eq(MIN_VALUE))
	                return ONE;
	            else {
	                // At this point, we have |other| >= 2, so |this/other| < |MIN_VALUE|.
	                var halfThis = this.shr(1);
	                approx = halfThis.div(divisor).shl(1);
	                if (approx.eq(ZERO)) {
	                    return divisor.isNegative() ? ONE : NEG_ONE;
	                } else {
	                    rem = this.sub(divisor.mul(approx));
	                    res = approx.add(rem.div(divisor));
	                    return res;
	                }
	            }
	        } else if (divisor.eq(MIN_VALUE))
	            return this.unsigned ? UZERO : ZERO;
	        if (this.isNegative()) {
	            if (divisor.isNegative())
	                return this.neg().div(divisor.neg());
	            return this.neg().div(divisor).neg();
	        } else if (divisor.isNegative())
	            return this.div(divisor.neg()).neg();
	        res = ZERO;
	    } else {
	        // The algorithm below has not been made for unsigned longs. It's therefore
	        // required to take special care of the MSB prior to running it.
	        if (!divisor.unsigned)
	            divisor = divisor.toUnsigned();
	        if (divisor.gt(this))
	            return UZERO;
	        if (divisor.gt(this.shru(1))) // 15 >>> 1 = 7 ; with divisor = 8 ; true
	            return UONE;
	        res = UZERO;
	    }

	    // Repeat the following until the remainder is less than other:  find a
	    // floating-point that approximates remainder / other *from below*, add this
	    // into the result, and subtract it from the remainder.  It is critical that
	    // the approximate value is less than or equal to the real value so that the
	    // remainder never becomes negative.
	    rem = this;
	    while (rem.gte(divisor)) {
	        // Approximate the result of division. This may be a little greater or
	        // smaller than the actual value.
	        approx = Math.max(1, Math.floor(rem.toNumber() / divisor.toNumber()));

	        // We will tweak the approximate result by changing it in the 48-th digit or
	        // the smallest non-fractional digit, whichever is larger.
	        var log2 = Math.ceil(Math.log(approx) / Math.LN2),
	            delta = (log2 <= 48) ? 1 : pow_dbl(2, log2 - 48),

	        // Decrease the approximation until it is smaller than the remainder.  Note
	        // that if it is too large, the product overflows and is negative.
	            approxRes = fromNumber(approx),
	            approxRem = approxRes.mul(divisor);
	        while (approxRem.isNegative() || approxRem.gt(rem)) {
	            approx -= delta;
	            approxRes = fromNumber(approx, this.unsigned);
	            approxRem = approxRes.mul(divisor);
	        }

	        // We know the answer can't be zero... and actually, zero would cause
	        // infinite recursion since we would make no progress.
	        if (approxRes.isZero())
	            approxRes = ONE;

	        res = res.add(approxRes);
	        rem = rem.sub(approxRem);
	    }
	    return res;
	};

	/**
	 * Returns this Long divided by the specified. This is an alias of {@link Long#divide}.
	 * @function
	 * @param {!Long|number|string} divisor Divisor
	 * @returns {!Long} Quotient
	 */
	LongPrototype.div = LongPrototype.divide;

	/**
	 * Returns this Long modulo the specified.
	 * @param {!Long|number|string} divisor Divisor
	 * @returns {!Long} Remainder
	 */
	LongPrototype.modulo = function modulo(divisor) {
	    if (!isLong(divisor))
	        divisor = fromValue(divisor);

	    // use wasm support if present
	    if (wasm) {
	        var low = (this.unsigned ? wasm.rem_u : wasm.rem_s)(
	            this.low,
	            this.high,
	            divisor.low,
	            divisor.high
	        );
	        return fromBits(low, wasm.get_high(), this.unsigned);
	    }

	    return this.sub(this.div(divisor).mul(divisor));
	};

	/**
	 * Returns this Long modulo the specified. This is an alias of {@link Long#modulo}.
	 * @function
	 * @param {!Long|number|string} divisor Divisor
	 * @returns {!Long} Remainder
	 */
	LongPrototype.mod = LongPrototype.modulo;

	/**
	 * Returns this Long modulo the specified. This is an alias of {@link Long#modulo}.
	 * @function
	 * @param {!Long|number|string} divisor Divisor
	 * @returns {!Long} Remainder
	 */
	LongPrototype.rem = LongPrototype.modulo;

	/**
	 * Returns the bitwise NOT of this Long.
	 * @returns {!Long}
	 */
	LongPrototype.not = function not() {
	    return fromBits(~this.low, ~this.high, this.unsigned);
	};

	/**
	 * Returns the bitwise AND of this Long and the specified.
	 * @param {!Long|number|string} other Other Long
	 * @returns {!Long}
	 */
	LongPrototype.and = function and(other) {
	    if (!isLong(other))
	        other = fromValue(other);
	    return fromBits(this.low & other.low, this.high & other.high, this.unsigned);
	};

	/**
	 * Returns the bitwise OR of this Long and the specified.
	 * @param {!Long|number|string} other Other Long
	 * @returns {!Long}
	 */
	LongPrototype.or = function or(other) {
	    if (!isLong(other))
	        other = fromValue(other);
	    return fromBits(this.low | other.low, this.high | other.high, this.unsigned);
	};

	/**
	 * Returns the bitwise XOR of this Long and the given one.
	 * @param {!Long|number|string} other Other Long
	 * @returns {!Long}
	 */
	LongPrototype.xor = function xor(other) {
	    if (!isLong(other))
	        other = fromValue(other);
	    return fromBits(this.low ^ other.low, this.high ^ other.high, this.unsigned);
	};

	/**
	 * Returns this Long with bits shifted to the left by the given amount.
	 * @param {number|!Long} numBits Number of bits
	 * @returns {!Long} Shifted Long
	 */
	LongPrototype.shiftLeft = function shiftLeft(numBits) {
	    if (isLong(numBits))
	        numBits = numBits.toInt();
	    if ((numBits &= 63) === 0)
	        return this;
	    else if (numBits < 32)
	        return fromBits(this.low << numBits, (this.high << numBits) | (this.low >>> (32 - numBits)), this.unsigned);
	    else
	        return fromBits(0, this.low << (numBits - 32), this.unsigned);
	};

	/**
	 * Returns this Long with bits shifted to the left by the given amount. This is an alias of {@link Long#shiftLeft}.
	 * @function
	 * @param {number|!Long} numBits Number of bits
	 * @returns {!Long} Shifted Long
	 */
	LongPrototype.shl = LongPrototype.shiftLeft;

	/**
	 * Returns this Long with bits arithmetically shifted to the right by the given amount.
	 * @param {number|!Long} numBits Number of bits
	 * @returns {!Long} Shifted Long
	 */
	LongPrototype.shiftRight = function shiftRight(numBits) {
	    if (isLong(numBits))
	        numBits = numBits.toInt();
	    if ((numBits &= 63) === 0)
	        return this;
	    else if (numBits < 32)
	        return fromBits((this.low >>> numBits) | (this.high << (32 - numBits)), this.high >> numBits, this.unsigned);
	    else
	        return fromBits(this.high >> (numBits - 32), this.high >= 0 ? 0 : -1, this.unsigned);
	};

	/**
	 * Returns this Long with bits arithmetically shifted to the right by the given amount. This is an alias of {@link Long#shiftRight}.
	 * @function
	 * @param {number|!Long} numBits Number of bits
	 * @returns {!Long} Shifted Long
	 */
	LongPrototype.shr = LongPrototype.shiftRight;

	/**
	 * Returns this Long with bits logically shifted to the right by the given amount.
	 * @param {number|!Long} numBits Number of bits
	 * @returns {!Long} Shifted Long
	 */
	LongPrototype.shiftRightUnsigned = function shiftRightUnsigned(numBits) {
	    if (isLong(numBits))
	        numBits = numBits.toInt();
	    numBits &= 63;
	    if (numBits === 0)
	        return this;
	    else {
	        var high = this.high;
	        if (numBits < 32) {
	            var low = this.low;
	            return fromBits((low >>> numBits) | (high << (32 - numBits)), high >>> numBits, this.unsigned);
	        } else if (numBits === 32)
	            return fromBits(high, 0, this.unsigned);
	        else
	            return fromBits(high >>> (numBits - 32), 0, this.unsigned);
	    }
	};

	/**
	 * Returns this Long with bits logically shifted to the right by the given amount. This is an alias of {@link Long#shiftRightUnsigned}.
	 * @function
	 * @param {number|!Long} numBits Number of bits
	 * @returns {!Long} Shifted Long
	 */
	LongPrototype.shru = LongPrototype.shiftRightUnsigned;

	/**
	 * Returns this Long with bits logically shifted to the right by the given amount. This is an alias of {@link Long#shiftRightUnsigned}.
	 * @function
	 * @param {number|!Long} numBits Number of bits
	 * @returns {!Long} Shifted Long
	 */
	LongPrototype.shr_u = LongPrototype.shiftRightUnsigned;

	/**
	 * Converts this Long to signed.
	 * @returns {!Long} Signed long
	 */
	LongPrototype.toSigned = function toSigned() {
	    if (!this.unsigned)
	        return this;
	    return fromBits(this.low, this.high, false);
	};

	/**
	 * Converts this Long to unsigned.
	 * @returns {!Long} Unsigned long
	 */
	LongPrototype.toUnsigned = function toUnsigned() {
	    if (this.unsigned)
	        return this;
	    return fromBits(this.low, this.high, true);
	};

	/**
	 * Converts this Long to its byte representation.
	 * @param {boolean=} le Whether little or big endian, defaults to big endian
	 * @returns {!Array.<number>} Byte representation
	 */
	LongPrototype.toBytes = function toBytes(le) {
	    return le ? this.toBytesLE() : this.toBytesBE();
	};

	/**
	 * Converts this Long to its little endian byte representation.
	 * @returns {!Array.<number>} Little endian byte representation
	 */
	LongPrototype.toBytesLE = function toBytesLE() {
	    var hi = this.high,
	        lo = this.low;
	    return [
	        lo        & 0xff,
	        lo >>>  8 & 0xff,
	        lo >>> 16 & 0xff,
	        lo >>> 24       ,
	        hi        & 0xff,
	        hi >>>  8 & 0xff,
	        hi >>> 16 & 0xff,
	        hi >>> 24
	    ];
	};

	/**
	 * Converts this Long to its big endian byte representation.
	 * @returns {!Array.<number>} Big endian byte representation
	 */
	LongPrototype.toBytesBE = function toBytesBE() {
	    var hi = this.high,
	        lo = this.low;
	    return [
	        hi >>> 24       ,
	        hi >>> 16 & 0xff,
	        hi >>>  8 & 0xff,
	        hi        & 0xff,
	        lo >>> 24       ,
	        lo >>> 16 & 0xff,
	        lo >>>  8 & 0xff,
	        lo        & 0xff
	    ];
	};

	/**
	 * Creates a Long from its byte representation.
	 * @param {!Array.<number>} bytes Byte representation
	 * @param {boolean=} unsigned Whether unsigned or not, defaults to signed
	 * @param {boolean=} le Whether little or big endian, defaults to big endian
	 * @returns {Long} The corresponding Long value
	 */
	Long.fromBytes = function fromBytes(bytes, unsigned, le) {
	    return le ? Long.fromBytesLE(bytes, unsigned) : Long.fromBytesBE(bytes, unsigned);
	};

	/**
	 * Creates a Long from its little endian byte representation.
	 * @param {!Array.<number>} bytes Little endian byte representation
	 * @param {boolean=} unsigned Whether unsigned or not, defaults to signed
	 * @returns {Long} The corresponding Long value
	 */
	Long.fromBytesLE = function fromBytesLE(bytes, unsigned) {
	    return new Long(
	        bytes[0]       |
	        bytes[1] <<  8 |
	        bytes[2] << 16 |
	        bytes[3] << 24,
	        bytes[4]       |
	        bytes[5] <<  8 |
	        bytes[6] << 16 |
	        bytes[7] << 24,
	        unsigned
	    );
	};

	/**
	 * Creates a Long from its big endian byte representation.
	 * @param {!Array.<number>} bytes Big endian byte representation
	 * @param {boolean=} unsigned Whether unsigned or not, defaults to signed
	 * @returns {Long} The corresponding Long value
	 */
	Long.fromBytesBE = function fromBytesBE(bytes, unsigned) {
	    return new Long(
	        bytes[4] << 24 |
	        bytes[5] << 16 |
	        bytes[6] <<  8 |
	        bytes[7],
	        bytes[0] << 24 |
	        bytes[1] << 16 |
	        bytes[2] <<  8 |
	        bytes[3],
	        unsigned
	    );
	};

	var global$1 = (typeof global !== "undefined" ? global :
	            typeof self !== "undefined" ? self :
	            typeof window !== "undefined" ? window : {});

	var lookup = [];
	var revLookup = [];
	var Arr = typeof Uint8Array !== 'undefined' ? Uint8Array : Array;
	var inited = false;
	function init$1 () {
	  inited = true;
	  var code = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	  for (var i = 0, len = code.length; i < len; ++i) {
	    lookup[i] = code[i];
	    revLookup[code.charCodeAt(i)] = i;
	  }

	  revLookup['-'.charCodeAt(0)] = 62;
	  revLookup['_'.charCodeAt(0)] = 63;
	}

	function toByteArray (b64) {
	  if (!inited) {
	    init$1();
	  }
	  var i, j, l, tmp, placeHolders, arr;
	  var len = b64.length;

	  if (len % 4 > 0) {
	    throw new Error('Invalid string. Length must be a multiple of 4')
	  }

	  // the number of equal signs (place holders)
	  // if there are two placeholders, than the two characters before it
	  // represent one byte
	  // if there is only one, then the three characters before it represent 2 bytes
	  // this is just a cheap hack to not do indexOf twice
	  placeHolders = b64[len - 2] === '=' ? 2 : b64[len - 1] === '=' ? 1 : 0;

	  // base64 is 4/3 + up to two characters of the original data
	  arr = new Arr(len * 3 / 4 - placeHolders);

	  // if there are placeholders, only get up to the last complete 4 chars
	  l = placeHolders > 0 ? len - 4 : len;

	  var L = 0;

	  for (i = 0, j = 0; i < l; i += 4, j += 3) {
	    tmp = (revLookup[b64.charCodeAt(i)] << 18) | (revLookup[b64.charCodeAt(i + 1)] << 12) | (revLookup[b64.charCodeAt(i + 2)] << 6) | revLookup[b64.charCodeAt(i + 3)];
	    arr[L++] = (tmp >> 16) & 0xFF;
	    arr[L++] = (tmp >> 8) & 0xFF;
	    arr[L++] = tmp & 0xFF;
	  }

	  if (placeHolders === 2) {
	    tmp = (revLookup[b64.charCodeAt(i)] << 2) | (revLookup[b64.charCodeAt(i + 1)] >> 4);
	    arr[L++] = tmp & 0xFF;
	  } else if (placeHolders === 1) {
	    tmp = (revLookup[b64.charCodeAt(i)] << 10) | (revLookup[b64.charCodeAt(i + 1)] << 4) | (revLookup[b64.charCodeAt(i + 2)] >> 2);
	    arr[L++] = (tmp >> 8) & 0xFF;
	    arr[L++] = tmp & 0xFF;
	  }

	  return arr
	}

	function tripletToBase64 (num) {
	  return lookup[num >> 18 & 0x3F] + lookup[num >> 12 & 0x3F] + lookup[num >> 6 & 0x3F] + lookup[num & 0x3F]
	}

	function encodeChunk (uint8, start, end) {
	  var tmp;
	  var output = [];
	  for (var i = start; i < end; i += 3) {
	    tmp = (uint8[i] << 16) + (uint8[i + 1] << 8) + (uint8[i + 2]);
	    output.push(tripletToBase64(tmp));
	  }
	  return output.join('')
	}

	function fromByteArray (uint8) {
	  if (!inited) {
	    init$1();
	  }
	  var tmp;
	  var len = uint8.length;
	  var extraBytes = len % 3; // if we have 1 byte left, pad 2 bytes
	  var output = '';
	  var parts = [];
	  var maxChunkLength = 16383; // must be multiple of 3

	  // go through the array every three bytes, we'll deal with trailing stuff later
	  for (var i = 0, len2 = len - extraBytes; i < len2; i += maxChunkLength) {
	    parts.push(encodeChunk(uint8, i, (i + maxChunkLength) > len2 ? len2 : (i + maxChunkLength)));
	  }

	  // pad the end with zeros, but make sure to not forget the extra bytes
	  if (extraBytes === 1) {
	    tmp = uint8[len - 1];
	    output += lookup[tmp >> 2];
	    output += lookup[(tmp << 4) & 0x3F];
	    output += '==';
	  } else if (extraBytes === 2) {
	    tmp = (uint8[len - 2] << 8) + (uint8[len - 1]);
	    output += lookup[tmp >> 10];
	    output += lookup[(tmp >> 4) & 0x3F];
	    output += lookup[(tmp << 2) & 0x3F];
	    output += '=';
	  }

	  parts.push(output);

	  return parts.join('')
	}

	function read (buffer, offset, isLE, mLen, nBytes) {
	  var e, m;
	  var eLen = nBytes * 8 - mLen - 1;
	  var eMax = (1 << eLen) - 1;
	  var eBias = eMax >> 1;
	  var nBits = -7;
	  var i = isLE ? (nBytes - 1) : 0;
	  var d = isLE ? -1 : 1;
	  var s = buffer[offset + i];

	  i += d;

	  e = s & ((1 << (-nBits)) - 1);
	  s >>= (-nBits);
	  nBits += eLen;
	  for (; nBits > 0; e = e * 256 + buffer[offset + i], i += d, nBits -= 8) {}

	  m = e & ((1 << (-nBits)) - 1);
	  e >>= (-nBits);
	  nBits += mLen;
	  for (; nBits > 0; m = m * 256 + buffer[offset + i], i += d, nBits -= 8) {}

	  if (e === 0) {
	    e = 1 - eBias;
	  } else if (e === eMax) {
	    return m ? NaN : ((s ? -1 : 1) * Infinity)
	  } else {
	    m = m + Math.pow(2, mLen);
	    e = e - eBias;
	  }
	  return (s ? -1 : 1) * m * Math.pow(2, e - mLen)
	}

	function write (buffer, value, offset, isLE, mLen, nBytes) {
	  var e, m, c;
	  var eLen = nBytes * 8 - mLen - 1;
	  var eMax = (1 << eLen) - 1;
	  var eBias = eMax >> 1;
	  var rt = (mLen === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0);
	  var i = isLE ? 0 : (nBytes - 1);
	  var d = isLE ? 1 : -1;
	  var s = value < 0 || (value === 0 && 1 / value < 0) ? 1 : 0;

	  value = Math.abs(value);

	  if (isNaN(value) || value === Infinity) {
	    m = isNaN(value) ? 1 : 0;
	    e = eMax;
	  } else {
	    e = Math.floor(Math.log(value) / Math.LN2);
	    if (value * (c = Math.pow(2, -e)) < 1) {
	      e--;
	      c *= 2;
	    }
	    if (e + eBias >= 1) {
	      value += rt / c;
	    } else {
	      value += rt * Math.pow(2, 1 - eBias);
	    }
	    if (value * c >= 2) {
	      e++;
	      c /= 2;
	    }

	    if (e + eBias >= eMax) {
	      m = 0;
	      e = eMax;
	    } else if (e + eBias >= 1) {
	      m = (value * c - 1) * Math.pow(2, mLen);
	      e = e + eBias;
	    } else {
	      m = value * Math.pow(2, eBias - 1) * Math.pow(2, mLen);
	      e = 0;
	    }
	  }

	  for (; mLen >= 8; buffer[offset + i] = m & 0xff, i += d, m /= 256, mLen -= 8) {}

	  e = (e << mLen) | m;
	  eLen += mLen;
	  for (; eLen > 0; buffer[offset + i] = e & 0xff, i += d, e /= 256, eLen -= 8) {}

	  buffer[offset + i - d] |= s * 128;
	}

	var toString = {}.toString;

	var isArray$1 = Array.isArray || function (arr) {
	  return toString.call(arr) == '[object Array]';
	};

	var INSPECT_MAX_BYTES = 50;

	/**
	 * If `Buffer.TYPED_ARRAY_SUPPORT`:
	 *   === true    Use Uint8Array implementation (fastest)
	 *   === false   Use Object implementation (most compatible, even IE6)
	 *
	 * Browsers that support typed arrays are IE 10+, Firefox 4+, Chrome 7+, Safari 5.1+,
	 * Opera 11.6+, iOS 4.2+.
	 *
	 * Due to various browser bugs, sometimes the Object implementation will be used even
	 * when the browser supports typed arrays.
	 *
	 * Note:
	 *
	 *   - Firefox 4-29 lacks support for adding new properties to `Uint8Array` instances,
	 *     See: https://bugzilla.mozilla.org/show_bug.cgi?id=695438.
	 *
	 *   - Chrome 9-10 is missing the `TypedArray.prototype.subarray` function.
	 *
	 *   - IE10 has a broken `TypedArray.prototype.subarray` function which returns arrays of
	 *     incorrect length in some situations.

	 * We detect these buggy browsers and set `Buffer.TYPED_ARRAY_SUPPORT` to `false` so they
	 * get the Object implementation, which is slower but behaves correctly.
	 */
	Buffer$1.TYPED_ARRAY_SUPPORT = global$1.TYPED_ARRAY_SUPPORT !== undefined
	  ? global$1.TYPED_ARRAY_SUPPORT
	  : true;

	/*
	 * Export kMaxLength after typed array support is determined.
	 */
	kMaxLength();

	function kMaxLength () {
	  return Buffer$1.TYPED_ARRAY_SUPPORT
	    ? 0x7fffffff
	    : 0x3fffffff
	}

	function createBuffer (that, length) {
	  if (kMaxLength() < length) {
	    throw new RangeError('Invalid typed array length')
	  }
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    // Return an augmented `Uint8Array` instance, for best performance
	    that = new Uint8Array(length);
	    that.__proto__ = Buffer$1.prototype;
	  } else {
	    // Fallback: Return an object instance of the Buffer class
	    if (that === null) {
	      that = new Buffer$1(length);
	    }
	    that.length = length;
	  }

	  return that
	}

	/**
	 * The Buffer constructor returns instances of `Uint8Array` that have their
	 * prototype changed to `Buffer.prototype`. Furthermore, `Buffer` is a subclass of
	 * `Uint8Array`, so the returned instances will have all the node `Buffer` methods
	 * and the `Uint8Array` methods. Square bracket notation works as expected -- it
	 * returns a single octet.
	 *
	 * The `Uint8Array` prototype remains unmodified.
	 */

	function Buffer$1 (arg, encodingOrOffset, length) {
	  if (!Buffer$1.TYPED_ARRAY_SUPPORT && !(this instanceof Buffer$1)) {
	    return new Buffer$1(arg, encodingOrOffset, length)
	  }

	  // Common case.
	  if (typeof arg === 'number') {
	    if (typeof encodingOrOffset === 'string') {
	      throw new Error(
	        'If encoding is specified then the first argument must be a string'
	      )
	    }
	    return allocUnsafe(this, arg)
	  }
	  return from(this, arg, encodingOrOffset, length)
	}

	Buffer$1.poolSize = 8192; // not used by this implementation

	// TODO: Legacy, not needed anymore. Remove in next major version.
	Buffer$1._augment = function (arr) {
	  arr.__proto__ = Buffer$1.prototype;
	  return arr
	};

	function from (that, value, encodingOrOffset, length) {
	  if (typeof value === 'number') {
	    throw new TypeError('"value" argument must not be a number')
	  }

	  if (typeof ArrayBuffer !== 'undefined' && value instanceof ArrayBuffer) {
	    return fromArrayBuffer(that, value, encodingOrOffset, length)
	  }

	  if (typeof value === 'string') {
	    return fromString(that, value, encodingOrOffset)
	  }

	  return fromObject(that, value)
	}

	/**
	 * Functionally equivalent to Buffer(arg, encoding) but throws a TypeError
	 * if value is a number.
	 * Buffer.from(str[, encoding])
	 * Buffer.from(array)
	 * Buffer.from(buffer)
	 * Buffer.from(arrayBuffer[, byteOffset[, length]])
	 **/
	Buffer$1.from = function (value, encodingOrOffset, length) {
	  return from(null, value, encodingOrOffset, length)
	};

	if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	  Buffer$1.prototype.__proto__ = Uint8Array.prototype;
	  Buffer$1.__proto__ = Uint8Array;
	  if (typeof Symbol !== 'undefined' && Symbol.species &&
	      Buffer$1[Symbol.species] === Buffer$1) ;
	}

	function assertSize (size) {
	  if (typeof size !== 'number') {
	    throw new TypeError('"size" argument must be a number')
	  } else if (size < 0) {
	    throw new RangeError('"size" argument must not be negative')
	  }
	}

	function alloc (that, size, fill, encoding) {
	  assertSize(size);
	  if (size <= 0) {
	    return createBuffer(that, size)
	  }
	  if (fill !== undefined) {
	    // Only pay attention to encoding if it's a string. This
	    // prevents accidentally sending in a number that would
	    // be interpretted as a start offset.
	    return typeof encoding === 'string'
	      ? createBuffer(that, size).fill(fill, encoding)
	      : createBuffer(that, size).fill(fill)
	  }
	  return createBuffer(that, size)
	}

	/**
	 * Creates a new filled Buffer instance.
	 * alloc(size[, fill[, encoding]])
	 **/
	Buffer$1.alloc = function (size, fill, encoding) {
	  return alloc(null, size, fill, encoding)
	};

	function allocUnsafe (that, size) {
	  assertSize(size);
	  that = createBuffer(that, size < 0 ? 0 : checked(size) | 0);
	  if (!Buffer$1.TYPED_ARRAY_SUPPORT) {
	    for (var i = 0; i < size; ++i) {
	      that[i] = 0;
	    }
	  }
	  return that
	}

	/**
	 * Equivalent to Buffer(num), by default creates a non-zero-filled Buffer instance.
	 * */
	Buffer$1.allocUnsafe = function (size) {
	  return allocUnsafe(null, size)
	};
	/**
	 * Equivalent to SlowBuffer(num), by default creates a non-zero-filled Buffer instance.
	 */
	Buffer$1.allocUnsafeSlow = function (size) {
	  return allocUnsafe(null, size)
	};

	function fromString (that, string, encoding) {
	  if (typeof encoding !== 'string' || encoding === '') {
	    encoding = 'utf8';
	  }

	  if (!Buffer$1.isEncoding(encoding)) {
	    throw new TypeError('"encoding" must be a valid string encoding')
	  }

	  var length = byteLength(string, encoding) | 0;
	  that = createBuffer(that, length);

	  var actual = that.write(string, encoding);

	  if (actual !== length) {
	    // Writing a hex string, for example, that contains invalid characters will
	    // cause everything after the first invalid character to be ignored. (e.g.
	    // 'abxxcd' will be treated as 'ab')
	    that = that.slice(0, actual);
	  }

	  return that
	}

	function fromArrayLike (that, array) {
	  var length = array.length < 0 ? 0 : checked(array.length) | 0;
	  that = createBuffer(that, length);
	  for (var i = 0; i < length; i += 1) {
	    that[i] = array[i] & 255;
	  }
	  return that
	}

	function fromArrayBuffer (that, array, byteOffset, length) {
	  array.byteLength; // this throws if `array` is not a valid ArrayBuffer

	  if (byteOffset < 0 || array.byteLength < byteOffset) {
	    throw new RangeError('\'offset\' is out of bounds')
	  }

	  if (array.byteLength < byteOffset + (length || 0)) {
	    throw new RangeError('\'length\' is out of bounds')
	  }

	  if (byteOffset === undefined && length === undefined) {
	    array = new Uint8Array(array);
	  } else if (length === undefined) {
	    array = new Uint8Array(array, byteOffset);
	  } else {
	    array = new Uint8Array(array, byteOffset, length);
	  }

	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    // Return an augmented `Uint8Array` instance, for best performance
	    that = array;
	    that.__proto__ = Buffer$1.prototype;
	  } else {
	    // Fallback: Return an object instance of the Buffer class
	    that = fromArrayLike(that, array);
	  }
	  return that
	}

	function fromObject (that, obj) {
	  if (internalIsBuffer(obj)) {
	    var len = checked(obj.length) | 0;
	    that = createBuffer(that, len);

	    if (that.length === 0) {
	      return that
	    }

	    obj.copy(that, 0, 0, len);
	    return that
	  }

	  if (obj) {
	    if ((typeof ArrayBuffer !== 'undefined' &&
	        obj.buffer instanceof ArrayBuffer) || 'length' in obj) {
	      if (typeof obj.length !== 'number' || isnan(obj.length)) {
	        return createBuffer(that, 0)
	      }
	      return fromArrayLike(that, obj)
	    }

	    if (obj.type === 'Buffer' && isArray$1(obj.data)) {
	      return fromArrayLike(that, obj.data)
	    }
	  }

	  throw new TypeError('First argument must be a string, Buffer, ArrayBuffer, Array, or array-like object.')
	}

	function checked (length) {
	  // Note: cannot use `length < kMaxLength()` here because that fails when
	  // length is NaN (which is otherwise coerced to zero.)
	  if (length >= kMaxLength()) {
	    throw new RangeError('Attempt to allocate Buffer larger than maximum ' +
	                         'size: 0x' + kMaxLength().toString(16) + ' bytes')
	  }
	  return length | 0
	}
	Buffer$1.isBuffer = isBuffer$1;
	function internalIsBuffer (b) {
	  return !!(b != null && b._isBuffer)
	}

	Buffer$1.compare = function compare (a, b) {
	  if (!internalIsBuffer(a) || !internalIsBuffer(b)) {
	    throw new TypeError('Arguments must be Buffers')
	  }

	  if (a === b) return 0

	  var x = a.length;
	  var y = b.length;

	  for (var i = 0, len = Math.min(x, y); i < len; ++i) {
	    if (a[i] !== b[i]) {
	      x = a[i];
	      y = b[i];
	      break
	    }
	  }

	  if (x < y) return -1
	  if (y < x) return 1
	  return 0
	};

	Buffer$1.isEncoding = function isEncoding (encoding) {
	  switch (String(encoding).toLowerCase()) {
	    case 'hex':
	    case 'utf8':
	    case 'utf-8':
	    case 'ascii':
	    case 'latin1':
	    case 'binary':
	    case 'base64':
	    case 'ucs2':
	    case 'ucs-2':
	    case 'utf16le':
	    case 'utf-16le':
	      return true
	    default:
	      return false
	  }
	};

	Buffer$1.concat = function concat (list, length) {
	  if (!isArray$1(list)) {
	    throw new TypeError('"list" argument must be an Array of Buffers')
	  }

	  if (list.length === 0) {
	    return Buffer$1.alloc(0)
	  }

	  var i;
	  if (length === undefined) {
	    length = 0;
	    for (i = 0; i < list.length; ++i) {
	      length += list[i].length;
	    }
	  }

	  var buffer = Buffer$1.allocUnsafe(length);
	  var pos = 0;
	  for (i = 0; i < list.length; ++i) {
	    var buf = list[i];
	    if (!internalIsBuffer(buf)) {
	      throw new TypeError('"list" argument must be an Array of Buffers')
	    }
	    buf.copy(buffer, pos);
	    pos += buf.length;
	  }
	  return buffer
	};

	function byteLength (string, encoding) {
	  if (internalIsBuffer(string)) {
	    return string.length
	  }
	  if (typeof ArrayBuffer !== 'undefined' && typeof ArrayBuffer.isView === 'function' &&
	      (ArrayBuffer.isView(string) || string instanceof ArrayBuffer)) {
	    return string.byteLength
	  }
	  if (typeof string !== 'string') {
	    string = '' + string;
	  }

	  var len = string.length;
	  if (len === 0) return 0

	  // Use a for loop to avoid recursion
	  var loweredCase = false;
	  for (;;) {
	    switch (encoding) {
	      case 'ascii':
	      case 'latin1':
	      case 'binary':
	        return len
	      case 'utf8':
	      case 'utf-8':
	      case undefined:
	        return utf8ToBytes(string).length
	      case 'ucs2':
	      case 'ucs-2':
	      case 'utf16le':
	      case 'utf-16le':
	        return len * 2
	      case 'hex':
	        return len >>> 1
	      case 'base64':
	        return base64ToBytes(string).length
	      default:
	        if (loweredCase) return utf8ToBytes(string).length // assume utf8
	        encoding = ('' + encoding).toLowerCase();
	        loweredCase = true;
	    }
	  }
	}
	Buffer$1.byteLength = byteLength;

	function slowToString (encoding, start, end) {
	  var loweredCase = false;

	  // No need to verify that "this.length <= MAX_UINT32" since it's a read-only
	  // property of a typed array.

	  // This behaves neither like String nor Uint8Array in that we set start/end
	  // to their upper/lower bounds if the value passed is out of range.
	  // undefined is handled specially as per ECMA-262 6th Edition,
	  // Section 13.3.3.7 Runtime Semantics: KeyedBindingInitialization.
	  if (start === undefined || start < 0) {
	    start = 0;
	  }
	  // Return early if start > this.length. Done here to prevent potential uint32
	  // coercion fail below.
	  if (start > this.length) {
	    return ''
	  }

	  if (end === undefined || end > this.length) {
	    end = this.length;
	  }

	  if (end <= 0) {
	    return ''
	  }

	  // Force coersion to uint32. This will also coerce falsey/NaN values to 0.
	  end >>>= 0;
	  start >>>= 0;

	  if (end <= start) {
	    return ''
	  }

	  if (!encoding) encoding = 'utf8';

	  while (true) {
	    switch (encoding) {
	      case 'hex':
	        return hexSlice(this, start, end)

	      case 'utf8':
	      case 'utf-8':
	        return utf8Slice(this, start, end)

	      case 'ascii':
	        return asciiSlice(this, start, end)

	      case 'latin1':
	      case 'binary':
	        return latin1Slice(this, start, end)

	      case 'base64':
	        return base64Slice(this, start, end)

	      case 'ucs2':
	      case 'ucs-2':
	      case 'utf16le':
	      case 'utf-16le':
	        return utf16leSlice(this, start, end)

	      default:
	        if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
	        encoding = (encoding + '').toLowerCase();
	        loweredCase = true;
	    }
	  }
	}

	// The property is used by `Buffer.isBuffer` and `is-buffer` (in Safari 5-7) to detect
	// Buffer instances.
	Buffer$1.prototype._isBuffer = true;

	function swap (b, n, m) {
	  var i = b[n];
	  b[n] = b[m];
	  b[m] = i;
	}

	Buffer$1.prototype.swap16 = function swap16 () {
	  var len = this.length;
	  if (len % 2 !== 0) {
	    throw new RangeError('Buffer size must be a multiple of 16-bits')
	  }
	  for (var i = 0; i < len; i += 2) {
	    swap(this, i, i + 1);
	  }
	  return this
	};

	Buffer$1.prototype.swap32 = function swap32 () {
	  var len = this.length;
	  if (len % 4 !== 0) {
	    throw new RangeError('Buffer size must be a multiple of 32-bits')
	  }
	  for (var i = 0; i < len; i += 4) {
	    swap(this, i, i + 3);
	    swap(this, i + 1, i + 2);
	  }
	  return this
	};

	Buffer$1.prototype.swap64 = function swap64 () {
	  var len = this.length;
	  if (len % 8 !== 0) {
	    throw new RangeError('Buffer size must be a multiple of 64-bits')
	  }
	  for (var i = 0; i < len; i += 8) {
	    swap(this, i, i + 7);
	    swap(this, i + 1, i + 6);
	    swap(this, i + 2, i + 5);
	    swap(this, i + 3, i + 4);
	  }
	  return this
	};

	Buffer$1.prototype.toString = function toString () {
	  var length = this.length | 0;
	  if (length === 0) return ''
	  if (arguments.length === 0) return utf8Slice(this, 0, length)
	  return slowToString.apply(this, arguments)
	};

	Buffer$1.prototype.equals = function equals (b) {
	  if (!internalIsBuffer(b)) throw new TypeError('Argument must be a Buffer')
	  if (this === b) return true
	  return Buffer$1.compare(this, b) === 0
	};

	Buffer$1.prototype.inspect = function inspect () {
	  var str = '';
	  var max = INSPECT_MAX_BYTES;
	  if (this.length > 0) {
	    str = this.toString('hex', 0, max).match(/.{2}/g).join(' ');
	    if (this.length > max) str += ' ... ';
	  }
	  return '<Buffer ' + str + '>'
	};

	Buffer$1.prototype.compare = function compare (target, start, end, thisStart, thisEnd) {
	  if (!internalIsBuffer(target)) {
	    throw new TypeError('Argument must be a Buffer')
	  }

	  if (start === undefined) {
	    start = 0;
	  }
	  if (end === undefined) {
	    end = target ? target.length : 0;
	  }
	  if (thisStart === undefined) {
	    thisStart = 0;
	  }
	  if (thisEnd === undefined) {
	    thisEnd = this.length;
	  }

	  if (start < 0 || end > target.length || thisStart < 0 || thisEnd > this.length) {
	    throw new RangeError('out of range index')
	  }

	  if (thisStart >= thisEnd && start >= end) {
	    return 0
	  }
	  if (thisStart >= thisEnd) {
	    return -1
	  }
	  if (start >= end) {
	    return 1
	  }

	  start >>>= 0;
	  end >>>= 0;
	  thisStart >>>= 0;
	  thisEnd >>>= 0;

	  if (this === target) return 0

	  var x = thisEnd - thisStart;
	  var y = end - start;
	  var len = Math.min(x, y);

	  var thisCopy = this.slice(thisStart, thisEnd);
	  var targetCopy = target.slice(start, end);

	  for (var i = 0; i < len; ++i) {
	    if (thisCopy[i] !== targetCopy[i]) {
	      x = thisCopy[i];
	      y = targetCopy[i];
	      break
	    }
	  }

	  if (x < y) return -1
	  if (y < x) return 1
	  return 0
	};

	// Finds either the first index of `val` in `buffer` at offset >= `byteOffset`,
	// OR the last index of `val` in `buffer` at offset <= `byteOffset`.
	//
	// Arguments:
	// - buffer - a Buffer to search
	// - val - a string, Buffer, or number
	// - byteOffset - an index into `buffer`; will be clamped to an int32
	// - encoding - an optional encoding, relevant is val is a string
	// - dir - true for indexOf, false for lastIndexOf
	function bidirectionalIndexOf (buffer, val, byteOffset, encoding, dir) {
	  // Empty buffer means no match
	  if (buffer.length === 0) return -1

	  // Normalize byteOffset
	  if (typeof byteOffset === 'string') {
	    encoding = byteOffset;
	    byteOffset = 0;
	  } else if (byteOffset > 0x7fffffff) {
	    byteOffset = 0x7fffffff;
	  } else if (byteOffset < -2147483648) {
	    byteOffset = -2147483648;
	  }
	  byteOffset = +byteOffset;  // Coerce to Number.
	  if (isNaN(byteOffset)) {
	    // byteOffset: it it's undefined, null, NaN, "foo", etc, search whole buffer
	    byteOffset = dir ? 0 : (buffer.length - 1);
	  }

	  // Normalize byteOffset: negative offsets start from the end of the buffer
	  if (byteOffset < 0) byteOffset = buffer.length + byteOffset;
	  if (byteOffset >= buffer.length) {
	    if (dir) return -1
	    else byteOffset = buffer.length - 1;
	  } else if (byteOffset < 0) {
	    if (dir) byteOffset = 0;
	    else return -1
	  }

	  // Normalize val
	  if (typeof val === 'string') {
	    val = Buffer$1.from(val, encoding);
	  }

	  // Finally, search either indexOf (if dir is true) or lastIndexOf
	  if (internalIsBuffer(val)) {
	    // Special case: looking for empty string/buffer always fails
	    if (val.length === 0) {
	      return -1
	    }
	    return arrayIndexOf(buffer, val, byteOffset, encoding, dir)
	  } else if (typeof val === 'number') {
	    val = val & 0xFF; // Search for a byte value [0-255]
	    if (Buffer$1.TYPED_ARRAY_SUPPORT &&
	        typeof Uint8Array.prototype.indexOf === 'function') {
	      if (dir) {
	        return Uint8Array.prototype.indexOf.call(buffer, val, byteOffset)
	      } else {
	        return Uint8Array.prototype.lastIndexOf.call(buffer, val, byteOffset)
	      }
	    }
	    return arrayIndexOf(buffer, [ val ], byteOffset, encoding, dir)
	  }

	  throw new TypeError('val must be string, number or Buffer')
	}

	function arrayIndexOf (arr, val, byteOffset, encoding, dir) {
	  var indexSize = 1;
	  var arrLength = arr.length;
	  var valLength = val.length;

	  if (encoding !== undefined) {
	    encoding = String(encoding).toLowerCase();
	    if (encoding === 'ucs2' || encoding === 'ucs-2' ||
	        encoding === 'utf16le' || encoding === 'utf-16le') {
	      if (arr.length < 2 || val.length < 2) {
	        return -1
	      }
	      indexSize = 2;
	      arrLength /= 2;
	      valLength /= 2;
	      byteOffset /= 2;
	    }
	  }

	  function read (buf, i) {
	    if (indexSize === 1) {
	      return buf[i]
	    } else {
	      return buf.readUInt16BE(i * indexSize)
	    }
	  }

	  var i;
	  if (dir) {
	    var foundIndex = -1;
	    for (i = byteOffset; i < arrLength; i++) {
	      if (read(arr, i) === read(val, foundIndex === -1 ? 0 : i - foundIndex)) {
	        if (foundIndex === -1) foundIndex = i;
	        if (i - foundIndex + 1 === valLength) return foundIndex * indexSize
	      } else {
	        if (foundIndex !== -1) i -= i - foundIndex;
	        foundIndex = -1;
	      }
	    }
	  } else {
	    if (byteOffset + valLength > arrLength) byteOffset = arrLength - valLength;
	    for (i = byteOffset; i >= 0; i--) {
	      var found = true;
	      for (var j = 0; j < valLength; j++) {
	        if (read(arr, i + j) !== read(val, j)) {
	          found = false;
	          break
	        }
	      }
	      if (found) return i
	    }
	  }

	  return -1
	}

	Buffer$1.prototype.includes = function includes (val, byteOffset, encoding) {
	  return this.indexOf(val, byteOffset, encoding) !== -1
	};

	Buffer$1.prototype.indexOf = function indexOf (val, byteOffset, encoding) {
	  return bidirectionalIndexOf(this, val, byteOffset, encoding, true)
	};

	Buffer$1.prototype.lastIndexOf = function lastIndexOf (val, byteOffset, encoding) {
	  return bidirectionalIndexOf(this, val, byteOffset, encoding, false)
	};

	function hexWrite (buf, string, offset, length) {
	  offset = Number(offset) || 0;
	  var remaining = buf.length - offset;
	  if (!length) {
	    length = remaining;
	  } else {
	    length = Number(length);
	    if (length > remaining) {
	      length = remaining;
	    }
	  }

	  // must be an even number of digits
	  var strLen = string.length;
	  if (strLen % 2 !== 0) throw new TypeError('Invalid hex string')

	  if (length > strLen / 2) {
	    length = strLen / 2;
	  }
	  for (var i = 0; i < length; ++i) {
	    var parsed = parseInt(string.substr(i * 2, 2), 16);
	    if (isNaN(parsed)) return i
	    buf[offset + i] = parsed;
	  }
	  return i
	}

	function utf8Write (buf, string, offset, length) {
	  return blitBuffer(utf8ToBytes(string, buf.length - offset), buf, offset, length)
	}

	function asciiWrite (buf, string, offset, length) {
	  return blitBuffer(asciiToBytes(string), buf, offset, length)
	}

	function latin1Write (buf, string, offset, length) {
	  return asciiWrite(buf, string, offset, length)
	}

	function base64Write (buf, string, offset, length) {
	  return blitBuffer(base64ToBytes(string), buf, offset, length)
	}

	function ucs2Write (buf, string, offset, length) {
	  return blitBuffer(utf16leToBytes(string, buf.length - offset), buf, offset, length)
	}

	Buffer$1.prototype.write = function write (string, offset, length, encoding) {
	  // Buffer#write(string)
	  if (offset === undefined) {
	    encoding = 'utf8';
	    length = this.length;
	    offset = 0;
	  // Buffer#write(string, encoding)
	  } else if (length === undefined && typeof offset === 'string') {
	    encoding = offset;
	    length = this.length;
	    offset = 0;
	  // Buffer#write(string, offset[, length][, encoding])
	  } else if (isFinite(offset)) {
	    offset = offset | 0;
	    if (isFinite(length)) {
	      length = length | 0;
	      if (encoding === undefined) encoding = 'utf8';
	    } else {
	      encoding = length;
	      length = undefined;
	    }
	  // legacy write(string, encoding, offset, length) - remove in v0.13
	  } else {
	    throw new Error(
	      'Buffer.write(string, encoding, offset[, length]) is no longer supported'
	    )
	  }

	  var remaining = this.length - offset;
	  if (length === undefined || length > remaining) length = remaining;

	  if ((string.length > 0 && (length < 0 || offset < 0)) || offset > this.length) {
	    throw new RangeError('Attempt to write outside buffer bounds')
	  }

	  if (!encoding) encoding = 'utf8';

	  var loweredCase = false;
	  for (;;) {
	    switch (encoding) {
	      case 'hex':
	        return hexWrite(this, string, offset, length)

	      case 'utf8':
	      case 'utf-8':
	        return utf8Write(this, string, offset, length)

	      case 'ascii':
	        return asciiWrite(this, string, offset, length)

	      case 'latin1':
	      case 'binary':
	        return latin1Write(this, string, offset, length)

	      case 'base64':
	        // Warning: maxLength not taken into account in base64Write
	        return base64Write(this, string, offset, length)

	      case 'ucs2':
	      case 'ucs-2':
	      case 'utf16le':
	      case 'utf-16le':
	        return ucs2Write(this, string, offset, length)

	      default:
	        if (loweredCase) throw new TypeError('Unknown encoding: ' + encoding)
	        encoding = ('' + encoding).toLowerCase();
	        loweredCase = true;
	    }
	  }
	};

	Buffer$1.prototype.toJSON = function toJSON () {
	  return {
	    type: 'Buffer',
	    data: Array.prototype.slice.call(this._arr || this, 0)
	  }
	};

	function base64Slice (buf, start, end) {
	  if (start === 0 && end === buf.length) {
	    return fromByteArray(buf)
	  } else {
	    return fromByteArray(buf.slice(start, end))
	  }
	}

	function utf8Slice (buf, start, end) {
	  end = Math.min(buf.length, end);
	  var res = [];

	  var i = start;
	  while (i < end) {
	    var firstByte = buf[i];
	    var codePoint = null;
	    var bytesPerSequence = (firstByte > 0xEF) ? 4
	      : (firstByte > 0xDF) ? 3
	      : (firstByte > 0xBF) ? 2
	      : 1;

	    if (i + bytesPerSequence <= end) {
	      var secondByte, thirdByte, fourthByte, tempCodePoint;

	      switch (bytesPerSequence) {
	        case 1:
	          if (firstByte < 0x80) {
	            codePoint = firstByte;
	          }
	          break
	        case 2:
	          secondByte = buf[i + 1];
	          if ((secondByte & 0xC0) === 0x80) {
	            tempCodePoint = (firstByte & 0x1F) << 0x6 | (secondByte & 0x3F);
	            if (tempCodePoint > 0x7F) {
	              codePoint = tempCodePoint;
	            }
	          }
	          break
	        case 3:
	          secondByte = buf[i + 1];
	          thirdByte = buf[i + 2];
	          if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80) {
	            tempCodePoint = (firstByte & 0xF) << 0xC | (secondByte & 0x3F) << 0x6 | (thirdByte & 0x3F);
	            if (tempCodePoint > 0x7FF && (tempCodePoint < 0xD800 || tempCodePoint > 0xDFFF)) {
	              codePoint = tempCodePoint;
	            }
	          }
	          break
	        case 4:
	          secondByte = buf[i + 1];
	          thirdByte = buf[i + 2];
	          fourthByte = buf[i + 3];
	          if ((secondByte & 0xC0) === 0x80 && (thirdByte & 0xC0) === 0x80 && (fourthByte & 0xC0) === 0x80) {
	            tempCodePoint = (firstByte & 0xF) << 0x12 | (secondByte & 0x3F) << 0xC | (thirdByte & 0x3F) << 0x6 | (fourthByte & 0x3F);
	            if (tempCodePoint > 0xFFFF && tempCodePoint < 0x110000) {
	              codePoint = tempCodePoint;
	            }
	          }
	      }
	    }

	    if (codePoint === null) {
	      // we did not generate a valid codePoint so insert a
	      // replacement char (U+FFFD) and advance only 1 byte
	      codePoint = 0xFFFD;
	      bytesPerSequence = 1;
	    } else if (codePoint > 0xFFFF) {
	      // encode to utf16 (surrogate pair dance)
	      codePoint -= 0x10000;
	      res.push(codePoint >>> 10 & 0x3FF | 0xD800);
	      codePoint = 0xDC00 | codePoint & 0x3FF;
	    }

	    res.push(codePoint);
	    i += bytesPerSequence;
	  }

	  return decodeCodePointsArray(res)
	}

	// Based on http://stackoverflow.com/a/22747272/680742, the browser with
	// the lowest limit is Chrome, with 0x10000 args.
	// We go 1 magnitude less, for safety
	var MAX_ARGUMENTS_LENGTH = 0x1000;

	function decodeCodePointsArray (codePoints) {
	  var len = codePoints.length;
	  if (len <= MAX_ARGUMENTS_LENGTH) {
	    return String.fromCharCode.apply(String, codePoints) // avoid extra slice()
	  }

	  // Decode in chunks to avoid "call stack size exceeded".
	  var res = '';
	  var i = 0;
	  while (i < len) {
	    res += String.fromCharCode.apply(
	      String,
	      codePoints.slice(i, i += MAX_ARGUMENTS_LENGTH)
	    );
	  }
	  return res
	}

	function asciiSlice (buf, start, end) {
	  var ret = '';
	  end = Math.min(buf.length, end);

	  for (var i = start; i < end; ++i) {
	    ret += String.fromCharCode(buf[i] & 0x7F);
	  }
	  return ret
	}

	function latin1Slice (buf, start, end) {
	  var ret = '';
	  end = Math.min(buf.length, end);

	  for (var i = start; i < end; ++i) {
	    ret += String.fromCharCode(buf[i]);
	  }
	  return ret
	}

	function hexSlice (buf, start, end) {
	  var len = buf.length;

	  if (!start || start < 0) start = 0;
	  if (!end || end < 0 || end > len) end = len;

	  var out = '';
	  for (var i = start; i < end; ++i) {
	    out += toHex(buf[i]);
	  }
	  return out
	}

	function utf16leSlice (buf, start, end) {
	  var bytes = buf.slice(start, end);
	  var res = '';
	  for (var i = 0; i < bytes.length; i += 2) {
	    res += String.fromCharCode(bytes[i] + bytes[i + 1] * 256);
	  }
	  return res
	}

	Buffer$1.prototype.slice = function slice (start, end) {
	  var len = this.length;
	  start = ~~start;
	  end = end === undefined ? len : ~~end;

	  if (start < 0) {
	    start += len;
	    if (start < 0) start = 0;
	  } else if (start > len) {
	    start = len;
	  }

	  if (end < 0) {
	    end += len;
	    if (end < 0) end = 0;
	  } else if (end > len) {
	    end = len;
	  }

	  if (end < start) end = start;

	  var newBuf;
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    newBuf = this.subarray(start, end);
	    newBuf.__proto__ = Buffer$1.prototype;
	  } else {
	    var sliceLen = end - start;
	    newBuf = new Buffer$1(sliceLen, undefined);
	    for (var i = 0; i < sliceLen; ++i) {
	      newBuf[i] = this[i + start];
	    }
	  }

	  return newBuf
	};

	/*
	 * Need to make sure that buffer isn't trying to write out of bounds.
	 */
	function checkOffset (offset, ext, length) {
	  if ((offset % 1) !== 0 || offset < 0) throw new RangeError('offset is not uint')
	  if (offset + ext > length) throw new RangeError('Trying to access beyond buffer length')
	}

	Buffer$1.prototype.readUIntLE = function readUIntLE (offset, byteLength, noAssert) {
	  offset = offset | 0;
	  byteLength = byteLength | 0;
	  if (!noAssert) checkOffset(offset, byteLength, this.length);

	  var val = this[offset];
	  var mul = 1;
	  var i = 0;
	  while (++i < byteLength && (mul *= 0x100)) {
	    val += this[offset + i] * mul;
	  }

	  return val
	};

	Buffer$1.prototype.readUIntBE = function readUIntBE (offset, byteLength, noAssert) {
	  offset = offset | 0;
	  byteLength = byteLength | 0;
	  if (!noAssert) {
	    checkOffset(offset, byteLength, this.length);
	  }

	  var val = this[offset + --byteLength];
	  var mul = 1;
	  while (byteLength > 0 && (mul *= 0x100)) {
	    val += this[offset + --byteLength] * mul;
	  }

	  return val
	};

	Buffer$1.prototype.readUInt8 = function readUInt8 (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 1, this.length);
	  return this[offset]
	};

	Buffer$1.prototype.readUInt16LE = function readUInt16LE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 2, this.length);
	  return this[offset] | (this[offset + 1] << 8)
	};

	Buffer$1.prototype.readUInt16BE = function readUInt16BE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 2, this.length);
	  return (this[offset] << 8) | this[offset + 1]
	};

	Buffer$1.prototype.readUInt32LE = function readUInt32LE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length);

	  return ((this[offset]) |
	      (this[offset + 1] << 8) |
	      (this[offset + 2] << 16)) +
	      (this[offset + 3] * 0x1000000)
	};

	Buffer$1.prototype.readUInt32BE = function readUInt32BE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length);

	  return (this[offset] * 0x1000000) +
	    ((this[offset + 1] << 16) |
	    (this[offset + 2] << 8) |
	    this[offset + 3])
	};

	Buffer$1.prototype.readIntLE = function readIntLE (offset, byteLength, noAssert) {
	  offset = offset | 0;
	  byteLength = byteLength | 0;
	  if (!noAssert) checkOffset(offset, byteLength, this.length);

	  var val = this[offset];
	  var mul = 1;
	  var i = 0;
	  while (++i < byteLength && (mul *= 0x100)) {
	    val += this[offset + i] * mul;
	  }
	  mul *= 0x80;

	  if (val >= mul) val -= Math.pow(2, 8 * byteLength);

	  return val
	};

	Buffer$1.prototype.readIntBE = function readIntBE (offset, byteLength, noAssert) {
	  offset = offset | 0;
	  byteLength = byteLength | 0;
	  if (!noAssert) checkOffset(offset, byteLength, this.length);

	  var i = byteLength;
	  var mul = 1;
	  var val = this[offset + --i];
	  while (i > 0 && (mul *= 0x100)) {
	    val += this[offset + --i] * mul;
	  }
	  mul *= 0x80;

	  if (val >= mul) val -= Math.pow(2, 8 * byteLength);

	  return val
	};

	Buffer$1.prototype.readInt8 = function readInt8 (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 1, this.length);
	  if (!(this[offset] & 0x80)) return (this[offset])
	  return ((0xff - this[offset] + 1) * -1)
	};

	Buffer$1.prototype.readInt16LE = function readInt16LE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 2, this.length);
	  var val = this[offset] | (this[offset + 1] << 8);
	  return (val & 0x8000) ? val | 0xFFFF0000 : val
	};

	Buffer$1.prototype.readInt16BE = function readInt16BE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 2, this.length);
	  var val = this[offset + 1] | (this[offset] << 8);
	  return (val & 0x8000) ? val | 0xFFFF0000 : val
	};

	Buffer$1.prototype.readInt32LE = function readInt32LE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length);

	  return (this[offset]) |
	    (this[offset + 1] << 8) |
	    (this[offset + 2] << 16) |
	    (this[offset + 3] << 24)
	};

	Buffer$1.prototype.readInt32BE = function readInt32BE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length);

	  return (this[offset] << 24) |
	    (this[offset + 1] << 16) |
	    (this[offset + 2] << 8) |
	    (this[offset + 3])
	};

	Buffer$1.prototype.readFloatLE = function readFloatLE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length);
	  return read(this, offset, true, 23, 4)
	};

	Buffer$1.prototype.readFloatBE = function readFloatBE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 4, this.length);
	  return read(this, offset, false, 23, 4)
	};

	Buffer$1.prototype.readDoubleLE = function readDoubleLE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 8, this.length);
	  return read(this, offset, true, 52, 8)
	};

	Buffer$1.prototype.readDoubleBE = function readDoubleBE (offset, noAssert) {
	  if (!noAssert) checkOffset(offset, 8, this.length);
	  return read(this, offset, false, 52, 8)
	};

	function checkInt (buf, value, offset, ext, max, min) {
	  if (!internalIsBuffer(buf)) throw new TypeError('"buffer" argument must be a Buffer instance')
	  if (value > max || value < min) throw new RangeError('"value" argument is out of bounds')
	  if (offset + ext > buf.length) throw new RangeError('Index out of range')
	}

	Buffer$1.prototype.writeUIntLE = function writeUIntLE (value, offset, byteLength, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  byteLength = byteLength | 0;
	  if (!noAssert) {
	    var maxBytes = Math.pow(2, 8 * byteLength) - 1;
	    checkInt(this, value, offset, byteLength, maxBytes, 0);
	  }

	  var mul = 1;
	  var i = 0;
	  this[offset] = value & 0xFF;
	  while (++i < byteLength && (mul *= 0x100)) {
	    this[offset + i] = (value / mul) & 0xFF;
	  }

	  return offset + byteLength
	};

	Buffer$1.prototype.writeUIntBE = function writeUIntBE (value, offset, byteLength, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  byteLength = byteLength | 0;
	  if (!noAssert) {
	    var maxBytes = Math.pow(2, 8 * byteLength) - 1;
	    checkInt(this, value, offset, byteLength, maxBytes, 0);
	  }

	  var i = byteLength - 1;
	  var mul = 1;
	  this[offset + i] = value & 0xFF;
	  while (--i >= 0 && (mul *= 0x100)) {
	    this[offset + i] = (value / mul) & 0xFF;
	  }

	  return offset + byteLength
	};

	Buffer$1.prototype.writeUInt8 = function writeUInt8 (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 1, 0xff, 0);
	  if (!Buffer$1.TYPED_ARRAY_SUPPORT) value = Math.floor(value);
	  this[offset] = (value & 0xff);
	  return offset + 1
	};

	function objectWriteUInt16 (buf, value, offset, littleEndian) {
	  if (value < 0) value = 0xffff + value + 1;
	  for (var i = 0, j = Math.min(buf.length - offset, 2); i < j; ++i) {
	    buf[offset + i] = (value & (0xff << (8 * (littleEndian ? i : 1 - i)))) >>>
	      (littleEndian ? i : 1 - i) * 8;
	  }
	}

	Buffer$1.prototype.writeUInt16LE = function writeUInt16LE (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0);
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value & 0xff);
	    this[offset + 1] = (value >>> 8);
	  } else {
	    objectWriteUInt16(this, value, offset, true);
	  }
	  return offset + 2
	};

	Buffer$1.prototype.writeUInt16BE = function writeUInt16BE (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 2, 0xffff, 0);
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value >>> 8);
	    this[offset + 1] = (value & 0xff);
	  } else {
	    objectWriteUInt16(this, value, offset, false);
	  }
	  return offset + 2
	};

	function objectWriteUInt32 (buf, value, offset, littleEndian) {
	  if (value < 0) value = 0xffffffff + value + 1;
	  for (var i = 0, j = Math.min(buf.length - offset, 4); i < j; ++i) {
	    buf[offset + i] = (value >>> (littleEndian ? i : 3 - i) * 8) & 0xff;
	  }
	}

	Buffer$1.prototype.writeUInt32LE = function writeUInt32LE (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0);
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    this[offset + 3] = (value >>> 24);
	    this[offset + 2] = (value >>> 16);
	    this[offset + 1] = (value >>> 8);
	    this[offset] = (value & 0xff);
	  } else {
	    objectWriteUInt32(this, value, offset, true);
	  }
	  return offset + 4
	};

	Buffer$1.prototype.writeUInt32BE = function writeUInt32BE (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 4, 0xffffffff, 0);
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value >>> 24);
	    this[offset + 1] = (value >>> 16);
	    this[offset + 2] = (value >>> 8);
	    this[offset + 3] = (value & 0xff);
	  } else {
	    objectWriteUInt32(this, value, offset, false);
	  }
	  return offset + 4
	};

	Buffer$1.prototype.writeIntLE = function writeIntLE (value, offset, byteLength, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) {
	    var limit = Math.pow(2, 8 * byteLength - 1);

	    checkInt(this, value, offset, byteLength, limit - 1, -limit);
	  }

	  var i = 0;
	  var mul = 1;
	  var sub = 0;
	  this[offset] = value & 0xFF;
	  while (++i < byteLength && (mul *= 0x100)) {
	    if (value < 0 && sub === 0 && this[offset + i - 1] !== 0) {
	      sub = 1;
	    }
	    this[offset + i] = ((value / mul) >> 0) - sub & 0xFF;
	  }

	  return offset + byteLength
	};

	Buffer$1.prototype.writeIntBE = function writeIntBE (value, offset, byteLength, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) {
	    var limit = Math.pow(2, 8 * byteLength - 1);

	    checkInt(this, value, offset, byteLength, limit - 1, -limit);
	  }

	  var i = byteLength - 1;
	  var mul = 1;
	  var sub = 0;
	  this[offset + i] = value & 0xFF;
	  while (--i >= 0 && (mul *= 0x100)) {
	    if (value < 0 && sub === 0 && this[offset + i + 1] !== 0) {
	      sub = 1;
	    }
	    this[offset + i] = ((value / mul) >> 0) - sub & 0xFF;
	  }

	  return offset + byteLength
	};

	Buffer$1.prototype.writeInt8 = function writeInt8 (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 1, 0x7f, -128);
	  if (!Buffer$1.TYPED_ARRAY_SUPPORT) value = Math.floor(value);
	  if (value < 0) value = 0xff + value + 1;
	  this[offset] = (value & 0xff);
	  return offset + 1
	};

	Buffer$1.prototype.writeInt16LE = function writeInt16LE (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -32768);
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value & 0xff);
	    this[offset + 1] = (value >>> 8);
	  } else {
	    objectWriteUInt16(this, value, offset, true);
	  }
	  return offset + 2
	};

	Buffer$1.prototype.writeInt16BE = function writeInt16BE (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 2, 0x7fff, -32768);
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value >>> 8);
	    this[offset + 1] = (value & 0xff);
	  } else {
	    objectWriteUInt16(this, value, offset, false);
	  }
	  return offset + 2
	};

	Buffer$1.prototype.writeInt32LE = function writeInt32LE (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -2147483648);
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value & 0xff);
	    this[offset + 1] = (value >>> 8);
	    this[offset + 2] = (value >>> 16);
	    this[offset + 3] = (value >>> 24);
	  } else {
	    objectWriteUInt32(this, value, offset, true);
	  }
	  return offset + 4
	};

	Buffer$1.prototype.writeInt32BE = function writeInt32BE (value, offset, noAssert) {
	  value = +value;
	  offset = offset | 0;
	  if (!noAssert) checkInt(this, value, offset, 4, 0x7fffffff, -2147483648);
	  if (value < 0) value = 0xffffffff + value + 1;
	  if (Buffer$1.TYPED_ARRAY_SUPPORT) {
	    this[offset] = (value >>> 24);
	    this[offset + 1] = (value >>> 16);
	    this[offset + 2] = (value >>> 8);
	    this[offset + 3] = (value & 0xff);
	  } else {
	    objectWriteUInt32(this, value, offset, false);
	  }
	  return offset + 4
	};

	function checkIEEE754 (buf, value, offset, ext, max, min) {
	  if (offset + ext > buf.length) throw new RangeError('Index out of range')
	  if (offset < 0) throw new RangeError('Index out of range')
	}

	function writeFloat (buf, value, offset, littleEndian, noAssert) {
	  if (!noAssert) {
	    checkIEEE754(buf, value, offset, 4);
	  }
	  write(buf, value, offset, littleEndian, 23, 4);
	  return offset + 4
	}

	Buffer$1.prototype.writeFloatLE = function writeFloatLE (value, offset, noAssert) {
	  return writeFloat(this, value, offset, true, noAssert)
	};

	Buffer$1.prototype.writeFloatBE = function writeFloatBE (value, offset, noAssert) {
	  return writeFloat(this, value, offset, false, noAssert)
	};

	function writeDouble (buf, value, offset, littleEndian, noAssert) {
	  if (!noAssert) {
	    checkIEEE754(buf, value, offset, 8);
	  }
	  write(buf, value, offset, littleEndian, 52, 8);
	  return offset + 8
	}

	Buffer$1.prototype.writeDoubleLE = function writeDoubleLE (value, offset, noAssert) {
	  return writeDouble(this, value, offset, true, noAssert)
	};

	Buffer$1.prototype.writeDoubleBE = function writeDoubleBE (value, offset, noAssert) {
	  return writeDouble(this, value, offset, false, noAssert)
	};

	// copy(targetBuffer, targetStart=0, sourceStart=0, sourceEnd=buffer.length)
	Buffer$1.prototype.copy = function copy (target, targetStart, start, end) {
	  if (!start) start = 0;
	  if (!end && end !== 0) end = this.length;
	  if (targetStart >= target.length) targetStart = target.length;
	  if (!targetStart) targetStart = 0;
	  if (end > 0 && end < start) end = start;

	  // Copy 0 bytes; we're done
	  if (end === start) return 0
	  if (target.length === 0 || this.length === 0) return 0

	  // Fatal error conditions
	  if (targetStart < 0) {
	    throw new RangeError('targetStart out of bounds')
	  }
	  if (start < 0 || start >= this.length) throw new RangeError('sourceStart out of bounds')
	  if (end < 0) throw new RangeError('sourceEnd out of bounds')

	  // Are we oob?
	  if (end > this.length) end = this.length;
	  if (target.length - targetStart < end - start) {
	    end = target.length - targetStart + start;
	  }

	  var len = end - start;
	  var i;

	  if (this === target && start < targetStart && targetStart < end) {
	    // descending copy from end
	    for (i = len - 1; i >= 0; --i) {
	      target[i + targetStart] = this[i + start];
	    }
	  } else if (len < 1000 || !Buffer$1.TYPED_ARRAY_SUPPORT) {
	    // ascending copy from start
	    for (i = 0; i < len; ++i) {
	      target[i + targetStart] = this[i + start];
	    }
	  } else {
	    Uint8Array.prototype.set.call(
	      target,
	      this.subarray(start, start + len),
	      targetStart
	    );
	  }

	  return len
	};

	// Usage:
	//    buffer.fill(number[, offset[, end]])
	//    buffer.fill(buffer[, offset[, end]])
	//    buffer.fill(string[, offset[, end]][, encoding])
	Buffer$1.prototype.fill = function fill (val, start, end, encoding) {
	  // Handle string cases:
	  if (typeof val === 'string') {
	    if (typeof start === 'string') {
	      encoding = start;
	      start = 0;
	      end = this.length;
	    } else if (typeof end === 'string') {
	      encoding = end;
	      end = this.length;
	    }
	    if (val.length === 1) {
	      var code = val.charCodeAt(0);
	      if (code < 256) {
	        val = code;
	      }
	    }
	    if (encoding !== undefined && typeof encoding !== 'string') {
	      throw new TypeError('encoding must be a string')
	    }
	    if (typeof encoding === 'string' && !Buffer$1.isEncoding(encoding)) {
	      throw new TypeError('Unknown encoding: ' + encoding)
	    }
	  } else if (typeof val === 'number') {
	    val = val & 255;
	  }

	  // Invalid ranges are not set to a default, so can range check early.
	  if (start < 0 || this.length < start || this.length < end) {
	    throw new RangeError('Out of range index')
	  }

	  if (end <= start) {
	    return this
	  }

	  start = start >>> 0;
	  end = end === undefined ? this.length : end >>> 0;

	  if (!val) val = 0;

	  var i;
	  if (typeof val === 'number') {
	    for (i = start; i < end; ++i) {
	      this[i] = val;
	    }
	  } else {
	    var bytes = internalIsBuffer(val)
	      ? val
	      : utf8ToBytes(new Buffer$1(val, encoding).toString());
	    var len = bytes.length;
	    for (i = 0; i < end - start; ++i) {
	      this[i + start] = bytes[i % len];
	    }
	  }

	  return this
	};

	// HELPER FUNCTIONS
	// ================

	var INVALID_BASE64_RE = /[^+\/0-9A-Za-z-_]/g;

	function base64clean (str) {
	  // Node strips out invalid characters like \n and \t from the string, base64-js does not
	  str = stringtrim(str).replace(INVALID_BASE64_RE, '');
	  // Node converts strings with length < 2 to ''
	  if (str.length < 2) return ''
	  // Node allows for non-padded base64 strings (missing trailing ===), base64-js does not
	  while (str.length % 4 !== 0) {
	    str = str + '=';
	  }
	  return str
	}

	function stringtrim (str) {
	  if (str.trim) return str.trim()
	  return str.replace(/^\s+|\s+$/g, '')
	}

	function toHex (n) {
	  if (n < 16) return '0' + n.toString(16)
	  return n.toString(16)
	}

	function utf8ToBytes (string, units) {
	  units = units || Infinity;
	  var codePoint;
	  var length = string.length;
	  var leadSurrogate = null;
	  var bytes = [];

	  for (var i = 0; i < length; ++i) {
	    codePoint = string.charCodeAt(i);

	    // is surrogate component
	    if (codePoint > 0xD7FF && codePoint < 0xE000) {
	      // last char was a lead
	      if (!leadSurrogate) {
	        // no lead yet
	        if (codePoint > 0xDBFF) {
	          // unexpected trail
	          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD);
	          continue
	        } else if (i + 1 === length) {
	          // unpaired lead
	          if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD);
	          continue
	        }

	        // valid lead
	        leadSurrogate = codePoint;

	        continue
	      }

	      // 2 leads in a row
	      if (codePoint < 0xDC00) {
	        if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD);
	        leadSurrogate = codePoint;
	        continue
	      }

	      // valid surrogate pair
	      codePoint = (leadSurrogate - 0xD800 << 10 | codePoint - 0xDC00) + 0x10000;
	    } else if (leadSurrogate) {
	      // valid bmp char, but last char was a lead
	      if ((units -= 3) > -1) bytes.push(0xEF, 0xBF, 0xBD);
	    }

	    leadSurrogate = null;

	    // encode utf8
	    if (codePoint < 0x80) {
	      if ((units -= 1) < 0) break
	      bytes.push(codePoint);
	    } else if (codePoint < 0x800) {
	      if ((units -= 2) < 0) break
	      bytes.push(
	        codePoint >> 0x6 | 0xC0,
	        codePoint & 0x3F | 0x80
	      );
	    } else if (codePoint < 0x10000) {
	      if ((units -= 3) < 0) break
	      bytes.push(
	        codePoint >> 0xC | 0xE0,
	        codePoint >> 0x6 & 0x3F | 0x80,
	        codePoint & 0x3F | 0x80
	      );
	    } else if (codePoint < 0x110000) {
	      if ((units -= 4) < 0) break
	      bytes.push(
	        codePoint >> 0x12 | 0xF0,
	        codePoint >> 0xC & 0x3F | 0x80,
	        codePoint >> 0x6 & 0x3F | 0x80,
	        codePoint & 0x3F | 0x80
	      );
	    } else {
	      throw new Error('Invalid code point')
	    }
	  }

	  return bytes
	}

	function asciiToBytes (str) {
	  var byteArray = [];
	  for (var i = 0; i < str.length; ++i) {
	    // Node's code seems to be doing this and not & 0x7F..
	    byteArray.push(str.charCodeAt(i) & 0xFF);
	  }
	  return byteArray
	}

	function utf16leToBytes (str, units) {
	  var c, hi, lo;
	  var byteArray = [];
	  for (var i = 0; i < str.length; ++i) {
	    if ((units -= 2) < 0) break

	    c = str.charCodeAt(i);
	    hi = c >> 8;
	    lo = c % 256;
	    byteArray.push(lo);
	    byteArray.push(hi);
	  }

	  return byteArray
	}


	function base64ToBytes (str) {
	  return toByteArray(base64clean(str))
	}

	function blitBuffer (src, dst, offset, length) {
	  for (var i = 0; i < length; ++i) {
	    if ((i + offset >= dst.length) || (i >= src.length)) break
	    dst[i + offset] = src[i];
	  }
	  return i
	}

	function isnan (val) {
	  return val !== val // eslint-disable-line no-self-compare
	}


	// the following is from is-buffer, also by Feross Aboukhadijeh and with same lisence
	// The _isBuffer check is for Safari 5-7 support, because it's missing
	// Object.prototype.constructor. Remove this eventually
	function isBuffer$1(obj) {
	  return obj != null && (!!obj._isBuffer || isFastBuffer(obj) || isSlowBuffer(obj))
	}

	function isFastBuffer (obj) {
	  return !!obj.constructor && typeof obj.constructor.isBuffer === 'function' && obj.constructor.isBuffer(obj)
	}

	// For Node v0.10 support. Remove this eventually.
	function isSlowBuffer (obj) {
	  return typeof obj.readFloatLE === 'function' && typeof obj.slice === 'function' && isFastBuffer(obj.slice(0, 0))
	}

	var tars = {exports: {}};

	var env = {};

	// from https://github.com/kumavis/browser-process-hrtime/blob/master/index.js
	var performance$1 = global$1.performance || {};
	performance$1.now        ||
	  performance$1.mozNow     ||
	  performance$1.msNow      ||
	  performance$1.oNow       ||
	  performance$1.webkitNow  ||
	  function(){ return (new Date()).getTime() };

	var process = {
	  env: env};

	var inherits;
	if (typeof Object.create === 'function'){
	  inherits = function inherits(ctor, superCtor) {
	    // implementation from standard node.js 'util' module
	    ctor.super_ = superCtor;
	    ctor.prototype = Object.create(superCtor.prototype, {
	      constructor: {
	        value: ctor,
	        enumerable: false,
	        writable: true,
	        configurable: true
	      }
	    });
	  };
	} else {
	  inherits = function inherits(ctor, superCtor) {
	    ctor.super_ = superCtor;
	    var TempCtor = function () {};
	    TempCtor.prototype = superCtor.prototype;
	    ctor.prototype = new TempCtor();
	    ctor.prototype.constructor = ctor;
	  };
	}
	var inherits$1 = inherits;

	var formatRegExp = /%[sdj%]/g;
	function format(f) {
	  if (!isString(f)) {
	    var objects = [];
	    for (var i = 0; i < arguments.length; i++) {
	      objects.push(inspect$1(arguments[i]));
	    }
	    return objects.join(' ');
	  }

	  var i = 1;
	  var args = arguments;
	  var len = args.length;
	  var str = String(f).replace(formatRegExp, function(x) {
	    if (x === '%%') return '%';
	    if (i >= len) return x;
	    switch (x) {
	      case '%s': return String(args[i++]);
	      case '%d': return Number(args[i++]);
	      case '%j':
	        try {
	          return JSON.stringify(args[i++]);
	        } catch (_) {
	          return '[Circular]';
	        }
	      default:
	        return x;
	    }
	  });
	  for (var x = args[i]; i < len; x = args[++i]) {
	    if (isNull(x) || !isObject(x)) {
	      str += ' ' + x;
	    } else {
	      str += ' ' + inspect$1(x);
	    }
	  }
	  return str;
	}

	// Mark that a method should not be used.
	// Returns a modified function which warns once by default.
	// If --no-deprecation is set, then it is a no-op.
	function deprecate(fn, msg) {
	  // Allow for deprecating things in the process of starting up.
	  if (isUndefined(global$1.process)) {
	    return function() {
	      return deprecate(fn, msg).apply(this, arguments);
	    };
	  }

	  if (process.noDeprecation === true) {
	    return fn;
	  }

	  var warned = false;
	  function deprecated() {
	    if (!warned) {
	      if (process.throwDeprecation) {
	        throw new Error(msg);
	      } else if (process.traceDeprecation) {
	        console.trace(msg);
	      } else {
	        console.error(msg);
	      }
	      warned = true;
	    }
	    return fn.apply(this, arguments);
	  }

	  return deprecated;
	}

	var debugs = {};
	var debugEnviron;
	function debuglog(set) {
	  if (isUndefined(debugEnviron))
	    debugEnviron = process.env.NODE_DEBUG || '';
	  set = set.toUpperCase();
	  if (!debugs[set]) {
	    if (new RegExp('\\b' + set + '\\b', 'i').test(debugEnviron)) {
	      var pid = 0;
	      debugs[set] = function() {
	        var msg = format.apply(null, arguments);
	        console.error('%s %d: %s', set, pid, msg);
	      };
	    } else {
	      debugs[set] = function() {};
	    }
	  }
	  return debugs[set];
	}

	/**
	 * Echos the value of a value. Trys to print the value out
	 * in the best way possible given the different types.
	 *
	 * @param {Object} obj The object to print out.
	 * @param {Object} opts Optional options object that alters the output.
	 */
	/* legacy: obj, showHidden, depth, colors*/
	function inspect$1(obj, opts) {
	  // default options
	  var ctx = {
	    seen: [],
	    stylize: stylizeNoColor
	  };
	  // legacy...
	  if (arguments.length >= 3) ctx.depth = arguments[2];
	  if (arguments.length >= 4) ctx.colors = arguments[3];
	  if (isBoolean(opts)) {
	    // legacy...
	    ctx.showHidden = opts;
	  } else if (opts) {
	    // got an "options" object
	    _extend(ctx, opts);
	  }
	  // set default options
	  if (isUndefined(ctx.showHidden)) ctx.showHidden = false;
	  if (isUndefined(ctx.depth)) ctx.depth = 2;
	  if (isUndefined(ctx.colors)) ctx.colors = false;
	  if (isUndefined(ctx.customInspect)) ctx.customInspect = true;
	  if (ctx.colors) ctx.stylize = stylizeWithColor;
	  return formatValue(ctx, obj, ctx.depth);
	}

	// http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
	inspect$1.colors = {
	  'bold' : [1, 22],
	  'italic' : [3, 23],
	  'underline' : [4, 24],
	  'inverse' : [7, 27],
	  'white' : [37, 39],
	  'grey' : [90, 39],
	  'black' : [30, 39],
	  'blue' : [34, 39],
	  'cyan' : [36, 39],
	  'green' : [32, 39],
	  'magenta' : [35, 39],
	  'red' : [31, 39],
	  'yellow' : [33, 39]
	};

	// Don't use 'blue' not visible on cmd.exe
	inspect$1.styles = {
	  'special': 'cyan',
	  'number': 'yellow',
	  'boolean': 'yellow',
	  'undefined': 'grey',
	  'null': 'bold',
	  'string': 'green',
	  'date': 'magenta',
	  // "name": intentionally not styling
	  'regexp': 'red'
	};


	function stylizeWithColor(str, styleType) {
	  var style = inspect$1.styles[styleType];

	  if (style) {
	    return '\u001b[' + inspect$1.colors[style][0] + 'm' + str +
	           '\u001b[' + inspect$1.colors[style][1] + 'm';
	  } else {
	    return str;
	  }
	}


	function stylizeNoColor(str, styleType) {
	  return str;
	}


	function arrayToHash(array) {
	  var hash = {};

	  array.forEach(function(val, idx) {
	    hash[val] = true;
	  });

	  return hash;
	}


	function formatValue(ctx, value, recurseTimes) {
	  // Provide a hook for user-specified inspect functions.
	  // Check that value is an object with an inspect function on it
	  if (ctx.customInspect &&
	      value &&
	      isFunction(value.inspect) &&
	      // Filter out the util module, it's inspect function is special
	      value.inspect !== inspect$1 &&
	      // Also filter out any prototype objects using the circular check.
	      !(value.constructor && value.constructor.prototype === value)) {
	    var ret = value.inspect(recurseTimes, ctx);
	    if (!isString(ret)) {
	      ret = formatValue(ctx, ret, recurseTimes);
	    }
	    return ret;
	  }

	  // Primitive types cannot have properties
	  var primitive = formatPrimitive(ctx, value);
	  if (primitive) {
	    return primitive;
	  }

	  // Look up the keys of the object.
	  var keys = Object.keys(value);
	  var visibleKeys = arrayToHash(keys);

	  if (ctx.showHidden) {
	    keys = Object.getOwnPropertyNames(value);
	  }

	  // IE doesn't make error fields non-enumerable
	  // http://msdn.microsoft.com/en-us/library/ie/dww52sbt(v=vs.94).aspx
	  if (isError(value)
	      && (keys.indexOf('message') >= 0 || keys.indexOf('description') >= 0)) {
	    return formatError(value);
	  }

	  // Some type of object without properties can be shortcutted.
	  if (keys.length === 0) {
	    if (isFunction(value)) {
	      var name = value.name ? ': ' + value.name : '';
	      return ctx.stylize('[Function' + name + ']', 'special');
	    }
	    if (isRegExp(value)) {
	      return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
	    }
	    if (isDate(value)) {
	      return ctx.stylize(Date.prototype.toString.call(value), 'date');
	    }
	    if (isError(value)) {
	      return formatError(value);
	    }
	  }

	  var base = '', array = false, braces = ['{', '}'];

	  // Make Array say that they are Array
	  if (isArray(value)) {
	    array = true;
	    braces = ['[', ']'];
	  }

	  // Make functions say that they are functions
	  if (isFunction(value)) {
	    var n = value.name ? ': ' + value.name : '';
	    base = ' [Function' + n + ']';
	  }

	  // Make RegExps say that they are RegExps
	  if (isRegExp(value)) {
	    base = ' ' + RegExp.prototype.toString.call(value);
	  }

	  // Make dates with properties first say the date
	  if (isDate(value)) {
	    base = ' ' + Date.prototype.toUTCString.call(value);
	  }

	  // Make error with message first say the error
	  if (isError(value)) {
	    base = ' ' + formatError(value);
	  }

	  if (keys.length === 0 && (!array || value.length == 0)) {
	    return braces[0] + base + braces[1];
	  }

	  if (recurseTimes < 0) {
	    if (isRegExp(value)) {
	      return ctx.stylize(RegExp.prototype.toString.call(value), 'regexp');
	    } else {
	      return ctx.stylize('[Object]', 'special');
	    }
	  }

	  ctx.seen.push(value);

	  var output;
	  if (array) {
	    output = formatArray(ctx, value, recurseTimes, visibleKeys, keys);
	  } else {
	    output = keys.map(function(key) {
	      return formatProperty(ctx, value, recurseTimes, visibleKeys, key, array);
	    });
	  }

	  ctx.seen.pop();

	  return reduceToSingleString(output, base, braces);
	}


	function formatPrimitive(ctx, value) {
	  if (isUndefined(value))
	    return ctx.stylize('undefined', 'undefined');
	  if (isString(value)) {
	    var simple = '\'' + JSON.stringify(value).replace(/^"|"$/g, '')
	                                             .replace(/'/g, "\\'")
	                                             .replace(/\\"/g, '"') + '\'';
	    return ctx.stylize(simple, 'string');
	  }
	  if (isNumber(value))
	    return ctx.stylize('' + value, 'number');
	  if (isBoolean(value))
	    return ctx.stylize('' + value, 'boolean');
	  // For some reason typeof null is "object", so special case here.
	  if (isNull(value))
	    return ctx.stylize('null', 'null');
	}


	function formatError(value) {
	  return '[' + Error.prototype.toString.call(value) + ']';
	}


	function formatArray(ctx, value, recurseTimes, visibleKeys, keys) {
	  var output = [];
	  for (var i = 0, l = value.length; i < l; ++i) {
	    if (hasOwnProperty(value, String(i))) {
	      output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
	          String(i), true));
	    } else {
	      output.push('');
	    }
	  }
	  keys.forEach(function(key) {
	    if (!key.match(/^\d+$/)) {
	      output.push(formatProperty(ctx, value, recurseTimes, visibleKeys,
	          key, true));
	    }
	  });
	  return output;
	}


	function formatProperty(ctx, value, recurseTimes, visibleKeys, key, array) {
	  var name, str, desc;
	  desc = Object.getOwnPropertyDescriptor(value, key) || { value: value[key] };
	  if (desc.get) {
	    if (desc.set) {
	      str = ctx.stylize('[Getter/Setter]', 'special');
	    } else {
	      str = ctx.stylize('[Getter]', 'special');
	    }
	  } else {
	    if (desc.set) {
	      str = ctx.stylize('[Setter]', 'special');
	    }
	  }
	  if (!hasOwnProperty(visibleKeys, key)) {
	    name = '[' + key + ']';
	  }
	  if (!str) {
	    if (ctx.seen.indexOf(desc.value) < 0) {
	      if (isNull(recurseTimes)) {
	        str = formatValue(ctx, desc.value, null);
	      } else {
	        str = formatValue(ctx, desc.value, recurseTimes - 1);
	      }
	      if (str.indexOf('\n') > -1) {
	        if (array) {
	          str = str.split('\n').map(function(line) {
	            return '  ' + line;
	          }).join('\n').substr(2);
	        } else {
	          str = '\n' + str.split('\n').map(function(line) {
	            return '   ' + line;
	          }).join('\n');
	        }
	      }
	    } else {
	      str = ctx.stylize('[Circular]', 'special');
	    }
	  }
	  if (isUndefined(name)) {
	    if (array && key.match(/^\d+$/)) {
	      return str;
	    }
	    name = JSON.stringify('' + key);
	    if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
	      name = name.substr(1, name.length - 2);
	      name = ctx.stylize(name, 'name');
	    } else {
	      name = name.replace(/'/g, "\\'")
	                 .replace(/\\"/g, '"')
	                 .replace(/(^"|"$)/g, "'");
	      name = ctx.stylize(name, 'string');
	    }
	  }

	  return name + ': ' + str;
	}


	function reduceToSingleString(output, base, braces) {
	  var length = output.reduce(function(prev, cur) {
	    if (cur.indexOf('\n') >= 0) ;
	    return prev + cur.replace(/\u001b\[\d\d?m/g, '').length + 1;
	  }, 0);

	  if (length > 60) {
	    return braces[0] +
	           (base === '' ? '' : base + '\n ') +
	           ' ' +
	           output.join(',\n  ') +
	           ' ' +
	           braces[1];
	  }

	  return braces[0] + base + ' ' + output.join(', ') + ' ' + braces[1];
	}


	// NOTE: These type checking functions intentionally don't use `instanceof`
	// because it is fragile and can be easily faked with `Object.create()`.
	function isArray(ar) {
	  return Array.isArray(ar);
	}

	function isBoolean(arg) {
	  return typeof arg === 'boolean';
	}

	function isNull(arg) {
	  return arg === null;
	}

	function isNullOrUndefined(arg) {
	  return arg == null;
	}

	function isNumber(arg) {
	  return typeof arg === 'number';
	}

	function isString(arg) {
	  return typeof arg === 'string';
	}

	function isSymbol(arg) {
	  return typeof arg === 'symbol';
	}

	function isUndefined(arg) {
	  return arg === void 0;
	}

	function isRegExp(re) {
	  return isObject(re) && objectToString(re) === '[object RegExp]';
	}

	function isObject(arg) {
	  return typeof arg === 'object' && arg !== null;
	}

	function isDate(d) {
	  return isObject(d) && objectToString(d) === '[object Date]';
	}

	function isError(e) {
	  return isObject(e) &&
	      (objectToString(e) === '[object Error]' || e instanceof Error);
	}

	function isFunction(arg) {
	  return typeof arg === 'function';
	}

	function isPrimitive(arg) {
	  return arg === null ||
	         typeof arg === 'boolean' ||
	         typeof arg === 'number' ||
	         typeof arg === 'string' ||
	         typeof arg === 'symbol' ||  // ES6 symbol
	         typeof arg === 'undefined';
	}

	function isBuffer(maybeBuf) {
	  return isBuffer$1(maybeBuf);
	}

	function objectToString(o) {
	  return Object.prototype.toString.call(o);
	}


	function pad(n) {
	  return n < 10 ? '0' + n.toString(10) : n.toString(10);
	}


	var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
	              'Oct', 'Nov', 'Dec'];

	// 26 Feb 16:19:34
	function timestamp() {
	  var d = new Date();
	  var time = [pad(d.getHours()),
	              pad(d.getMinutes()),
	              pad(d.getSeconds())].join(':');
	  return [d.getDate(), months[d.getMonth()], time].join(' ');
	}


	// log is just a thin wrapper to console.log that prepends a timestamp
	function log() {
	  console.log('%s - %s', timestamp(), format.apply(null, arguments));
	}

	function _extend(origin, add) {
	  // Don't do anything if add isn't an object
	  if (!add || !isObject(add)) return origin;

	  var keys = Object.keys(add);
	  var i = keys.length;
	  while (i--) {
	    origin[keys[i]] = add[keys[i]];
	  }
	  return origin;
	}
	function hasOwnProperty(obj, prop) {
	  return Object.prototype.hasOwnProperty.call(obj, prop);
	}

	var util$1 = {
	  inherits: inherits$1,
	  _extend: _extend,
	  log: log,
	  isBuffer: isBuffer,
	  isPrimitive: isPrimitive,
	  isFunction: isFunction,
	  isError: isError,
	  isDate: isDate,
	  isObject: isObject,
	  isRegExp: isRegExp,
	  isUndefined: isUndefined,
	  isSymbol: isSymbol,
	  isString: isString,
	  isNumber: isNumber,
	  isNullOrUndefined: isNullOrUndefined,
	  isNull: isNull,
	  isBoolean: isBoolean,
	  isArray: isArray,
	  inspect: inspect$1,
	  deprecate: deprecate,
	  format: format,
	  debuglog: debuglog
	};

	var util$2 = /*#__PURE__*/Object.freeze({
		__proto__: null,
		_extend: _extend,
		debuglog: debuglog,
		default: util$1,
		deprecate: deprecate,
		format: format,
		inherits: inherits$1,
		inspect: inspect$1,
		isArray: isArray,
		isBoolean: isBoolean,
		isBuffer: isBuffer,
		isDate: isDate,
		isError: isError,
		isFunction: isFunction,
		isNull: isNull,
		isNullOrUndefined: isNullOrUndefined,
		isNumber: isNumber,
		isObject: isObject,
		isPrimitive: isPrimitive,
		isRegExp: isRegExp,
		isString: isString,
		isSymbol: isSymbol,
		isUndefined: isUndefined,
		log: log
	});

	function compare(a, b) {
	  if (a === b) {
	    return 0;
	  }

	  var x = a.length;
	  var y = b.length;

	  for (var i = 0, len = Math.min(x, y); i < len; ++i) {
	    if (a[i] !== b[i]) {
	      x = a[i];
	      y = b[i];
	      break;
	    }
	  }

	  if (x < y) {
	    return -1;
	  }
	  if (y < x) {
	    return 1;
	  }
	  return 0;
	}
	var hasOwn = Object.prototype.hasOwnProperty;

	var objectKeys = Object.keys || function (obj) {
	  var keys = [];
	  for (var key in obj) {
	    if (hasOwn.call(obj, key)) keys.push(key);
	  }
	  return keys;
	};
	var pSlice = Array.prototype.slice;
	var _functionsHaveNames;
	function functionsHaveNames() {
	  if (typeof _functionsHaveNames !== 'undefined') {
	    return _functionsHaveNames;
	  }
	  return _functionsHaveNames = (function () {
	    return function foo() {}.name === 'foo';
	  }());
	}
	function pToString (obj) {
	  return Object.prototype.toString.call(obj);
	}
	function isView(arrbuf) {
	  if (isBuffer$1(arrbuf)) {
	    return false;
	  }
	  if (typeof global$1.ArrayBuffer !== 'function') {
	    return false;
	  }
	  if (typeof ArrayBuffer.isView === 'function') {
	    return ArrayBuffer.isView(arrbuf);
	  }
	  if (!arrbuf) {
	    return false;
	  }
	  if (arrbuf instanceof DataView) {
	    return true;
	  }
	  if (arrbuf.buffer && arrbuf.buffer instanceof ArrayBuffer) {
	    return true;
	  }
	  return false;
	}
	// 1. The assert module provides functions that throw
	// AssertionError's when particular conditions are not met. The
	// assert module must conform to the following interface.

	function assert$1(value, message) {
	  if (!value) fail(value, true, message, '==', ok);
	}

	// 2. The AssertionError is defined in assert.
	// new assert.AssertionError({ message: message,
	//                             actual: actual,
	//                             expected: expected })

	var regex = /\s*function\s+([^\(\s]*)\s*/;
	// based on https://github.com/ljharb/function.prototype.name/blob/adeeeec8bfcc6068b187d7d9fb3d5bb1d3a30899/implementation.js
	function getName(func) {
	  if (!isFunction(func)) {
	    return;
	  }
	  if (functionsHaveNames()) {
	    return func.name;
	  }
	  var str = func.toString();
	  var match = str.match(regex);
	  return match && match[1];
	}
	assert$1.AssertionError = AssertionError;
	function AssertionError(options) {
	  this.name = 'AssertionError';
	  this.actual = options.actual;
	  this.expected = options.expected;
	  this.operator = options.operator;
	  if (options.message) {
	    this.message = options.message;
	    this.generatedMessage = false;
	  } else {
	    this.message = getMessage(this);
	    this.generatedMessage = true;
	  }
	  var stackStartFunction = options.stackStartFunction || fail;
	  if (Error.captureStackTrace) {
	    Error.captureStackTrace(this, stackStartFunction);
	  } else {
	    // non v8 browsers so we can have a stacktrace
	    var err = new Error();
	    if (err.stack) {
	      var out = err.stack;

	      // try to strip useless frames
	      var fn_name = getName(stackStartFunction);
	      var idx = out.indexOf('\n' + fn_name);
	      if (idx >= 0) {
	        // once we have located the function frame
	        // we need to strip out everything before it (and its line)
	        var next_line = out.indexOf('\n', idx + 1);
	        out = out.substring(next_line + 1);
	      }

	      this.stack = out;
	    }
	  }
	}

	// assert.AssertionError instanceof Error
	inherits$1(AssertionError, Error);

	function truncate(s, n) {
	  if (typeof s === 'string') {
	    return s.length < n ? s : s.slice(0, n);
	  } else {
	    return s;
	  }
	}
	function inspect(something) {
	  if (functionsHaveNames() || !isFunction(something)) {
	    return inspect$1(something);
	  }
	  var rawname = getName(something);
	  var name = rawname ? ': ' + rawname : '';
	  return '[Function' +  name + ']';
	}
	function getMessage(self) {
	  return truncate(inspect(self.actual), 128) + ' ' +
	         self.operator + ' ' +
	         truncate(inspect(self.expected), 128);
	}

	// At present only the three keys mentioned above are used and
	// understood by the spec. Implementations or sub modules can pass
	// other keys to the AssertionError's constructor - they will be
	// ignored.

	// 3. All of the following functions must throw an AssertionError
	// when a corresponding condition is not met, with a message that
	// may be undefined if not provided.  All assertion methods provide
	// both the actual and expected values to the assertion error for
	// display purposes.

	function fail(actual, expected, message, operator, stackStartFunction) {
	  throw new AssertionError({
	    message: message,
	    actual: actual,
	    expected: expected,
	    operator: operator,
	    stackStartFunction: stackStartFunction
	  });
	}

	// EXTENSION! allows for well behaved errors defined elsewhere.
	assert$1.fail = fail;

	// 4. Pure assertion tests whether a value is truthy, as determined
	// by !!guard.
	// assert.ok(guard, message_opt);
	// This statement is equivalent to assert.equal(true, !!guard,
	// message_opt);. To test strictly for the value true, use
	// assert.strictEqual(true, guard, message_opt);.

	function ok(value, message) {
	  if (!value) fail(value, true, message, '==', ok);
	}
	assert$1.ok = ok;

	// 5. The equality assertion tests shallow, coercive equality with
	// ==.
	// assert.equal(actual, expected, message_opt);
	assert$1.equal = equal;
	function equal(actual, expected, message) {
	  if (actual != expected) fail(actual, expected, message, '==', equal);
	}

	// 6. The non-equality assertion tests for whether two objects are not equal
	// with != assert.notEqual(actual, expected, message_opt);
	assert$1.notEqual = notEqual;
	function notEqual(actual, expected, message) {
	  if (actual == expected) {
	    fail(actual, expected, message, '!=', notEqual);
	  }
	}

	// 7. The equivalence assertion tests a deep equality relation.
	// assert.deepEqual(actual, expected, message_opt);
	assert$1.deepEqual = deepEqual;
	function deepEqual(actual, expected, message) {
	  if (!_deepEqual(actual, expected, false)) {
	    fail(actual, expected, message, 'deepEqual', deepEqual);
	  }
	}
	assert$1.deepStrictEqual = deepStrictEqual;
	function deepStrictEqual(actual, expected, message) {
	  if (!_deepEqual(actual, expected, true)) {
	    fail(actual, expected, message, 'deepStrictEqual', deepStrictEqual);
	  }
	}

	function _deepEqual(actual, expected, strict, memos) {
	  // 7.1. All identical values are equivalent, as determined by ===.
	  if (actual === expected) {
	    return true;
	  } else if (isBuffer$1(actual) && isBuffer$1(expected)) {
	    return compare(actual, expected) === 0;

	  // 7.2. If the expected value is a Date object, the actual value is
	  // equivalent if it is also a Date object that refers to the same time.
	  } else if (isDate(actual) && isDate(expected)) {
	    return actual.getTime() === expected.getTime();

	  // 7.3 If the expected value is a RegExp object, the actual value is
	  // equivalent if it is also a RegExp object with the same source and
	  // properties (`global`, `multiline`, `lastIndex`, `ignoreCase`).
	  } else if (isRegExp(actual) && isRegExp(expected)) {
	    return actual.source === expected.source &&
	           actual.global === expected.global &&
	           actual.multiline === expected.multiline &&
	           actual.lastIndex === expected.lastIndex &&
	           actual.ignoreCase === expected.ignoreCase;

	  // 7.4. Other pairs that do not both pass typeof value == 'object',
	  // equivalence is determined by ==.
	  } else if ((actual === null || typeof actual !== 'object') &&
	             (expected === null || typeof expected !== 'object')) {
	    return strict ? actual === expected : actual == expected;

	  // If both values are instances of typed arrays, wrap their underlying
	  // ArrayBuffers in a Buffer each to increase performance
	  // This optimization requires the arrays to have the same type as checked by
	  // Object.prototype.toString (aka pToString). Never perform binary
	  // comparisons for Float*Arrays, though, since e.g. +0 === -0 but their
	  // bit patterns are not identical.
	  } else if (isView(actual) && isView(expected) &&
	             pToString(actual) === pToString(expected) &&
	             !(actual instanceof Float32Array ||
	               actual instanceof Float64Array)) {
	    return compare(new Uint8Array(actual.buffer),
	                   new Uint8Array(expected.buffer)) === 0;

	  // 7.5 For all other Object pairs, including Array objects, equivalence is
	  // determined by having the same number of owned properties (as verified
	  // with Object.prototype.hasOwnProperty.call), the same set of keys
	  // (although not necessarily the same order), equivalent values for every
	  // corresponding key, and an identical 'prototype' property. Note: this
	  // accounts for both named and indexed properties on Arrays.
	  } else if (isBuffer$1(actual) !== isBuffer$1(expected)) {
	    return false;
	  } else {
	    memos = memos || {actual: [], expected: []};

	    var actualIndex = memos.actual.indexOf(actual);
	    if (actualIndex !== -1) {
	      if (actualIndex === memos.expected.indexOf(expected)) {
	        return true;
	      }
	    }

	    memos.actual.push(actual);
	    memos.expected.push(expected);

	    return objEquiv(actual, expected, strict, memos);
	  }
	}

	function isArguments(object) {
	  return Object.prototype.toString.call(object) == '[object Arguments]';
	}

	function objEquiv(a, b, strict, actualVisitedObjects) {
	  if (a === null || a === undefined || b === null || b === undefined)
	    return false;
	  // if one is a primitive, the other must be same
	  if (isPrimitive(a) || isPrimitive(b))
	    return a === b;
	  if (strict && Object.getPrototypeOf(a) !== Object.getPrototypeOf(b))
	    return false;
	  var aIsArgs = isArguments(a);
	  var bIsArgs = isArguments(b);
	  if ((aIsArgs && !bIsArgs) || (!aIsArgs && bIsArgs))
	    return false;
	  if (aIsArgs) {
	    a = pSlice.call(a);
	    b = pSlice.call(b);
	    return _deepEqual(a, b, strict);
	  }
	  var ka = objectKeys(a);
	  var kb = objectKeys(b);
	  var key, i;
	  // having the same number of owned properties (keys incorporates
	  // hasOwnProperty)
	  if (ka.length !== kb.length)
	    return false;
	  //the same set of keys (although not necessarily the same order),
	  ka.sort();
	  kb.sort();
	  //~~~cheap key test
	  for (i = ka.length - 1; i >= 0; i--) {
	    if (ka[i] !== kb[i])
	      return false;
	  }
	  //equivalent values for every corresponding key, and
	  //~~~possibly expensive deep test
	  for (i = ka.length - 1; i >= 0; i--) {
	    key = ka[i];
	    if (!_deepEqual(a[key], b[key], strict, actualVisitedObjects))
	      return false;
	  }
	  return true;
	}

	// 8. The non-equivalence assertion tests for any deep inequality.
	// assert.notDeepEqual(actual, expected, message_opt);
	assert$1.notDeepEqual = notDeepEqual;
	function notDeepEqual(actual, expected, message) {
	  if (_deepEqual(actual, expected, false)) {
	    fail(actual, expected, message, 'notDeepEqual', notDeepEqual);
	  }
	}

	assert$1.notDeepStrictEqual = notDeepStrictEqual;
	function notDeepStrictEqual(actual, expected, message) {
	  if (_deepEqual(actual, expected, true)) {
	    fail(actual, expected, message, 'notDeepStrictEqual', notDeepStrictEqual);
	  }
	}


	// 9. The strict equality assertion tests strict equality, as determined by ===.
	// assert.strictEqual(actual, expected, message_opt);
	assert$1.strictEqual = strictEqual;
	function strictEqual(actual, expected, message) {
	  if (actual !== expected) {
	    fail(actual, expected, message, '===', strictEqual);
	  }
	}

	// 10. The strict non-equality assertion tests for strict inequality, as
	// determined by !==.  assert.notStrictEqual(actual, expected, message_opt);
	assert$1.notStrictEqual = notStrictEqual;
	function notStrictEqual(actual, expected, message) {
	  if (actual === expected) {
	    fail(actual, expected, message, '!==', notStrictEqual);
	  }
	}

	function expectedException(actual, expected) {
	  if (!actual || !expected) {
	    return false;
	  }

	  if (Object.prototype.toString.call(expected) == '[object RegExp]') {
	    return expected.test(actual);
	  }

	  try {
	    if (actual instanceof expected) {
	      return true;
	    }
	  } catch (e) {
	    // Ignore.  The instanceof check doesn't work for arrow functions.
	  }

	  if (Error.isPrototypeOf(expected)) {
	    return false;
	  }

	  return expected.call({}, actual) === true;
	}

	function _tryBlock(block) {
	  var error;
	  try {
	    block();
	  } catch (e) {
	    error = e;
	  }
	  return error;
	}

	function _throws(shouldThrow, block, expected, message) {
	  var actual;

	  if (typeof block !== 'function') {
	    throw new TypeError('"block" argument must be a function');
	  }

	  if (typeof expected === 'string') {
	    message = expected;
	    expected = null;
	  }

	  actual = _tryBlock(block);

	  message = (expected && expected.name ? ' (' + expected.name + ').' : '.') +
	            (message ? ' ' + message : '.');

	  if (shouldThrow && !actual) {
	    fail(actual, expected, 'Missing expected exception' + message);
	  }

	  var userProvidedMessage = typeof message === 'string';
	  var isUnwantedException = !shouldThrow && isError(actual);
	  var isUnexpectedException = !shouldThrow && actual && !expected;

	  if ((isUnwantedException &&
	      userProvidedMessage &&
	      expectedException(actual, expected)) ||
	      isUnexpectedException) {
	    fail(actual, expected, 'Got unwanted exception' + message);
	  }

	  if ((shouldThrow && actual && expected &&
	      !expectedException(actual, expected)) || (!shouldThrow && actual)) {
	    throw actual;
	  }
	}

	// 11. Expected to throw an error:
	// assert.throws(block, Error_opt, message_opt);
	assert$1.throws = throws;
	function throws(block, /*optional*/error, /*optional*/message) {
	  _throws(true, block, error, message);
	}

	// EXTENSION! This is annoying to write outside this module.
	assert$1.doesNotThrow = doesNotThrow;
	function doesNotThrow(block, /*optional*/error, /*optional*/message) {
	  _throws(false, block, error, message);
	}

	assert$1.ifError = ifError;
	function ifError(err) {
	  if (err) throw err;
	}

	var assert$2 = /*#__PURE__*/Object.freeze({
		__proto__: null,
		AssertionError: AssertionError,
		assert: ok,
		deepEqual: deepEqual,
		deepStrictEqual: deepStrictEqual,
		default: assert$1,
		doesNotThrow: doesNotThrow,
		equal: equal,
		fail: fail,
		ifError: ifError,
		notDeepEqual: notDeepEqual,
		notDeepStrictEqual: notDeepStrictEqual,
		notEqual: notEqual,
		notStrictEqual: notStrictEqual,
		ok: ok,
		strictEqual: strictEqual,
		throws: throws
	});

	var require$$0 = /*@__PURE__*/getAugmentedNamespace(assert$2);

	var require$$1 = /*@__PURE__*/getAugmentedNamespace(util$2);

	var big = {exports: {}};

	/* big.js v3.1.3 https://github.com/MikeMcl/big.js/LICENCE */

	(function (module) {
	(function (global) {

		/*
		  big.js v3.1.3
		  A small, fast, easy-to-use library for arbitrary-precision decimal arithmetic.
		  https://github.com/MikeMcl/big.js/
		  Copyright (c) 2014 Michael Mclaughlin <M8ch88l@gmail.com>
		  MIT Expat Licence
		*/

		/***************************** EDITABLE DEFAULTS ******************************/

		    // The default values below must be integers within the stated ranges.

		    /*
		     * The maximum number of decimal places of the results of operations
		     * involving division: div and sqrt, and pow with negative exponents.
		     */
		    var DP = 20,                           // 0 to MAX_DP

		        /*
		         * The rounding mode used when rounding to the above decimal places.
		         *
		         * 0 Towards zero (i.e. truncate, no rounding).       (ROUND_DOWN)
		         * 1 To nearest neighbour. If equidistant, round up.  (ROUND_HALF_UP)
		         * 2 To nearest neighbour. If equidistant, to even.   (ROUND_HALF_EVEN)
		         * 3 Away from zero.                                  (ROUND_UP)
		         */
		        RM = 1,                            // 0, 1, 2 or 3

		        // The maximum value of DP and Big.DP.
		        MAX_DP = 1E6,                      // 0 to 1000000

		        // The maximum magnitude of the exponent argument to the pow method.
		        MAX_POWER = 1E6,                   // 1 to 1000000

		        /*
		         * The exponent value at and beneath which toString returns exponential
		         * notation.
		         * JavaScript's Number type: -7
		         * -1000000 is the minimum recommended exponent value of a Big.
		         */
		        E_NEG = -7,                   // 0 to -1000000

		        /*
		         * The exponent value at and above which toString returns exponential
		         * notation.
		         * JavaScript's Number type: 21
		         * 1000000 is the maximum recommended exponent value of a Big.
		         * (This limit is not enforced or checked.)
		         */
		        E_POS = 21,                   // 0 to 1000000

		/******************************************************************************/

		        // The shared prototype object.
		        P = {},
		        isValid = /^-?(\d+(\.\d*)?|\.\d+)(e[+-]?\d+)?$/i,
		        Big;


		    /*
		     * Create and return a Big constructor.
		     *
		     */
		    function bigFactory() {

		        /*
		         * The Big constructor and exported function.
		         * Create and return a new instance of a Big number object.
		         *
		         * n {number|string|Big} A numeric value.
		         */
		        function Big(n) {
		            var x = this;

		            // Enable constructor usage without new.
		            if (!(x instanceof Big)) {
		                return n === void 0 ? bigFactory() : new Big(n);
		            }

		            // Duplicate.
		            if (n instanceof Big) {
		                x.s = n.s;
		                x.e = n.e;
		                x.c = n.c.slice();
		            } else {
		                parse(x, n);
		            }

		            /*
		             * Retain a reference to this Big constructor, and shadow
		             * Big.prototype.constructor which points to Object.
		             */
		            x.constructor = Big;
		        }

		        Big.prototype = P;
		        Big.DP = DP;
		        Big.RM = RM;
		        Big.E_NEG = E_NEG;
		        Big.E_POS = E_POS;

		        return Big;
		    }


		    // Private functions


		    /*
		     * Return a string representing the value of Big x in normal or exponential
		     * notation to dp fixed decimal places or significant digits.
		     *
		     * x {Big} The Big to format.
		     * dp {number} Integer, 0 to MAX_DP inclusive.
		     * toE {number} 1 (toExponential), 2 (toPrecision) or undefined (toFixed).
		     */
		    function format(x, dp, toE) {
		        var Big = x.constructor,

		            // The index (normal notation) of the digit that may be rounded up.
		            i = dp - (x = new Big(x)).e,
		            c = x.c;

		        // Round?
		        if (c.length > ++dp) {
		            rnd(x, i, Big.RM);
		        }

		        if (!c[0]) {
		            ++i;
		        } else if (toE) {
		            i = dp;

		        // toFixed
		        } else {
		            c = x.c;

		            // Recalculate i as x.e may have changed if value rounded up.
		            i = x.e + i + 1;
		        }

		        // Append zeros?
		        for (; c.length < i; c.push(0)) {
		        }
		        i = x.e;

		        /*
		         * toPrecision returns exponential notation if the number of
		         * significant digits specified is less than the number of digits
		         * necessary to represent the integer part of the value in normal
		         * notation.
		         */
		        return toE === 1 || toE && (dp <= i || i <= Big.E_NEG) ?

		          // Exponential notation.
		          (x.s < 0 && c[0] ? '-' : '') +
		            (c.length > 1 ? c[0] + '.' + c.join('').slice(1) : c[0]) +
		              (i < 0 ? 'e' : 'e+') + i

		          // Normal notation.
		          : x.toString();
		    }


		    /*
		     * Parse the number or string value passed to a Big constructor.
		     *
		     * x {Big} A Big number instance.
		     * n {number|string} A numeric value.
		     */
		    function parse(x, n) {
		        var e, i, nL;

		        // Minus zero?
		        if (n === 0 && 1 / n < 0) {
		            n = '-0';

		        // Ensure n is string and check validity.
		        } else if (!isValid.test(n += '')) {
		            throwErr(NaN);
		        }

		        // Determine sign.
		        x.s = n.charAt(0) == '-' ? (n = n.slice(1), -1) : 1;

		        // Decimal point?
		        if ((e = n.indexOf('.')) > -1) {
		            n = n.replace('.', '');
		        }

		        // Exponential form?
		        if ((i = n.search(/e/i)) > 0) {

		            // Determine exponent.
		            if (e < 0) {
		                e = i;
		            }
		            e += +n.slice(i + 1);
		            n = n.substring(0, i);

		        } else if (e < 0) {

		            // Integer.
		            e = n.length;
		        }

		        nL = n.length;

		        // Determine leading zeros.
		        for (i = 0; i < nL && n.charAt(i) == '0'; i++) {
		        }

		        if (i == nL) {

		            // Zero.
		            x.c = [ x.e = 0 ];
		        } else {

		            // Determine trailing zeros.
		            for (; nL > 0 && n.charAt(--nL) == '0';) {
		            }

		            x.e = e - i - 1;
		            x.c = [];

		            // Convert string to array of digits without leading/trailing zeros.
		            //for (e = 0; i <= nL; x.c[e++] = +n.charAt(i++)) {
		            for (; i <= nL; x.c.push(+n.charAt(i++))) {
		            }
		        }

		        return x;
		    }


		    /*
		     * Round Big x to a maximum of dp decimal places using rounding mode rm.
		     * Called by div, sqrt and round.
		     *
		     * x {Big} The Big to round.
		     * dp {number} Integer, 0 to MAX_DP inclusive.
		     * rm {number} 0, 1, 2 or 3 (DOWN, HALF_UP, HALF_EVEN, UP)
		     * [more] {boolean} Whether the result of division was truncated.
		     */
		    function rnd(x, dp, rm, more) {
		        var u,
		            xc = x.c,
		            i = x.e + dp + 1;

		        if (rm === 1) {

		            // xc[i] is the digit after the digit that may be rounded up.
		            more = xc[i] >= 5;
		        } else if (rm === 2) {
		            more = xc[i] > 5 || xc[i] == 5 &&
		              (more || i < 0 || xc[i + 1] !== u || xc[i - 1] & 1);
		        } else if (rm === 3) {
		            more = more || xc[i] !== u || i < 0;
		        } else {
		            more = false;

		            if (rm !== 0) {
		                throwErr('!Big.RM!');
		            }
		        }

		        if (i < 1 || !xc[0]) {

		            if (more) {

		                // 1, 0.1, 0.01, 0.001, 0.0001 etc.
		                x.e = -dp;
		                x.c = [1];
		            } else {

		                // Zero.
		                x.c = [x.e = 0];
		            }
		        } else {

		            // Remove any digits after the required decimal places.
		            xc.length = i--;

		            // Round up?
		            if (more) {

		                // Rounding up may mean the previous digit has to be rounded up.
		                for (; ++xc[i] > 9;) {
		                    xc[i] = 0;

		                    if (!i--) {
		                        ++x.e;
		                        xc.unshift(1);
		                    }
		                }
		            }

		            // Remove trailing zeros.
		            for (i = xc.length; !xc[--i]; xc.pop()) {
		            }
		        }

		        return x;
		    }


		    /*
		     * Throw a BigError.
		     *
		     * message {string} The error message.
		     */
		    function throwErr(message) {
		        var err = new Error(message);
		        err.name = 'BigError';

		        throw err;
		    }


		    // Prototype/instance methods


		    /*
		     * Return a new Big whose value is the absolute value of this Big.
		     */
		    P.abs = function () {
		        var x = new this.constructor(this);
		        x.s = 1;

		        return x;
		    };


		    /*
		     * Return
		     * 1 if the value of this Big is greater than the value of Big y,
		     * -1 if the value of this Big is less than the value of Big y, or
		     * 0 if they have the same value.
		    */
		    P.cmp = function (y) {
		        var xNeg,
		            x = this,
		            xc = x.c,
		            yc = (y = new x.constructor(y)).c,
		            i = x.s,
		            j = y.s,
		            k = x.e,
		            l = y.e;

		        // Either zero?
		        if (!xc[0] || !yc[0]) {
		            return !xc[0] ? !yc[0] ? 0 : -j : i;
		        }

		        // Signs differ?
		        if (i != j) {
		            return i;
		        }
		        xNeg = i < 0;

		        // Compare exponents.
		        if (k != l) {
		            return k > l ^ xNeg ? 1 : -1;
		        }

		        i = -1;
		        j = (k = xc.length) < (l = yc.length) ? k : l;

		        // Compare digit by digit.
		        for (; ++i < j;) {

		            if (xc[i] != yc[i]) {
		                return xc[i] > yc[i] ^ xNeg ? 1 : -1;
		            }
		        }

		        // Compare lengths.
		        return k == l ? 0 : k > l ^ xNeg ? 1 : -1;
		    };


		    /*
		     * Return a new Big whose value is the value of this Big divided by the
		     * value of Big y, rounded, if necessary, to a maximum of Big.DP decimal
		     * places using rounding mode Big.RM.
		     */
		    P.div = function (y) {
		        var x = this,
		            Big = x.constructor,
		            // dividend
		            dvd = x.c,
		            //divisor
		            dvs = (y = new Big(y)).c,
		            s = x.s == y.s ? 1 : -1,
		            dp = Big.DP;

		        if (dp !== ~~dp || dp < 0 || dp > MAX_DP) {
		            throwErr('!Big.DP!');
		        }

		        // Either 0?
		        if (!dvd[0] || !dvs[0]) {

		            // If both are 0, throw NaN
		            if (dvd[0] == dvs[0]) {
		                throwErr(NaN);
		            }

		            // If dvs is 0, throw +-Infinity.
		            if (!dvs[0]) {
		                throwErr(s / 0);
		            }

		            // dvd is 0, return +-0.
		            return new Big(s * 0);
		        }

		        var dvsL, dvsT, next, cmp, remI, u,
		            dvsZ = dvs.slice(),
		            dvdI = dvsL = dvs.length,
		            dvdL = dvd.length,
		            // remainder
		            rem = dvd.slice(0, dvsL),
		            remL = rem.length,
		            // quotient
		            q = y,
		            qc = q.c = [],
		            qi = 0,
		            digits = dp + (q.e = x.e - y.e) + 1;

		        q.s = s;
		        s = digits < 0 ? 0 : digits;

		        // Create version of divisor with leading zero.
		        dvsZ.unshift(0);

		        // Add zeros to make remainder as long as divisor.
		        for (; remL++ < dvsL; rem.push(0)) {
		        }

		        do {

		            // 'next' is how many times the divisor goes into current remainder.
		            for (next = 0; next < 10; next++) {

		                // Compare divisor and remainder.
		                if (dvsL != (remL = rem.length)) {
		                    cmp = dvsL > remL ? 1 : -1;
		                } else {

		                    for (remI = -1, cmp = 0; ++remI < dvsL;) {

		                        if (dvs[remI] != rem[remI]) {
		                            cmp = dvs[remI] > rem[remI] ? 1 : -1;
		                            break;
		                        }
		                    }
		                }

		                // If divisor < remainder, subtract divisor from remainder.
		                if (cmp < 0) {

		                    // Remainder can't be more than 1 digit longer than divisor.
		                    // Equalise lengths using divisor with extra leading zero?
		                    for (dvsT = remL == dvsL ? dvs : dvsZ; remL;) {

		                        if (rem[--remL] < dvsT[remL]) {
		                            remI = remL;

		                            for (; remI && !rem[--remI]; rem[remI] = 9) {
		                            }
		                            --rem[remI];
		                            rem[remL] += 10;
		                        }
		                        rem[remL] -= dvsT[remL];
		                    }
		                    for (; !rem[0]; rem.shift()) {
		                    }
		                } else {
		                    break;
		                }
		            }

		            // Add the 'next' digit to the result array.
		            qc[qi++] = cmp ? next : ++next;

		            // Update the remainder.
		            if (rem[0] && cmp) {
		                rem[remL] = dvd[dvdI] || 0;
		            } else {
		                rem = [ dvd[dvdI] ];
		            }

		        } while ((dvdI++ < dvdL || rem[0] !== u) && s--);

		        // Leading zero? Do not remove if result is simply zero (qi == 1).
		        if (!qc[0] && qi != 1) {

		            // There can't be more than one zero.
		            qc.shift();
		            q.e--;
		        }

		        // Round?
		        if (qi > digits) {
		            rnd(q, dp, Big.RM, rem[0] !== u);
		        }

		        return q;
		    };


		    /*
		     * Return true if the value of this Big is equal to the value of Big y,
		     * otherwise returns false.
		     */
		    P.eq = function (y) {
		        return !this.cmp(y);
		    };


		    /*
		     * Return true if the value of this Big is greater than the value of Big y,
		     * otherwise returns false.
		     */
		    P.gt = function (y) {
		        return this.cmp(y) > 0;
		    };


		    /*
		     * Return true if the value of this Big is greater than or equal to the
		     * value of Big y, otherwise returns false.
		     */
		    P.gte = function (y) {
		        return this.cmp(y) > -1;
		    };


		    /*
		     * Return true if the value of this Big is less than the value of Big y,
		     * otherwise returns false.
		     */
		    P.lt = function (y) {
		        return this.cmp(y) < 0;
		    };


		    /*
		     * Return true if the value of this Big is less than or equal to the value
		     * of Big y, otherwise returns false.
		     */
		    P.lte = function (y) {
		         return this.cmp(y) < 1;
		    };


		    /*
		     * Return a new Big whose value is the value of this Big minus the value
		     * of Big y.
		     */
		    P.sub = P.minus = function (y) {
		        var i, j, t, xLTy,
		            x = this,
		            Big = x.constructor,
		            a = x.s,
		            b = (y = new Big(y)).s;

		        // Signs differ?
		        if (a != b) {
		            y.s = -b;
		            return x.plus(y);
		        }

		        var xc = x.c.slice(),
		            xe = x.e,
		            yc = y.c,
		            ye = y.e;

		        // Either zero?
		        if (!xc[0] || !yc[0]) {

		            // y is non-zero? x is non-zero? Or both are zero.
		            return yc[0] ? (y.s = -b, y) : new Big(xc[0] ? x : 0);
		        }

		        // Determine which is the bigger number.
		        // Prepend zeros to equalise exponents.
		        if (a = xe - ye) {

		            if (xLTy = a < 0) {
		                a = -a;
		                t = xc;
		            } else {
		                ye = xe;
		                t = yc;
		            }

		            t.reverse();
		            for (b = a; b--; t.push(0)) {
		            }
		            t.reverse();
		        } else {

		            // Exponents equal. Check digit by digit.
		            j = ((xLTy = xc.length < yc.length) ? xc : yc).length;

		            for (a = b = 0; b < j; b++) {

		                if (xc[b] != yc[b]) {
		                    xLTy = xc[b] < yc[b];
		                    break;
		                }
		            }
		        }

		        // x < y? Point xc to the array of the bigger number.
		        if (xLTy) {
		            t = xc;
		            xc = yc;
		            yc = t;
		            y.s = -y.s;
		        }

		        /*
		         * Append zeros to xc if shorter. No need to add zeros to yc if shorter
		         * as subtraction only needs to start at yc.length.
		         */
		        if (( b = (j = yc.length) - (i = xc.length) ) > 0) {

		            for (; b--; xc[i++] = 0) {
		            }
		        }

		        // Subtract yc from xc.
		        for (b = i; j > a;){

		            if (xc[--j] < yc[j]) {

		                for (i = j; i && !xc[--i]; xc[i] = 9) {
		                }
		                --xc[i];
		                xc[j] += 10;
		            }
		            xc[j] -= yc[j];
		        }

		        // Remove trailing zeros.
		        for (; xc[--b] === 0; xc.pop()) {
		        }

		        // Remove leading zeros and adjust exponent accordingly.
		        for (; xc[0] === 0;) {
		            xc.shift();
		            --ye;
		        }

		        if (!xc[0]) {

		            // n - n = +0
		            y.s = 1;

		            // Result must be zero.
		            xc = [ye = 0];
		        }

		        y.c = xc;
		        y.e = ye;

		        return y;
		    };


		    /*
		     * Return a new Big whose value is the value of this Big modulo the
		     * value of Big y.
		     */
		    P.mod = function (y) {
		        var yGTx,
		            x = this,
		            Big = x.constructor,
		            a = x.s,
		            b = (y = new Big(y)).s;

		        if (!y.c[0]) {
		            throwErr(NaN);
		        }

		        x.s = y.s = 1;
		        yGTx = y.cmp(x) == 1;
		        x.s = a;
		        y.s = b;

		        if (yGTx) {
		            return new Big(x);
		        }

		        a = Big.DP;
		        b = Big.RM;
		        Big.DP = Big.RM = 0;
		        x = x.div(y);
		        Big.DP = a;
		        Big.RM = b;

		        return this.minus( x.times(y) );
		    };


		    /*
		     * Return a new Big whose value is the value of this Big plus the value
		     * of Big y.
		     */
		    P.add = P.plus = function (y) {
		        var t,
		            x = this,
		            Big = x.constructor,
		            a = x.s,
		            b = (y = new Big(y)).s;

		        // Signs differ?
		        if (a != b) {
		            y.s = -b;
		            return x.minus(y);
		        }

		        var xe = x.e,
		            xc = x.c,
		            ye = y.e,
		            yc = y.c;

		        // Either zero?
		        if (!xc[0] || !yc[0]) {

		            // y is non-zero? x is non-zero? Or both are zero.
		            return yc[0] ? y : new Big(xc[0] ? x : a * 0);
		        }
		        xc = xc.slice();

		        // Prepend zeros to equalise exponents.
		        // Note: Faster to use reverse then do unshifts.
		        if (a = xe - ye) {

		            if (a > 0) {
		                ye = xe;
		                t = yc;
		            } else {
		                a = -a;
		                t = xc;
		            }

		            t.reverse();
		            for (; a--; t.push(0)) {
		            }
		            t.reverse();
		        }

		        // Point xc to the longer array.
		        if (xc.length - yc.length < 0) {
		            t = yc;
		            yc = xc;
		            xc = t;
		        }
		        a = yc.length;

		        /*
		         * Only start adding at yc.length - 1 as the further digits of xc can be
		         * left as they are.
		         */
		        for (b = 0; a;) {
		            b = (xc[--a] = xc[a] + yc[a] + b) / 10 | 0;
		            xc[a] %= 10;
		        }

		        // No need to check for zero, as +x + +y != 0 && -x + -y != 0

		        if (b) {
		            xc.unshift(b);
		            ++ye;
		        }

		         // Remove trailing zeros.
		        for (a = xc.length; xc[--a] === 0; xc.pop()) {
		        }

		        y.c = xc;
		        y.e = ye;

		        return y;
		    };


		    /*
		     * Return a Big whose value is the value of this Big raised to the power n.
		     * If n is negative, round, if necessary, to a maximum of Big.DP decimal
		     * places using rounding mode Big.RM.
		     *
		     * n {number} Integer, -MAX_POWER to MAX_POWER inclusive.
		     */
		    P.pow = function (n) {
		        var x = this,
		            one = new x.constructor(1),
		            y = one,
		            isNeg = n < 0;

		        if (n !== ~~n || n < -MAX_POWER || n > MAX_POWER) {
		            throwErr('!pow!');
		        }

		        n = isNeg ? -n : n;

		        for (;;) {

		            if (n & 1) {
		                y = y.times(x);
		            }
		            n >>= 1;

		            if (!n) {
		                break;
		            }
		            x = x.times(x);
		        }

		        return isNeg ? one.div(y) : y;
		    };


		    /*
		     * Return a new Big whose value is the value of this Big rounded to a
		     * maximum of dp decimal places using rounding mode rm.
		     * If dp is not specified, round to 0 decimal places.
		     * If rm is not specified, use Big.RM.
		     *
		     * [dp] {number} Integer, 0 to MAX_DP inclusive.
		     * [rm] 0, 1, 2 or 3 (ROUND_DOWN, ROUND_HALF_UP, ROUND_HALF_EVEN, ROUND_UP)
		     */
		    P.round = function (dp, rm) {
		        var x = this,
		            Big = x.constructor;

		        if (dp == null) {
		            dp = 0;
		        } else if (dp !== ~~dp || dp < 0 || dp > MAX_DP) {
		            throwErr('!round!');
		        }
		        rnd(x = new Big(x), dp, rm == null ? Big.RM : rm);

		        return x;
		    };


		    /*
		     * Return a new Big whose value is the square root of the value of this Big,
		     * rounded, if necessary, to a maximum of Big.DP decimal places using
		     * rounding mode Big.RM.
		     */
		    P.sqrt = function () {
		        var estimate, r, approx,
		            x = this,
		            Big = x.constructor,
		            xc = x.c,
		            i = x.s,
		            e = x.e,
		            half = new Big('0.5');

		        // Zero?
		        if (!xc[0]) {
		            return new Big(x);
		        }

		        // If negative, throw NaN.
		        if (i < 0) {
		            throwErr(NaN);
		        }

		        // Estimate.
		        i = Math.sqrt(x.toString());

		        // Math.sqrt underflow/overflow?
		        // Pass x to Math.sqrt as integer, then adjust the result exponent.
		        if (i === 0 || i === 1 / 0) {
		            estimate = xc.join('');

		            if (!(estimate.length + e & 1)) {
		                estimate += '0';
		            }

		            r = new Big( Math.sqrt(estimate).toString() );
		            r.e = ((e + 1) / 2 | 0) - (e < 0 || e & 1);
		        } else {
		            r = new Big(i.toString());
		        }

		        i = r.e + (Big.DP += 4);

		        // Newton-Raphson iteration.
		        do {
		            approx = r;
		            r = half.times( approx.plus( x.div(approx) ) );
		        } while ( approx.c.slice(0, i).join('') !==
		                       r.c.slice(0, i).join('') );

		        rnd(r, Big.DP -= 4, Big.RM);

		        return r;
		    };


		    /*
		     * Return a new Big whose value is the value of this Big times the value of
		     * Big y.
		     */
		    P.mul = P.times = function (y) {
		        var c,
		            x = this,
		            Big = x.constructor,
		            xc = x.c,
		            yc = (y = new Big(y)).c,
		            a = xc.length,
		            b = yc.length,
		            i = x.e,
		            j = y.e;

		        // Determine sign of result.
		        y.s = x.s == y.s ? 1 : -1;

		        // Return signed 0 if either 0.
		        if (!xc[0] || !yc[0]) {
		            return new Big(y.s * 0);
		        }

		        // Initialise exponent of result as x.e + y.e.
		        y.e = i + j;

		        // If array xc has fewer digits than yc, swap xc and yc, and lengths.
		        if (a < b) {
		            c = xc;
		            xc = yc;
		            yc = c;
		            j = a;
		            a = b;
		            b = j;
		        }

		        // Initialise coefficient array of result with zeros.
		        for (c = new Array(j = a + b); j--; c[j] = 0) {
		        }

		        // Multiply.

		        // i is initially xc.length.
		        for (i = b; i--;) {
		            b = 0;

		            // a is yc.length.
		            for (j = a + i; j > i;) {

		                // Current sum of products at this digit position, plus carry.
		                b = c[j] + yc[i] * xc[j - i - 1] + b;
		                c[j--] = b % 10;

		                // carry
		                b = b / 10 | 0;
		            }
		            c[j] = (c[j] + b) % 10;
		        }

		        // Increment result exponent if there is a final carry.
		        if (b) {
		            ++y.e;
		        }

		        // Remove any leading zero.
		        if (!c[0]) {
		            c.shift();
		        }

		        // Remove trailing zeros.
		        for (i = c.length; !c[--i]; c.pop()) {
		        }
		        y.c = c;

		        return y;
		    };


		    /*
		     * Return a string representing the value of this Big.
		     * Return exponential notation if this Big has a positive exponent equal to
		     * or greater than Big.E_POS, or a negative exponent equal to or less than
		     * Big.E_NEG.
		     */
		    P.toString = P.valueOf = P.toJSON = function () {
		        var x = this,
		            Big = x.constructor,
		            e = x.e,
		            str = x.c.join(''),
		            strL = str.length;

		        // Exponential notation?
		        if (e <= Big.E_NEG || e >= Big.E_POS) {
		            str = str.charAt(0) + (strL > 1 ? '.' + str.slice(1) : '') +
		              (e < 0 ? 'e' : 'e+') + e;

		        // Negative exponent?
		        } else if (e < 0) {

		            // Prepend zeros.
		            for (; ++e; str = '0' + str) {
		            }
		            str = '0.' + str;

		        // Positive exponent?
		        } else if (e > 0) {

		            if (++e > strL) {

		                // Append zeros.
		                for (e -= strL; e-- ; str += '0') {
		                }
		            } else if (e < strL) {
		                str = str.slice(0, e) + '.' + str.slice(e);
		            }

		        // Exponent zero.
		        } else if (strL > 1) {
		            str = str.charAt(0) + '.' + str.slice(1);
		        }

		        // Avoid '-0'
		        return x.s < 0 && x.c[0] ? '-' + str : str;
		    };


		    /*
		     ***************************************************************************
		     * If toExponential, toFixed, toPrecision and format are not required they
		     * can safely be commented-out or deleted. No redundant code will be left.
		     * format is used only by toExponential, toFixed and toPrecision.
		     ***************************************************************************
		     */


		    /*
		     * Return a string representing the value of this Big in exponential
		     * notation to dp fixed decimal places and rounded, if necessary, using
		     * Big.RM.
		     *
		     * [dp] {number} Integer, 0 to MAX_DP inclusive.
		     */
		    P.toExponential = function (dp) {

		        if (dp == null) {
		            dp = this.c.length - 1;
		        } else if (dp !== ~~dp || dp < 0 || dp > MAX_DP) {
		            throwErr('!toExp!');
		        }

		        return format(this, dp, 1);
		    };


		    /*
		     * Return a string representing the value of this Big in normal notation
		     * to dp fixed decimal places and rounded, if necessary, using Big.RM.
		     *
		     * [dp] {number} Integer, 0 to MAX_DP inclusive.
		     */
		    P.toFixed = function (dp) {
		        var str,
		            x = this,
		            Big = x.constructor,
		            neg = Big.E_NEG,
		            pos = Big.E_POS;

		        // Prevent the possibility of exponential notation.
		        Big.E_NEG = -(Big.E_POS = 1 / 0);

		        if (dp == null) {
		            str = x.toString();
		        } else if (dp === ~~dp && dp >= 0 && dp <= MAX_DP) {
		            str = format(x, x.e + dp);

		            // (-0).toFixed() is '0', but (-0.1).toFixed() is '-0'.
		            // (-0).toFixed(1) is '0.0', but (-0.01).toFixed(1) is '-0.0'.
		            if (x.s < 0 && x.c[0] && str.indexOf('-') < 0) {
		        //E.g. -0.5 if rounded to -0 will cause toString to omit the minus sign.
		                str = '-' + str;
		            }
		        }
		        Big.E_NEG = neg;
		        Big.E_POS = pos;

		        if (!str) {
		            throwErr('!toFix!');
		        }

		        return str;
		    };


		    /*
		     * Return a string representing the value of this Big rounded to sd
		     * significant digits using Big.RM. Use exponential notation if sd is less
		     * than the number of digits necessary to represent the integer part of the
		     * value in normal notation.
		     *
		     * sd {number} Integer, 1 to MAX_DP inclusive.
		     */
		    P.toPrecision = function (sd) {

		        if (sd == null) {
		            return this.toString();
		        } else if (sd !== ~~sd || sd < 1 || sd > MAX_DP) {
		            throwErr('!toPre!');
		        }

		        return format(this, sd - 1, 2);
		    };


		    // Export


		    Big = bigFactory();

		    //AMD.
		    if (module.exports) {
		        module.exports = Big;
		        module.exports.Big = Big;

		    //Browser.
		    } else {
		        global.Big = Big;
		    }
		})(commonjsGlobal); 
	} (big));

	var bigExports = big.exports;

	var assert = require$$0;
	var util   = require$$1;
	var Big = bigExports;
	var Tars    = tars.exports = {};
	var BIT32 = 4294967296;
	var BIT31 = BIT32 / 2;

	/**
	 * 异常类
	 */
	Tars.Exception = function ($code, $message) {
	    this.code    = $code;
	    this.message = $message;
	};
	util.inherits(Tars.Exception, Error);

	Tars.EncodeException = function ($message) {
	    this.code    = -2;
	    this.message = $message;
	};
	util.inherits(Tars.EncodeException, Tars.Exception);

	Tars.DecodeException = function ($message) {
	    this.code    = -1;
	    this.message = $message;
	};
	util.inherits(Tars.DecodeException, Tars.Exception);

	Tars.DecodeMismatch = function ($message) {
	    this.code    = -1;
	    this.message = $message;
	};
	util.inherits(Tars.DecodeMismatch, Tars.DecodeException);

	Tars.DecodeRequireNotExist = function ($message) {
	    this.code    = -1;
	    this.message = $message;
	};
	util.inherits(Tars.DecodeRequireNotExist, Tars.DecodeException);

	Tars.DecodeInvalidValue = function ($message) {
	    this.code    = -1;
	    this.message = $message;
	};
	util.inherits(Tars.DecodeInvalidValue, Tars.DecodeException);

	Tars.TupNotFoundKey = function ($message) {
	    this.code    = -1;
	    this.message = $message;
	};
	util.inherits(Tars.TupNotFoundKey, Tars.Exception);

	/**
	 * TARS编解码底层辅助类
	 */
	Tars.DataHelp = {
	    EN_INT8         : 0,
	    EN_INT16        : 1,
	    EN_INT32        : 2,
	    EN_INT64        : 3,
	    EN_FLOAT        : 4,
	    EN_DOUBLE       : 5,
	    EN_STRING1      : 6,
	    EN_STRING4      : 7,
	    EN_MAP          : 8,
	    EN_LIST         : 9,
	    EN_STRUCTBEGIN  : 10,
	    EN_STRUCTEND    : 11,
	    EN_ZERO         : 12,
	    EN_SIMPLELIST   : 13
	};

	Tars.Boolean = {
	    _write      : function(os, tag, val) { return os.writeBoolean(tag, val);      },
	    _read       : function(is, tag, def) { return is.readBoolean(tag, true, def); },
	    _classname  : "bool"
	};

	Tars.Int8 = {
	    _write      : function(os, tag, val) { return os.writeInt8(tag, val); },
	    _read       : function(is, tag, def) { return is.readInt8(tag, true, def); },
	    _classname  : "char"
	};

	Tars.Int16 = {
	    _write      : function(os, tag, val) { return os.writeInt16(tag, val); },
	    _read       : function(is, tag, def) { return is.readInt16(tag, true, def); },
	    _classname  : "short"
	};

	Tars.Int32 = {
	    _write      : function(os, tag, val) { return os.writeInt32(tag, val); },
	    _read       : function(is, tag, def) { return is.readInt32(tag, true, def); },
	    _classname  : "int32"
	};

	Tars.Int64 = {
	    _write      : function(os, tag, val, bString) { return os.writeInt64(tag, val, bString); },
	    _read       : function(is, tag, def, bString) { return is.readInt64(tag, true, def, bString); },
	    _classname  : "int64"
	};

	Tars.UInt8 = {
	    _write      : function(os, tag, val) { return os.writeInt16(tag, val); },
	    _read       : function(is, tag, def) { return is.readInt16(tag, true, def); },
	    _classname  : "short"
	};

	Tars.UInt16 = {
	    _write      : function(os, tag, val) { return os.writeInt32(tag, val); },
	    _read       : function(is, tag, def) { return is.readInt32(tag, true, def); },
	    _classname  : "int32"
	};

	Tars.UInt32 = {
	    _write      : function(os, tag, val) { return os.writeInt64(tag, val);      },
	    _read       : function(is, tag, def) { return is.readInt64(tag, true, def); },
	    _classname  : "int64"
	};

	Tars.Float = {
	    _write      : function(os, tag, val) { return os.writeFloat(tag, val);      },
	    _read       : function(is, tag, def) { return is.readFloat(tag, true, def); },
	    _classname  : "float"
	};

	Tars.Double = {
	    _write      : function(os, tag, val) { return os.writeDouble(tag, val);      },
	    _read       : function(is, tag, def) { return is.readDouble(tag, true, def); },
	    _classname  : "double"
	};

	Tars.String = {
	    _write      : function(os, tag, val, bRaw) { return os.writeString(tag, val, bRaw);      },
	    _read       : function(is, tag, def, bRaw) { return is.readString(tag, true, def, bRaw); },
	    _classname  : "string"
	};

	Tars.Enum    = {
	    _write      : function(os, tag, val) { return os.writeInt32(tag, val);        },
	    _read       : function(is, tag, def) { return is.readInt32(tag, true, def);   },
	    _classname  : "int32"
	};

	/**
	 * TARS-List实现类
	 */
	var HeroList = function (proto, bValue) {
	    this._proto     = proto;
	    this._bValue = bValue || 0;
	    this.value      = new Array();
	    this._classname = "List<" + proto._classname + ">";
	};

	HeroList.prototype._write  = function(os, tag, val, bRaw, bString) { return os.writeList(tag, val, bRaw, bString); };
	HeroList.prototype._read   = function(is, tag, def, bRaw, bString) { return is.readList(tag, true, def, bRaw, bString); };
	HeroList.prototype.new     = function() { return new HeroList(this._proto); };
	HeroList.prototype.at      = function(index) { return this.value[index]; };
	HeroList.prototype.push    = function(value) { this.value.push(value); };
	HeroList.prototype.forEach = function(callback) {
	    for (var i = 0; i < this.value.length; i++) {
	        if (callback.call(null, this.value[i], i, this.value) == false) break;
	    }
	};
	HeroList.prototype.toObject = function () {
	    var tmp = [];
	    for (var i = 0, len = this.value.length; i < len; i++){
	        tmp.push(!this.value[i].toObject?this.value[i]:this.value[i].toObject());
	    }

	    return tmp;
	};

	HeroList.prototype.readFromObject = function (json) {
	    var vsimple = !this._proto.create && !this._proto._vproto && !this._proto._proto && !this._proto.new;

	    for (var i = 0, len = json.length; i < len; i++) {
	        if (vsimple) {
	            this.push(json[i]);
	        } else {
	            var temp = this._proto.new();
	            temp.readFromObject(json[i]);
	            this.push(temp);
	        }
	    }

	    return this;
	};

	HeroList.prototype.__defineGetter__("length", function () { return this.value.length; });

	Tars.List = function(proto, bValue) {
	    return new HeroList(proto, bValue);
	};

	/**
	 * TARS-Map实现类
	 */
	var MultiMap = function(kproto, vproto, bKey, bValue) {
	    this._kproto    = kproto;
	    this._vproto    = vproto;
	    this._bKey = bKey || 0;
	    this._bValue = bValue || 0;
	    this.keys       = new Object();
	    this.value      = new Object();
	    this._classname = "map<" + kproto._classname + "," + vproto._classname + ">";
	};

	MultiMap.prototype._write  = function(os, tag, val, bRaw)   { return os.writeMap(tag, val, bRaw);           };
	MultiMap.prototype._read   = function(is, tag, def, bRaw)   { return is.readMap(tag, true, def, bRaw);      };
	MultiMap.prototype.put     = function(key, value)     { this.insert(key, value);                };
	MultiMap.prototype.set     = function(key, value)     { this.insert(key, value);                };
	MultiMap.prototype.remove  = function(key)            { delete this.keys[key._genKey()]; delete this.value[key._genKey()]; };
	MultiMap.prototype.size    = function()               { return Object.keys(this.keys || {}).length;};
	MultiMap.prototype.has     = function(key)            { return this.keys.hasOwnProperty(key._genKey()); };
	MultiMap.prototype.insert  = function(key, value)     {
	    var keys = Object.keys(this.keys || {});
	    for(var i = 0; i < keys.length; i++)
	    {
	        var anItem = keys[i];
	        if (key._equal(this.keys[anItem])) {
	            this.value[anItem] = value;
	            return ;
	        }
	    }

	    this.keys[key._genKey()]  = key;
	    this.value[key._genKey()] = value;
	};

	MultiMap.prototype.get = function(key) {
	    var keys = Object.keys(this.keys || {});
	    for(var i = 0; i < keys.length; i++)
	    {
	        var anItem = keys[i];
	        if (key._equal(this.keys[anItem])) {
	            return this.value[anItem];
	        }
	    }
	    return undefined;
	};

	MultiMap.prototype.clear   = function() {
	    delete this.keys;
	    delete this.value;
	    this.keys  = new Object();
	    this.value = new Object();
	};

	MultiMap.prototype.forEach = function(callback) {
	    var keys = Object.keys(this.value || {});
	    for(var i = 0; i < keys.length; i++)
	    {
	        var key = keys[i];
	        if (callback.call(null, this.keys[key], this.value[key]) == false)
	            break;
	    }
	};

	MultiMap.prototype.toObject = function () {
	    assert(false, "multimap has no toObject function");
	};

	MultiMap.prototype.readFromObject = function () {
	    assert(false, "multimap has no toObject readFromObject");
	};

	var HeroMap = function (kproto, vproto, bKey, bValue) {
	    this._kproto    = kproto;
	    this._vproto    = vproto;
	    this._bKey = bKey || 0;
	    this._bValue = bValue || 0;
	    this.value      = new Object();
	    this._classname = "map<" + kproto._classname + "," + vproto._classname + ">";
	};

	HeroMap.prototype._write  = function(os, tag, val)   { return os.writeMap(tag, val);                       };
	HeroMap.prototype._read   = function(is, tag, def)   { return is.readMap(tag, true, def);                  };
	HeroMap.prototype.new     = function()               { return new HeroMap(this._kproto, this._vproto);     };
	HeroMap.prototype.put     = function(key, value)     { this.insert(key, value);                            };
	HeroMap.prototype.set     = function(key, value)     { this.insert(key, value);                            };
	HeroMap.prototype.remove  = function(key)            { delete this.value[key];                             };
	HeroMap.prototype.size    = function()               { return Object.keys(this.value || {}).length;        };
	HeroMap.prototype.has     = function(key)            { return this.value.hasOwnProperty(key);              };
	HeroMap.prototype.insert  = function(key, value)     { this.value[key] = value;                            };
	HeroMap.prototype.get     = function(key)            { return this.value[key];                             };
	HeroMap.prototype.clear   = function()               { delete this.value; this.value = new Object();       };
	HeroMap.prototype.forEach = function(callback, bKey)       {
	    var keys = Object.keys(this.value || {});
	    for(var i = 0; i < keys.length; i++)
	    {
	        var key = keys[i];
	        switch (this._kproto){
	            case Tars.Int8:
	            case Tars.Int16:
	            case Tars.Int32:
	            case Tars.UInt8:
	            case Tars.UInt16:
	            case Tars.UInt32:
	            case Tars.Float:
	            case Tars.Double:
	                key=Number(key);
	                break;
	            case Tars.Int64:
	                if(!bKey){
	                    key=Number(key);
	                }
	                break;
	        }
	        if (callback.call(null, key, this.value[key]) == false)
	            break;
	    }
	};

	HeroMap.prototype.toObject = function () {
	    var tmp = {};
	    var keys = Object.keys(this.value || {});
	    for(var i = 0; i < keys.length; i++)
	    {
	        var key = keys[i];
	        tmp[key] = !this.value[key].toObject?this.value[key]:this.value[key].toObject();
	    }

	    return tmp;
	};

	HeroMap.prototype.readFromObject = function (json) {
	    var vsimple = !this._vproto.create && !this._vproto._vproto && !this._vproto._proto;

	    var keys = Object.keys(json || {});
	    for(var i = 0; i < keys.length; i++)
	    {
	        var key = keys[i];
	        if (vsimple) {
	            this.insert(key, json[key]);
	        } else {
	            var temp = this._vproto.new();
	            temp.readFromObject(json[key]);
	            this.insert(key, temp);
	        }
	    }
	};

	Tars.Map = function(kproto, vproto, bKey, bValue) {
	    if (kproto.prototype && kproto.prototype._equal) {
	        return new MultiMap(kproto, vproto, bKey, bValue);
	    }

	    return new HeroMap(kproto, vproto, bKey, bValue);
	};

	/**
	 * 适用于NodeJS支持的Buffer的实现类
	 */
	var createNodeBuffer = (function () {
	    if ('allocUnsafe' in Buffer$1) {
	        return function (data) {
	            return Buffer$1.allocUnsafe(data);
	        }
	    } else {
	        return function (data) {
	            return new Buffer$1(data);
	        }
	    }
	}());

	Tars.BinBuffer = function (buffer) {
	    if(!buffer)
	    {
	        buffer = createNodeBuffer(0);
	    }
	    this._buffer    = (buffer != undefined && buffer instanceof Buffer$1)?buffer:null;
	    this._length    = (buffer != undefined && buffer instanceof Buffer$1)?buffer.length:0;
	    this._capacity  = this._length;
	    this._position  = 0;
	};
	Tars.BinBuffer._classname = "list<char>";

	Tars.BinBuffer.prototype.__defineGetter__("length",   function () { return this._length;   });
	Tars.BinBuffer.prototype.__defineGetter__("capacity", function () { return this._capacity; });
	Tars.BinBuffer.prototype.__defineGetter__("position", function () { return this._position; });
	Tars.BinBuffer.prototype.__defineSetter__("position", function (position) { this._position = position; });

	Tars.BinBuffer._write = function (os, tag, val) {
	    return os.writeBytes(tag, val);
	};

	Tars.BinBuffer._read = function (os, tag, def) {
	    return os.readBytes(tag, true, def);
	};

	Tars.BinBuffer.new = function () {
	    return new Tars.BinBuffer();
	};

	Tars.BinBuffer.from = function (data) {
	    var binBuffer = new Tars.BinBuffer();
	    binBuffer.writeString(data);
	    return binBuffer;
	};

	Tars.BinBuffer.prototype.reset = function () {
	    this._length    = 0;
	    this._position  = 0;
	};

	Tars.BinBuffer.prototype._allocate = function (byteLength) {
	    if (this._capacity > this._position + byteLength) {
	        return ;
	    }

	    this._capacity = Math.max(512, (this._position + byteLength) * 2);
	    var temp = createNodeBuffer(this._capacity);
	    if (this._buffer != null) {
	        this._buffer.copy(temp, 0, 0, this._position);
	        this._buffer = undefined;
	    }

	    this._buffer = temp;
	};

	Tars.BinBuffer.prototype.replace = function (srcBuffer, offset, byteLength) {
	    srcBuffer.copy(this._buffer, 0, offset, offset + byteLength);
	};

	Tars.BinBuffer.prototype.writeInt8 = function (value) {
	    value = +value;
	    this._allocate(1);
	    this._buffer.writeInt8(value, this._position);
	    this._position += 1;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeUInt8 = function (value) {
	    value = +value;
	    this._allocate(1);
	    this._buffer.writeUInt8(value, this._position);
	    this._position += 1;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeInt16 = function (value) {
	    value = +value;
	    this._allocate(2);
	    this._buffer.writeInt16BE(value, this._position);
	    this._position += 2;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeUInt16 = function (value) {
	    value = +value;
	    this._allocate(2);
	    this._buffer.writeUInt16BE(value, this._position);
	    this._position += 2;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeInt32 = function (value) {
	    value = +value;
	    this._allocate(4);
	    this._buffer.writeInt32BE(value, this._position);
	    this._position += 4;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeUInt32 = function (value) {
	    value = +value;
	    this._allocate(4);
	    this._buffer.writeUInt32BE(value, this._position);
	    this._position += 4;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeInt64  = function (value, bString) {
	    var H4, L4;
	    if (bString === true || bString === 1) {
	        //字符串int64写入，支持int64精度
	        var val = new Big(value);
	        if (val.s === 1) {
	            H4 = +val.div(BIT32).round(0,0).toString();
	            L4 = +val.mod(BIT32).toString();
	        } else {
	            H4 = val.div(BIT32).round(0,3);
	            L4 = +val.minus((new Big(H4)).times(BIT32)).toString();
	            H4 = +H4.plus(BIT32).toString();
	        }
	    } else {
	        //Number写入，支持到2^53-1的精度
	        var val = +value;
	        if (val > 0){
	            H4 = Math.floor(val/BIT32);
	            L4 = val - H4 * BIT32;
	        } else {
	            H4 = Math.floor(val/BIT32);
	            L4 = val - H4 * BIT32;
	            H4 += BIT32;
	        }
	    }

	    this._allocate(8);
	    this._buffer.writeUInt32BE(H4, this._position);
	    this._buffer.writeUInt32BE(L4, this._position + 4);
	    this._position += 8;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeFloat = function (value) {
	    this._allocate(4);
	    this._buffer.writeFloatBE(value, this._position);
	    this._position += 4;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeDouble = function (value) {
	    this._allocate(8);
	    this._buffer.writeDoubleBE(value, this._position);
	    this._position += 8;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeString = function (value, ByteLength, bRaw) {
	    if (bRaw === true || bRaw === 1) {
	        this._allocate(ByteLength);
	        value.copy(this._buffer, this._position);
	        this._position += ByteLength;
	        this._length = this._position;
	        return ;
	    }

	    var byteLength = ByteLength || Buffer$1.byteLength(value);
	    this._allocate(byteLength);

	    this._buffer.write(value, this._position, byteLength, "utf8");


	    this._position += byteLength;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeBinBuffer = function (srcBinBuffer) {
	    if (srcBinBuffer._length == 0 || srcBinBuffer._buffer == null) return ;

	    this._allocate(srcBinBuffer.length);
	    srcBinBuffer._buffer.copy(this._buffer, this._position, 0, srcBinBuffer._length);
	    this._position += srcBinBuffer._length;
	    this._length = this._position;
	};

	Tars.BinBuffer.prototype.writeNodeBuffer = function (srcBuffer, offset, byteLength) {
	    offset      = (offset == undefined)?0:offset;
	    byteLength  = (byteLength == undefined)?srcBuffer.length:byteLength;

	    this._allocate(byteLength);
	    srcBuffer.copy(this._buffer, this._position, offset, offset + byteLength);
	    this._length   += byteLength;
	    this._position += byteLength;
	};

	Tars.BinBuffer.prototype.readInt8 = function () {
	    return this._buffer.readInt8(this._position++);
	};

	Tars.BinBuffer.prototype.readInt16 = function () {
	    this._position += 2;
	    return this._buffer.readInt16BE(this._position - 2);
	};

	Tars.BinBuffer.prototype.readInt32 = function () {
	    this._position += 4;
	    return this._buffer.readInt32BE(this._position - 4);
	};

	Tars.BinBuffer.prototype.readUInt8 = function () {
	    this._position += 1;
	    return this._buffer.readUInt8(this._position - 1);
	};

	Tars.BinBuffer.prototype.readUInt16 = function () {
	    this._position += 2;
	    return this._buffer.readUInt16BE(this._position - 2);
	};

	Tars.BinBuffer.prototype.readUInt32 = function () {
	    this._position += 4;
	    return this._buffer.readUInt32BE(this._position - 4);
	};

	Tars.BinBuffer.prototype.readInt64 = function(bString) {
	    var H4 = this._buffer.readUInt32BE(this._position);
	    var L4 = this._buffer.readUInt32BE(this._position + 4);
	    this._position += 8;
	    //字符串格式读出，支持int64精度
	    if (bString === true || bString === 1) {
	        if (H4 < BIT31) {
	            return new Big(H4).times(BIT32).plus(L4).toString();
	        } else {
	            H4 = BIT32 - 1 - H4;
	            return '-' + (new Big(H4)).times(BIT32).plus(BIT32 - L4).toString();
	        }
	    }
	    //Number读出，支持到 2^53 - 1 的精度
	    if (H4 < BIT31) {
	        return H4 * BIT32 + L4;
	    } else {
	        return -((BIT32 - L4) + BIT32 * (BIT32 - 1 - H4));
	    }
	};

	Tars.BinBuffer.prototype.readFloat = function() {
	    this._position += 4;
	    return this._buffer.readFloatBE(this._position - 4);
	};

	Tars.BinBuffer.prototype.readDouble = function() {
	    this._position += 8;
	    return this._buffer.readDoubleBE(this._position - 8);
	};

	Tars.BinBuffer.prototype.readString = function (byteLength, bRaw) {

	    var temp = createNodeBuffer(byteLength);
	    var ret;
	    if (bRaw === true || bRaw === 1) {
	        this._buffer.copy(temp, 0, this._position, this._position + byteLength);
	        this._position += byteLength;
	        return temp;
	    }

	    this._buffer.copy(temp, 0, this._position, this._position + byteLength);
	    this._position += byteLength;
	    if(temp.length == 1)
	    {
	        if(temp[0] & 0x80)
	        {
	            ret = temp.toString("binary", 0, temp.length);
	        } else {
	            ret = temp.toString("utf8", 0, temp.length);
	        }
	    } else {
	        ret = temp.toString("utf8", 0, temp.length);
	    }

	    return ret;
	};

	Tars.BinBuffer.prototype.readBinBuffer = function (byteLength, bReuse) {
	    if (bReuse === true) {
	        var temp = new Tars.BinBuffer();
	        temp._buffer    = this._buffer.slice(this._position, this._position + byteLength);
	        temp._length    = byteLength;
	        temp._capacity  = byteLength;
	        temp._position  = 0;

	        return temp;
	    }

	    var temp = new Tars.BinBuffer();
	    temp.writeNodeBuffer(this._buffer, this._position, byteLength);
	    this._position += byteLength;
	    return temp;
	};

	Tars.BinBuffer.prototype.toNodeBuffer = function () {
	    var temp = createNodeBuffer(this._length);
	    this._buffer.copy(temp, 0, 0, this._length);
	    return temp;
	};

	Tars.BinBuffer.prototype.toNodeBufferUnSafe = function () {
	    return this._buffer.slice(0, this._length);
	};

	Tars.BinBuffer.prototype.toObject = function () {
	    return this.toNodeBuffer();
	};

	Tars.BinBuffer.prototype.readFromObject = Tars.BinBuffer.prototype.writeNodeBuffer;

	Tars.BinBuffer.prototype.print = function() {
	    var str  = "";
	    for (var i = 0; i < this._length; i++) {
	        str += (this._buffer[i] > 15?"":"0") + this._buffer[i].toString(16) + (((i+1)%16 == 0)?"\n":" ");
	    }

	    console.log(str.toUpperCase());
	};

	/**
	 * tars输出编解码包裹类
	 */
	Tars.TarsOutputStream = function () {
	    this._binBuffer = new Tars.BinBuffer;
	};

	Tars.TarsOutputStream.prototype._writeTo = function (tag, type) {
	    if (tag < 15) {
	        this._binBuffer.writeUInt8((tag << 4 & 0xF0) | type);
	    } else {
	        this._binBuffer.writeUInt16((0xF0 | type) << 8 | tag);
	    }
	};

	Tars.TarsOutputStream.prototype.setHeaderLength = function (value) {
	    var position = this._binBuffer._position === 0?4:this._binBuffer._position;
	    var length   = this._binBuffer._position === 0?4:this._binBuffer._length;

	    this._binBuffer._position = 0;
	    this._binBuffer.writeInt32(value);
	    this._binBuffer._position = position;
	    this._binBuffer._length   = length;
	};

	Tars.TarsOutputStream.prototype.writeBoolean = function (tag, value) {
	    this.writeInt8(tag, value == true ? 1 : 0);
	};

	Tars.TarsOutputStream.prototype.writeInt8 = function (tag, value) {
	    value = +value;
	    if (value == 0) {
	        this._writeTo(tag, Tars.DataHelp.EN_ZERO);
	    } else {
	        this._writeTo(tag, Tars.DataHelp.EN_INT8);
	        this._binBuffer.writeInt8(value);
	    }
	};

	Tars.TarsOutputStream.prototype.writeInt16 = function (tag, value) {
	    value = +value;
	    if (value >= -128 && value <= 127) {
	        this.writeInt8(tag, value);
	    } else {
	        this._writeTo(tag, Tars.DataHelp.EN_INT16);
	        this._binBuffer.writeInt16(value);
	    }
	};

	Tars.TarsOutputStream.prototype.writeInt32 = function (tag, value) {
	    value = +value;
	    if (value >= -32768 && value <= 32767) {
	        this.writeInt16(tag, value);
	    } else {
	        this._writeTo(tag, Tars.DataHelp.EN_INT32);
	        this._binBuffer.writeInt32(value);
	    }
	};

	Tars.TarsOutputStream.prototype.writeInt64 = function (tag, value, bString) {
	    var val = +value;
	    if (val >= -2147483648 && val <= 2147483647) {
	        this.writeInt32(tag, val);
	        return;
	    }
	    this._writeTo(tag, Tars.DataHelp.EN_INT64);
	    this._binBuffer.writeInt64(value, bString);
	};

	Tars.TarsOutputStream.prototype.writeUInt8 = function (tag, value) {
	    this.writeInt16(tag, value);
	};

	Tars.TarsOutputStream.prototype.writeUInt16 = function (tag, value) {
	    this.writeInt32(tag, value);
	};

	Tars.TarsOutputStream.prototype.writeUInt32 = function (tag, value) {
	    this.writeInt64(tag, value);
	};

	Tars.TarsOutputStream.prototype.writeFloat = function (tag, value) {
	    if (value == 0) {
	        this._writeTo(tag, Tars.DataHelp.EN_ZERO);
	    } else {
	        this._writeTo(tag, Tars.DataHelp.EN_FLOAT);
	        this._binBuffer.writeFloat(value);
	    }
	};

	Tars.TarsOutputStream.prototype.writeDouble = function (tag, value) {
	    if (value == 0) {
	        this._writeTo(tag, Tars.DataHelp.EN_ZERO);
	    } else {
	        this._writeTo(tag, Tars.DataHelp.EN_DOUBLE);
	        this._binBuffer.writeDouble(value);
	    }
	};

	Tars.TarsOutputStream.prototype.writeStruct = function (tag, value) {
	    if (value._writeTo == undefined) {
	        throw Error("not defined writeTo Function");
	    }

	    this._writeTo(tag, Tars.DataHelp.EN_STRUCTBEGIN);
	    value._writeTo(this);
	    this._writeTo(0, Tars.DataHelp.EN_STRUCTEND);
	};

	Tars.TarsOutputStream.prototype.writeString = function (tag, value, bRaw) {
	    if (bRaw != undefined && bRaw == true) {
	        var byteLength = value.length;
	        if (byteLength > 255) {
	            this._writeTo(tag, Tars.DataHelp.EN_STRING4);
	            this._binBuffer.writeUInt32(byteLength);
	        } else {
	            this._writeTo(tag, Tars.DataHelp.EN_STRING1);
	            this._binBuffer.writeUInt8(byteLength);
	        }

	        this._binBuffer.writeString(value, byteLength, bRaw);
	        return ;
	    }

	    var byteLength = Buffer$1.byteLength(value, "utf8");
	    if (byteLength > 255) {
	        this._writeTo(tag, Tars.DataHelp.EN_STRING4);
	        this._binBuffer.writeUInt32(byteLength);
	    } else {
	        this._writeTo(tag, Tars.DataHelp.EN_STRING1);
	        this._binBuffer.writeUInt8(byteLength);
	    }

	    this._binBuffer.writeString(value, byteLength);
	};

	Tars.TarsOutputStream.prototype.writeBytes = function (tag, value) {
	    this._writeTo(tag, Tars.DataHelp.EN_SIMPLELIST);
	    this._writeTo(0, Tars.DataHelp.EN_INT8);
	    this.writeInt32(0, value.length);
	    this._binBuffer.writeBinBuffer(value);
	};
	var writeListDeprecateWarnning = util.deprecate(function(){},"bRaw in writeList is deprecated, use List(TarsStream.String, bRaw) instead");
	Tars.TarsOutputStream.prototype.writeList = function (tag, value, bRaw) {
	    this._writeTo(tag, Tars.DataHelp.EN_LIST);
	    this.writeInt32(0, value.length);
	    //3.0.21版本之前通过writeList(xxx, true)来表示字符串转buffer，long转string表示
	    //3.0.21版本之后通过构造 List<T, bValue>来表示是否转换，这里以后要废弃掉
	    if(bRaw === true ){
	        writeListDeprecateWarnning();
	    }
	    var bValue = value._bValue || bRaw;

	    for (var i = 0, len = value.value.length; i < len; i++) {
	        value._proto._write(this, 0, value.value[i], bValue);
	    }
	};

	Tars.TarsOutputStream.prototype.writeMap  = function (tag, value) {
	    this._writeTo(tag, Tars.DataHelp.EN_MAP);
	    this.writeInt32(0, value.size());

	    var self = this;
	    var bKey = value._bKey, bValue = value._bValue;
	    if(value._kproto == Tars.String){
	        bKey = false;
	    }
	    value.forEach(function (key, val){
	        value._kproto._write(self, 0, key, bKey);
	        value._vproto._write(self, 1, val, bValue);
	    }, bKey);
	};

	Tars.TarsOutputStream.prototype.getBinBuffer = function() {
	    return this._binBuffer;
	};

	/**
	 * TARS-TARS输入编解码包裹类
	 */
	Tars.TarsInputStream = function (binBuffer) {
	    this._binBuffer = binBuffer;
	    this._binBuffer._position = 0;
	};

	Tars.TarsInputStream.prototype.setBinBuffer = function (binBuffer) {
	    this._binBuffer = binBuffer;
	    this._binBuffer._position = 0;
	};

	Tars.TarsInputStream.prototype._readFrom = function () {
	    var temp = this._binBuffer.readUInt8();
	    var tag  = (temp & 0xF0) >> 4;
	    var type = (temp & 0x0F);

	    if (tag >= 15) tag = this._binBuffer.readUInt8();
	    return {tag:tag, type:type};
	};

	Tars.TarsInputStream.prototype._peekFrom = function () {
	    var pos  = this._binBuffer._position;
	    var head = this._readFrom();
	    this._binBuffer.position = pos;

	    return {tag:head.tag, type:head.type, size:(head.tag >= 15) ? 2 : 1};
	};

	Tars.TarsInputStream.prototype._skipField = function (type) {
	    switch (type) {
	        case Tars.DataHelp.EN_INT8        : this._binBuffer._position += 1; break;
	        case Tars.DataHelp.EN_INT16       : this._binBuffer._position += 2; break;
	        case Tars.DataHelp.EN_INT32       : this._binBuffer._position += 4; break;
	        case Tars.DataHelp.EN_INT64       : this._binBuffer._position += 8; break;
	        case Tars.DataHelp.EN_FLOAT       : this._binBuffer._position += 4; break;
	        case Tars.DataHelp.EN_DOUBLE      : this._binBuffer._position += 8; break;
	        case Tars.DataHelp.EN_STRING1     : {
	            var Length = this._binBuffer.readUInt8();
	            this._binBuffer._position += Length;
	            break;
	        }
	        case Tars.DataHelp.EN_STRING4     : {
	            var Length = this._binBuffer.readUInt32();
	            this._binBuffer._position += Length;
	            break;
	        }
	        case Tars.DataHelp.EN_STRUCTBEGIN : this._skipToStructEnd(); break;
	        case Tars.DataHelp.EN_STRUCTEND   :
	        case Tars.DataHelp.EN_ZERO        : break;
	        case Tars.DataHelp.EN_MAP         : {
	            var size = this.readInt32(0, true);

	            for (var i = 0; i < size * 2; ++i) {
	                var head = this._readFrom();
	                this._skipField(head.type);
	            }

	            break;
	        }
	        case Tars.DataHelp.EN_SIMPLELIST : {
	            var head = this._readFrom();
	            if (head.type != Tars.DataHelp.EN_INT8) {
	                throw new Tars.DecodeInvalidValue("skipField with invalid type, type value: " + type + "," + head.type);
	            }

	            var Length = this.readInt32(0, true);
	            this._binBuffer._position += Length;
	            break;
	        }
	        case Tars.DataHelp.EN_LIST : {
	            var size = this.readInt32(0, true);
	            for (var i = 0; i < size; ++i) {
	                var head = this._readFrom();
	                this._skipField(head.type);
	            }
	            break;
	        }
	        default : throw new Tars.DecodeInvalidValue("skipField with invalid type, type value: " + type);
	    }
	};

	Tars.TarsInputStream.prototype._skipToStructEnd = function () {
	    for ( ; ; ) {
	        var head = this._readFrom();
	        this._skipField(head.type);

	        if (head.type == Tars.DataHelp.EN_STRUCTEND) {
	            return;
	        }
	    }
	};
	Tars.TarsInputStream.prototype._skipToTag = function (tag, require) {
	    while (this._binBuffer._position < this._binBuffer._length) {
	        var head = this._peekFrom();
	        //记录tag的位置，struct随读随解码
	        if(this._tagPosMap){
	            this._tagPosMap[head.tag] = this._binBuffer._position;
	            this._tagPosMap._current = this._binBuffer._position;
	        }
	        if (tag <= head.tag || head.type == Tars.DataHelp.EN_STRUCTEND) {
	            if ((head.type === Tars.DataHelp.EN_STRUCTEND)?false:(tag === head.tag)) {
	                return true;
	            }
	            break;
	        }
	        this._binBuffer._position += head.size;
	        this._skipField(head.type);
	    }

	    if (require) throw new Tars.DecodeRequireNotExist("require field not exist, tag:" + tag);
	    return false;
	};

	Tars.TarsInputStream.prototype.readBoolean = function (tag, require, DEFAULT_VALUE) {
	    return this.readInt8(tag, require, DEFAULT_VALUE) == 1 ? true : false;
	};

	Tars.TarsInputStream.prototype.readInt8 = function (tag, require, DEFAULT_VALUE) {
	    if (this._skipToTag(tag, require) == false) { return DEFAULT_VALUE; }

	    var head = this._readFrom();
	    switch (head.type) {
	        case Tars.DataHelp.EN_ZERO: return 0;
	        case Tars.DataHelp.EN_INT8: return this._binBuffer.readInt8();
	    }

	    throw new Tars.DecodeMismatch("read int8 type mismatch, tag:" + tag + ", get type:" + head.type);
	};

	Tars.TarsInputStream.prototype.readInt16 = function (tag, require, DEFAULT_VALUE) {
	    if (this._skipToTag(tag, require) == false) { return DEFAULT_VALUE; }

	    var head = this._readFrom();
	    switch (head.type) {
	        case Tars.DataHelp.EN_ZERO   : return 0;
	        case Tars.DataHelp.EN_INT8   : return this._binBuffer.readInt8();
	        case Tars.DataHelp.EN_INT16  : return this._binBuffer.readInt16();
	    }

	    throw new Tars.DecodeMismatch("read int8 type mismatch, tag:" + tag + ", get type:" + head.type);
	};

	Tars.TarsInputStream.prototype.readInt32 = function (tag, requrire, DEFAULT_VALUE) {
	    if (this._skipToTag(tag, requrire) == false) { return DEFAULT_VALUE; }

	    var head = this._readFrom();
	    switch (head.type) {
	        case Tars.DataHelp.EN_ZERO   : return 0;
	        case Tars.DataHelp.EN_INT8   : return this._binBuffer.readInt8();
	        case Tars.DataHelp.EN_INT16  : return this._binBuffer.readInt16();
	        case Tars.DataHelp.EN_INT32  : return this._binBuffer.readInt32();
	    }

	    throw new Tars.DecodeMismatch("read int8 type mismatch, tag:" + tag + ", get type:" + head.type);
	};

	Tars.TarsInputStream.prototype.readInt64 = function (tag, require, DEFAULT_VALUE, bString) {
	    if (this._skipToTag(tag, require) == false) { return DEFAULT_VALUE; }

	    var head = this._readFrom();
	    switch (head.type) {
	        case Tars.DataHelp.EN_ZERO   : return 0;
	        case Tars.DataHelp.EN_INT8   : return this._binBuffer.readInt8();
	        case Tars.DataHelp.EN_INT16  : return this._binBuffer.readInt16();
	        case Tars.DataHelp.EN_INT32  : return this._binBuffer.readInt32();
	        case Tars.DataHelp.EN_INT64  : return this._binBuffer.readInt64(bString);
	    }

	    throw new Tars.DecodeMismatch("read int64 type mismatch, tag:" + tag + ", get type:" + head.type);
	};

	Tars.TarsInputStream.prototype.readFloat = function (tag, require, DEFAULT_VALUE) {
	    if (this._skipToTag(tag, require) == false) { return DEFAULT_VALUE; }

	    var head = this._readFrom();
	    switch (head.type) {
	        case Tars.DataHelp.EN_ZERO   : return 0;
	        case Tars.DataHelp.EN_FLOAT  : return this._binBuffer.readFloat();
	    }

	    throw new Tars.DecodeMismatch("read float type mismatch, tag:" + tag + ", get type:" + head.type);
	};

	Tars.TarsInputStream.prototype.readDouble = function (tag, require, DEFAULT_VALUE) {
	    if (this._skipToTag(tag, require) == false) { return DEFAULT_VALUE; }

	    var head = this._readFrom();
	    switch (head.type) {
	        case Tars.DataHelp.EN_ZERO    : return 0;
	        case Tars.DataHelp.EN_DOUBLE  : return this._binBuffer.readDouble();
	    }

	    throw new Tars.DecodeMismatch("read double type mismatch, tag:" + tag + ", get type:" + head.type);
	};

	Tars.TarsInputStream.prototype.readUInt8 = function (tag, require, DEFAULT_VALUE)  {
	    return this.readInt16(tag, require, DEFAULT_VALUE);
	};

	Tars.TarsInputStream.prototype.readUInt16 = function (tag, require, DEFAULT_VALUE) {
	    return this.readInt32(tag, require, DEFAULT_VALUE);
	};

	Tars.TarsInputStream.prototype.readUInt32 = function (tag, require, DEFAULT_VALUE) {
	    return this.readInt64(tag, require, DEFAULT_VALUE);
	};

	Tars.TarsInputStream.prototype.readString = function (tag, require, DEFAULT_VALUE, bRaw) {
	    if (this._skipToTag(tag, require) == false) { return DEFAULT_VALUE; }

	    var head = this._readFrom();
	    if (head.type == Tars.DataHelp.EN_STRING1) {
	        return this._binBuffer.readString(this._binBuffer.readUInt8(), bRaw);
	    }

	    if (head.type == Tars.DataHelp.EN_STRING4) {
	        return this._binBuffer.readString(this._binBuffer.readUInt32(), bRaw);
	    }

	    throw new Tars.DecodeMismatch("read 'string' type mismatch, tag: " + tag + ", get type: " + head.type + ".");
	};

	Tars.TarsInputStream.prototype.readStruct = function (tag, require, TYPE_T) {
	    if (this._skipToTag(tag, require) == false) { return  new TYPE_T(); }

	    var head = this._readFrom();
	    if (head.type != Tars.DataHelp.EN_STRUCTBEGIN) {
	        throw new Tars.DecodeMismatch("read struct type mismatch, tag: " + tag + ", get type:" + head.type);
	    }

	    var temp = TYPE_T._readFrom(this);
	    this._skipToStructEnd();
	    return temp;
	};

	Tars.TarsInputStream.prototype.readBytes  = function(tag, require, TYPE_T, bRaw) {
	    if (this._skipToTag(tag, require) == false) { return new TYPE_T(); }

	    var head = this._readFrom();
	    if (head.type == Tars.DataHelp.EN_SIMPLELIST) {
	        var temp = this._readFrom();
	        if (temp.type != Tars.DataHelp.EN_INT8) {
	            throw new Tars.DecodeMismatch("type mismatch, tag:" + tag + ",type:" + head.type + "," + temp.type);
	        }

	        var size = this.readInt32(0, true);
	        if (size < 0) {
	            throw new Tars.DecodeInvalidValue("invalid size, tag:" + tag + ",type:" + head.type + "," + temp.type);
	        }

	        var bytes = this._binBuffer.readBinBuffer(size, bRaw);
	        bytes.position = 0;
	        return bytes;
	    }

	    throw new Tars.DecodeMismatch("type mismatch, tag:" + tag + ",type:" + head.type);
	};

	var readListDeprecateWarnning = util.deprecate(function(){},"bRaw in readList is deprecated, use List(TarsStream.String, bRaw) instead");
	Tars.TarsInputStream.prototype.readList = function(tag, require, TYPE_T, bRaw) {
	    if (this._skipToTag(tag, require) == false) { return TYPE_T; }

	    var head = this._readFrom();
	    if (head.type != Tars.DataHelp.EN_LIST) {
	        throw new Tars.DecodeMismatch("read 'vector' type mismatch, tag: " + tag + ", get type: " + head.type);
	    }

	    var size = this.readInt32(0, true);
	    if (size < 0) {
	        throw new Tars.DecodeInvalidValue("invalid size, tag: " + tag + ", type: " + head.type + ", size: " + size);
	    }
	    //3.0.21版本之前通过readList(xxx, true)来表示字符串转buffer，long转string表示
	    //3.0.21版本之后通过构造 List<T, bValue>来表示是否转换，这里以后要废弃掉
	    if(bRaw === true){
	        readListDeprecateWarnning();
	    }

	    var bValue = TYPE_T._bValue || bRaw;

	    var TEMP = new Tars.List(TYPE_T._proto);
	    for (var i = 0; i < size; ++i) {
	        TEMP.value.push(TEMP._proto._read(this, 0, TEMP._proto, bValue));
	    }
	    return TEMP;
	};

	Tars.TarsInputStream.prototype.readMap = function(tag, require, TYPE_T) {
	    if (this._skipToTag(tag, require) == false) { return TYPE_T; }

	    var head = this._readFrom();
	    if (head.type != Tars.DataHelp.EN_MAP) {
	        throw new Tars.DecodeMismatch("read 'map' type mismatch, tag: " + tag + ", get type: " + head.type);
	    }

	    var size = this.readInt32(0, true);
	    if (size < 0) {
	        throw new Tars.DecodeMismatch("invalid map, tag: " + tag + ", size: " + size);
	    }

	    var bKey = TYPE_T._bKey, bValue = TYPE_T._bValue;
	    if(TYPE_T._kproto == Tars.String){
	        bKey = false;
	    }
	    var TEMP = new Tars.Map(TYPE_T._kproto, TYPE_T._vproto, bKey, bValue);

	    for (var i = 0; i < size; i++) {
	        var key = TEMP._kproto._read(this, 0, TEMP._kproto, bKey);
	        var val = TEMP._vproto._read(this, 1, TEMP._vproto, bValue);
	        TEMP.insert(key, val);
	    }

	    return TEMP;
	};

	/**
	 * TUP包裹类
	 */
	Tars.UniAttribute = function () {
	    this._data = new Tars.Map(Tars.String, Tars.BinBuffer);
	    this._mmap = new Tars.Map(Tars.String, Tars.Map(Tars.String, Tars.BinBuffer));
	    this._buff = new Tars.TarsOutputStream();
	    this._temp = new Tars.TarsInputStream(new Tars.BinBuffer());
	    this._iver = Tars.UniAttribute.TUP_SIMPLE;

	    this.__defineGetter__("tupVersion", function() { return this._iver; });
	    this.__defineSetter__("tupVersion", function(value) { this._iver = value; });
	};

	Tars.UniAttribute.TUP_COMPLEX = 2;
	Tars.UniAttribute.TUP_SIMPLE  = 3;
	Tars.UniAttribute.JSON_VERSION  = 5;

	Tars.UniAttribute.prototype._getkey = function(name, DEFAULT_VALUE, TYPE_T, FUNC, bValue) {
	    if (this._iver == Tars.UniAttribute.TUP_SIMPLE) {
	        var binBuffer = this._data.get(name);
	        if (binBuffer == undefined && DEFAULT_VALUE == undefined) {
	            throw new Tars.TupNotFoundKey("UniAttribute not found key:" + name);
	        }
	        if (binBuffer == undefined && DEFAULT_VALUE != undefined) {
	            return DEFAULT_VALUE;
	        }
	    } else {
	        var item = this._mmap.get(name);
	        if (item == undefined && DEFAULT_VALUE == undefined) {
	            throw new Tars.TupNotFoundKey("UniAttribute not found key:" + name);
	        }
	        if (item == undefined && DEFAULT_VALUE != undefined) {
	            return DEFAULT_VALUE;
	        }

	        var binBuffer = item.get(TYPE_T._classname);
	        if (binBuffer == undefined) {
	            throw new Tars.TupNotFoundKey("UniAttribute type match fail,key:" + name + ",type:" + TYPE_T._classname);
	        }
	    }

	    this._temp.setBinBuffer(binBuffer);
	    return FUNC.call(this._temp, 0, true, TYPE_T, bValue)
	};

	Tars.UniAttribute.prototype._setkey = function(name, value, TYPE_T, FUNC, bValue) {
	    this._buff._binBuffer.reset();
	    FUNC.call(this._buff, 0, value, bValue);

	    if (this._iver == Tars.UniAttribute.TUP_SIMPLE) {
	        this._data.set(name, new Tars.BinBuffer(this._buff.getBinBuffer().toNodeBuffer()));
	    } else {
	        var temp = new Tars.Map(Tars.String, Tars.BinBuffer);
	        temp.set(TYPE_T._classname, new Tars.BinBuffer(this._buff.getBinBuffer().toNodeBuffer()));
	        this._mmap.set(name, temp);
	    }
	};

	Tars.UniAttribute.prototype.decode = function(binBuffer) {
	    var is = new Tars.TarsInputStream(binBuffer);
	    if (this._iver == Tars.UniAttribute.TUP_SIMPLE) {
	        this._data.clear();
	        this._data = is.readMap(0, true, Tars.Map(Tars.String, Tars.BinBuffer));
	    } else {
	        this._mmap.clear();
	        this._mmap = is.readMap(0, true, Tars.Map(Tars.String, Tars.Map(Tars.String, Tars.BinBuffer)));
	    }
	};

	Tars.UniAttribute.prototype.encode = function() {
	    var os = new Tars.TarsOutputStream();
	    os.writeMap(0, this._iver == Tars.UniAttribute.TUP_SIMPLE?this._data:this._mmap);
	    return os.getBinBuffer();
	};

	Tars.UniAttribute.prototype.writeBoolean = function(name, value) { this._setkey(name, value, Tars.Boolean, this._buff.writeBoolean); };
	Tars.UniAttribute.prototype.writeInt8    = function(name, value) { this._setkey(name, value, Tars.Int8, this._buff.writeInt8);       };
	Tars.UniAttribute.prototype.writeUInt8   = function(name, value) { this._setkey(name, value, Tars.UInt8, this._buff.writeUInt8);     };
	Tars.UniAttribute.prototype.writeInt16   = function(name, value) { this._setkey(name, value, Tars.Int16, this._buff.writeInt16);     };
	Tars.UniAttribute.prototype.writeUInt16  = function(name, value) { this._setkey(name, value, Tars.UInt16, this._buff.writeUInt16);   };
	Tars.UniAttribute.prototype.writeInt32   = function(name, value) { this._setkey(name, value, Tars.Int32, this._buff.writeInt32);     };
	Tars.UniAttribute.prototype.writeUInt32  = function(name, value) { this._setkey(name, value, Tars.UInt32, this._buff.writeUInt32);   };
	Tars.UniAttribute.prototype.writeInt64   = function(name, value, bValue) { this._setkey(name, value, Tars.Int64, this._buff.writeInt64, bValue);     };
	Tars.UniAttribute.prototype.writeFloat   = function(name, value) { this._setkey(name, value, Tars.Float, this._buff.writeFloat);     };
	Tars.UniAttribute.prototype.writeDouble  = function(name, value) { this._setkey(name, value, Tars.Double, this._buff.writeDouble);   };
	Tars.UniAttribute.prototype.writeBytes   = function(name, value) { this._setkey(name, value, Tars.BinBuffer, this._buff.writeBytes); };
	Tars.UniAttribute.prototype.writeString  = function(name, value, bValue) { this._setkey(name, value, Tars.String, this._buff.writeString, bValue);   };
	Tars.UniAttribute.prototype.writeStruct  = function(name, value) { this._setkey(name, value, value, this._buff.writeStruct);        };
	Tars.UniAttribute.prototype.writeList    = function(name, value) { this._setkey(name, value, value, this._buff.writeList);          };
	Tars.UniAttribute.prototype.writeMap     = function(name, value) { this._setkey(name, value, value, this._buff.writeMap);           };

	Tars.UniAttribute.prototype.readBoolean  = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.Boolean,    this._temp.readBoolean);     };
	Tars.UniAttribute.prototype.readInt8     = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.Int8,       this._temp.readInt8);        };
	Tars.UniAttribute.prototype.readUInt8    = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.UInt8,      this._temp.readUInt8);       };
	Tars.UniAttribute.prototype.readInt16    = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.Int16,      this._temp.readInt16);       };
	Tars.UniAttribute.prototype.readUInt16   = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.UInt16,     this._temp.readUInt16);      };
	Tars.UniAttribute.prototype.readInt32    = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.Int32,      this._temp.readInt32);       };
	Tars.UniAttribute.prototype.readUInt32   = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.UInt32,     this._temp.readUInt32);      };
	Tars.UniAttribute.prototype.readInt64    = function(name, DEFAULT_VALUE, bValue) { return this._getkey(name, DEFAULT_VALUE, Tars.Int64,      this._temp.readInt64, bValue);       };
	Tars.UniAttribute.prototype.readFloat    = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.Float,      this._temp.readFloat);       };
	Tars.UniAttribute.prototype.readDouble   = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.Double,     this._temp.readDouble);      };
	Tars.UniAttribute.prototype.readBytes    = function(name, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, Tars.BinBuffer,  this._temp.readBytes);       };
	Tars.UniAttribute.prototype.readString   = function(name, DEFAULT_VALUE, bValue) { return this._getkey(name, DEFAULT_VALUE, Tars.String,     this._temp.readString, bValue);      };
	Tars.UniAttribute.prototype.readStruct   = function(name, TYPE_T, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, TYPE_T, this._temp.readStruct);      };
	Tars.UniAttribute.prototype.readList     = function(name, TYPE_T, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, TYPE_T, this._temp.readList);        };
	Tars.UniAttribute.prototype.readMap      = function(name, TYPE_T, DEFAULT_VALUE) { return this._getkey(name, DEFAULT_VALUE, TYPE_T, this._temp.readMap);         };

	Tars.Tup = function () {
	    this._iVersion     = 0;
	    this._cPacketType  = 0;
	    this._iMessageType = 0;
	    this._iRequestId   = 0;
	    this._sServantName = '';
	    this._sFuncName    = '';
	    this._binBuffer    = new Tars.BinBuffer();
	    this._iTimeout     = 0;
	    this._context      = new Tars.Map(Tars.String, Tars.String);
	    this._status       = new Tars.Map(Tars.String, Tars.String);
	    this._attribute    = new Tars.UniAttribute();

	    this.__defineGetter__("servantName", function() { return this._sServantName; });
	    this.__defineSetter__("servantName", function(value) { this._sServantName = value; });
	    this.__defineGetter__("funcName",    function() { return this._sFuncName; });
	    this.__defineSetter__("funcName",    function(value) { this._sFuncName = value; });
	    this.__defineGetter__("requestId",   function() { return this._iRequestId; });
	    this.__defineSetter__("requestId",   function(value) { this._iRequestId = value; });
	    this.__defineGetter__("tupVersion",  function() { return this._attribute.tupVersion; });
	    this.__defineSetter__("tupVersion",  function(value) { this._attribute.tupVersion = value; });
	};

	Tars.Tup.TUP_COMPLEX = Tars.UniAttribute.TUP_COMPLEX; //复杂TUP协议
	Tars.Tup.TUP_SIMPLE  = Tars.UniAttribute.TUP_SIMPLE;  //精简TUP协议
	Tars.Tup.JSON_VERSION  = Tars.UniAttribute.JSON_VERSION;  //tars-json协议

	Tars.Tup.prototype._writeTo = function() {
	    var os = new Tars.TarsOutputStream();
	    os._binBuffer.writeInt32(0);
	    os.writeInt16  (1,  this._attribute.tupVersion);
	    os.writeInt8   (2,  this._cPacketType);
	    os.writeInt32  (3,  this._iMessageType);
	    os.writeInt32  (4,  this._iRequestId);
	    os.writeString (5,  this._sServantName);
	    os.writeString (6,  this._sFuncName);
	    os.writeBytes  (7,  this._binBuffer);
	    os.writeInt32  (8,  this._iTimeout);
	    os.writeMap    (9,  this._context);
	    os.writeMap    (10, this._status);

	    var pos = os._binBuffer._position;
	    var len = os._binBuffer._length;

	    os._binBuffer._position = 0;
	    os._binBuffer.writeInt32(os._binBuffer._length);
	    os._binBuffer._length   = len;
	    os._binBuffer._position = pos;

	    return os.getBinBuffer();
	};

	Tars.Tup.prototype._readFrom = function(is) {
	    this._iVersion     = is.readInt16(1, true);
	    this._cPacketType  = is.readInt8(2, true);
	    this._iMessageType = is.readInt32(3, true);
	    this._iRequestId   = is.readInt32(4, true);
	    this._sServantName = is.readString(5, true);
	    this._sFuncName    = is.readString(6, true);
	    this._binBuffer    = is.readBytes(7, true);
	    this._iTimeout     = is.readInt32(8, true);
	    this._context      = is.readMap(9, false, Tars.Map(Tars.String, Tars.String));
	    this._status       = is.readMap(10, false, Tars.Map(Tars.String, Tars.String));

	    this._attribute.tupVersion = this._iVersion;
	};

	Tars.Tup.prototype.encode = function() {
	    this._binBuffer = this._attribute.encode();
	    return this._writeTo();
	};

	Tars.Tup.prototype.decode = function (binBuffer) {
	    var is  = new Tars.TarsInputStream(binBuffer);
	    var len = is._binBuffer.readInt32();
	    if (len < 4) {
	        throw Error("packet length too short");
	    }
	    this._readFrom(is);
	    this._attribute.decode(this._binBuffer);
	};

	Tars.Tup.prototype.getTarsResultCode = function () {
	    var code = this._status.get("STATUS_RESULT_CODE");
	    return code === undefined?0:parseInt(code);
	};

	Tars.Tup.prototype.getTarsResultDesc = function () {
	    var desc = this._status.get("STATUS_RESULT_DESC");
	    return desc === undefined?"":desc;
	};

	Tars.Tup.prototype.writeBoolean = function(name, value) { this._attribute.writeBoolean(name, value); };
	Tars.Tup.prototype.writeInt8    = function(name, value) { this._attribute.writeInt8(name, value);    };
	Tars.Tup.prototype.writeUInt8   = function(name, value) { this._attribute.writeUInt8(name, value);   };
	Tars.Tup.prototype.writeInt16   = function(name, value) { this._attribute.writeInt16(name, value);   };
	Tars.Tup.prototype.writeUInt16  = function(name, value) { this._attribute.writeUInt16(name, value);  };
	Tars.Tup.prototype.writeInt32   = function(name, value) { this._attribute.writeInt32(name, value);   };
	Tars.Tup.prototype.writeUInt32  = function(name, value) { this._attribute.writeUInt32(name, value);  };
	Tars.Tup.prototype.writeInt64   = function(name, value, bValue) { this._attribute.writeInt64(name, value, bValue);   };
	Tars.Tup.prototype.writeFloat   = function(name, value) { this._attribute.writeFloat(name, value);   };
	Tars.Tup.prototype.writeDouble  = function(name, value) { this._attribute.writeDouble(name, value);  };
	Tars.Tup.prototype.writeBytes   = function(name, value) { this._attribute.writeBytes(name, value);   };
	Tars.Tup.prototype.writeString  = function(name, value, bValue) { this._attribute.writeString(name, value, bValue);  };
	Tars.Tup.prototype.writeStruct  = function(name, value) { this._attribute.writeStruct(name, value);  };
	Tars.Tup.prototype.writeList    = function(name, value) { this._attribute.writeList(name, value);    };
	Tars.Tup.prototype.writeMap     = function(name, value) { this._attribute.writeMap(name, value);     };

	Tars.Tup.prototype.readBoolean  = function(name, DEFAULT_VALUE)         { return this._attribute.readBoolean(name, DEFAULT_VALUE);        };
	Tars.Tup.prototype.readInt8     = function(name, DEFAULT_VALUE)         { return this._attribute.readInt8(name, DEFAULT_VALUE);           };
	Tars.Tup.prototype.readUInt8    = function(name, DEFAULT_VALUE)         { return this._attribute.readUInt8(name, DEFAULT_VALUE);          };
	Tars.Tup.prototype.readInt16    = function(name, DEFAULT_VALUE)         { return this._attribute.readInt16(name, DEFAULT_VALUE);          };
	Tars.Tup.prototype.readUInt16   = function(name, DEFAULT_VALUE)         { return this._attribute.readUInt16(name, DEFAULT_VALUE);         };
	Tars.Tup.prototype.readInt32    = function(name, DEFAULT_VALUE)         { return this._attribute.readInt32(name, DEFAULT_VALUE);          };
	Tars.Tup.prototype.readUInt32   = function(name, DEFAULT_VALUE)         { return this._attribute.readUInt32(name, DEFAULT_VALUE);         };
	Tars.Tup.prototype.readInt64    = function(name, DEFAULT_VALUE, bValue)         { return this._attribute.readInt64(name, DEFAULT_VALUE, bValue);          };
	Tars.Tup.prototype.readFloat    = function(name, DEFAULT_VALUE)         { return this._attribute.readFloat(name, DEFAULT_VALUE);          };
	Tars.Tup.prototype.readDouble   = function(name, DEFAULT_VALUE)         { return this._attribute.readDouble(name, DEFAULT_VALUE);         };
	Tars.Tup.prototype.readBytes    = function(name, DEFAULT_VALUE)         { return this._attribute.readBytes(name, DEFAULT_VALUE);          };
	Tars.Tup.prototype.readString   = function(name, DEFAULT_VALUE, bValue)         { return this._attribute.readString(name, DEFAULT_VALUE, bValue);         };
	Tars.Tup.prototype.readStruct   = function(name, TYPE_T, DEFAULT_VALUE) { return this._attribute.readStruct(name, TYPE_T, DEFAULT_VALUE); };
	Tars.Tup.prototype.readList     = function(name, TYPE_T, DEFAULT_VALUE) { return this._attribute.readList(name, TYPE_T, DEFAULT_VALUE);   };
	Tars.Tup.prototype.readMap      = function(name, TYPE_T, DEFAULT_VALUE) { return this._attribute.readMap(name, TYPE_T, DEFAULT_VALUE);    };

	var tarsExports = tars.exports;

	// **********************************************************************
	// Parsed By TarsParser(2.4.5), Generated By tars2node(20200707)
	// TarsParser Maintained By <TARS> and tars2node Maintained By <superzheng>
	// Generated from "bg_cs_msg.tars" by Structure Mode
	// **********************************************************************
	/* tslint:disable */
	/* eslint-disable */
	/// <reference types="node" />
	// import assert = require("assert");
	class sim_assert {
	    static fail(info) {
	        console.error("sim_sim_assert", info);
	    }
	}
	const _hasOwnProperty = Object.prototype.hasOwnProperty;
	var bg_proto_cs;
	(function (bg_proto_cs) {
	    (function (BGCSErrorCode) {
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_SUCCESS"] = 0] = "BGCS_RET_SUCCESS";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_SVR_ERROR"] = 1] = "BGCS_RET_SVR_ERROR";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_PARAM_INVALID"] = 2] = "BGCS_RET_PARAM_INVALID";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_AUTH_FAILED"] = 3] = "BGCS_RET_AUTH_FAILED";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_GAMESVR_OFFLINE"] = 4] = "BGCS_RET_GAMESVR_OFFLINE";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_DUPLICATED_LOGIN"] = 5] = "BGCS_RET_DUPLICATED_LOGIN";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_ENQUEUE_ERROR"] = 6] = "BGCS_RET_ENQUEUE_ERROR";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_ENQUEUE"] = 7] = "BGCS_RET_ENQUEUE";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_INVALID_SESSION"] = 8] = "BGCS_RET_INVALID_SESSION";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_KICK_TIMEOUT"] = 9] = "BGCS_RET_KICK_TIMEOUT";
	        BGCSErrorCode[BGCSErrorCode["BGCS_RET_AUTH_CODE_NOT_ZERO"] = 10] = "BGCS_RET_AUTH_CODE_NOT_ZERO";
	    })(bg_proto_cs.BGCSErrorCode || (bg_proto_cs.BGCSErrorCode = {}));
	    (function (BGCSErrorCode) {
	        BGCSErrorCode._classname = "bg_proto_cs.BGCSErrorCode";
	        function _write(os, tag, val) { return os.writeInt32(tag, val); }
	        BGCSErrorCode._write = _write;
	        function _read(is, tag, def) { return is.readInt32(tag, true, def); }
	        BGCSErrorCode._read = _read;
	    })(bg_proto_cs.BGCSErrorCode || (bg_proto_cs.BGCSErrorCode = {}));
	    (function (AuthType) {
	        AuthType[AuthType["AuthTypeNone"] = 0] = "AuthTypeNone";
	        AuthType[AuthType["AuthTypeGuest"] = 1] = "AuthTypeGuest";
	        AuthType[AuthType["AuthTypeTouTiao"] = 2] = "AuthTypeTouTiao";
	        AuthType[AuthType["AuthTypeDouYin"] = 3] = "AuthTypeDouYin";
	        AuthType[AuthType["AuthTypeGoogle"] = 4] = "AuthTypeGoogle";
	        AuthType[AuthType["AuthTypeQQ"] = 5] = "AuthTypeQQ";
	        AuthType[AuthType["AuthTypeWeChat"] = 6] = "AuthTypeWeChat";
	        AuthType[AuthType["AuthTypeMiniApp"] = 7] = "AuthTypeMiniApp";
	        AuthType[AuthType["AuthTypeGSDK"] = 8] = "AuthTypeGSDK";
	        AuthType[AuthType["AuthTypePassportSDK"] = 9] = "AuthTypePassportSDK";
	        AuthType[AuthType["AuthTypeCustomized"] = 10] = "AuthTypeCustomized";
	    })(bg_proto_cs.AuthType || (bg_proto_cs.AuthType = {}));
	    (function (AuthType) {
	        AuthType._classname = "bg_proto_cs.AuthType";
	        function _write(os, tag, val) { return os.writeInt32(tag, val); }
	        AuthType._write = _write;
	        function _read(is, tag, def) { return is.readInt32(tag, true, def); }
	        AuthType._read = _read;
	    })(bg_proto_cs.AuthType || (bg_proto_cs.AuthType = {}));
	    (function (CloseReason) {
	        CloseReason[CloseReason["KICK_BY_RELOGIN"] = 0] = "KICK_BY_RELOGIN";
	        CloseReason[CloseReason["KICK_BY_GAME"] = 1] = "KICK_BY_GAME";
	    })(bg_proto_cs.CloseReason || (bg_proto_cs.CloseReason = {}));
	    (function (CloseReason) {
	        CloseReason._classname = "bg_proto_cs.CloseReason";
	        function _write(os, tag, val) { return os.writeInt32(tag, val); }
	        CloseReason._write = _write;
	        function _read(is, tag, def) { return is.readInt32(tag, true, def); }
	        CloseReason._read = _read;
	    })(bg_proto_cs.CloseReason || (bg_proto_cs.CloseReason = {}));
	    class OAuthInfoNone {
	        constructor() {
	            this.openid = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.OAuthInfoNone";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new OAuthInfoNone;
	            tmp.openid = is.readString(0, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.openid);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                openid: this.openid
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "openid") && (this.openid = json.openid);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new OAuthInfoNone();
	        }
	        static create(is) {
	            return bg_proto_cs.OAuthInfoNone._readFrom(is);
	        }
	    }
	    OAuthInfoNone._classname = "bg_proto_cs.OAuthInfoNone";
	    bg_proto_cs.OAuthInfoNone = OAuthInfoNone;
	    class OAuthInfoAuthorizationCode {
	        constructor() {
	            this.openid = "";
	            this.anonymous_openid = "";
	            this.anonymous_uid = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.OAuthInfoAuthorizationCode";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new OAuthInfoAuthorizationCode;
	            tmp.openid = is.readString(0, true, "");
	            tmp.anonymous_openid = is.readString(1, true, "");
	            tmp.anonymous_uid = is.readString(2, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.openid);
	            os.writeString(1, this.anonymous_openid);
	            os.writeString(2, this.anonymous_uid);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                openid: this.openid,
	                anonymous_openid: this.anonymous_openid,
	                anonymous_uid: this.anonymous_uid
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "openid") && (this.openid = json.openid);
	            _hasOwnProperty.call(json, "anonymous_openid") && (this.anonymous_openid = json.anonymous_openid);
	            _hasOwnProperty.call(json, "anonymous_uid") && (this.anonymous_uid = json.anonymous_uid);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new OAuthInfoAuthorizationCode();
	        }
	        static create(is) {
	            return bg_proto_cs.OAuthInfoAuthorizationCode._readFrom(is);
	        }
	    }
	    OAuthInfoAuthorizationCode._classname = "bg_proto_cs.OAuthInfoAuthorizationCode";
	    bg_proto_cs.OAuthInfoAuthorizationCode = OAuthInfoAuthorizationCode;
	    class BGSessionInfo {
	        constructor() {
	            this.uid = 0;
	            this.session_id = 0;
	            this.ticket = "";
	            this.auth_type = 0;
	            this.auth_info = new tarsExports.BinBuffer;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGSessionInfo";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGSessionInfo;
	            tmp.uid = is.readInt64(0, true, 0);
	            tmp.session_id = is.readInt64(1, true, 0);
	            tmp.ticket = is.readString(2, true, "");
	            tmp.auth_type = is.readInt32(3, true, 0);
	            tmp.auth_info = is.readBytes(4, true, tarsExports.BinBuffer);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt64(0, this.uid);
	            os.writeInt64(1, this.session_id);
	            os.writeString(2, this.ticket);
	            os.writeInt32(3, this.auth_type);
	            os.writeBytes(4, this.auth_info);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                uid: this.uid,
	                session_id: this.session_id,
	                ticket: this.ticket,
	                auth_type: this.auth_type,
	                auth_info: this.auth_info.toObject()
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "uid") && (this.uid = json.uid);
	            _hasOwnProperty.call(json, "session_id") && (this.session_id = json.session_id);
	            _hasOwnProperty.call(json, "ticket") && (this.ticket = json.ticket);
	            _hasOwnProperty.call(json, "auth_type") && (this.auth_type = json.auth_type);
	            _hasOwnProperty.call(json, "auth_info") && (this.auth_info.readFromObject(json.auth_info));
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGSessionInfo();
	        }
	        static create(is) {
	            return bg_proto_cs.BGSessionInfo._readFrom(is);
	        }
	    }
	    BGSessionInfo._classname = "bg_proto_cs.BGSessionInfo";
	    bg_proto_cs.BGSessionInfo = BGSessionInfo;
	    class BGHeartbeatReq {
	        constructor() {
	            this.seq_no = 0;
	            this.timestamp = 0;
	            this.last_ttl = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGHeartbeatReq";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGHeartbeatReq;
	            tmp.seq_no = is.readInt32(0, false, 0);
	            tmp.timestamp = is.readInt64(1, false, 0);
	            tmp.last_ttl = is.readInt32(2, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt32(0, this.seq_no);
	            os.writeInt64(1, this.timestamp);
	            os.writeInt32(2, this.last_ttl);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                seq_no: this.seq_no,
	                timestamp: this.timestamp,
	                last_ttl: this.last_ttl
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "seq_no") && (this.seq_no = json.seq_no);
	            _hasOwnProperty.call(json, "timestamp") && (this.timestamp = json.timestamp);
	            _hasOwnProperty.call(json, "last_ttl") && (this.last_ttl = json.last_ttl);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGHeartbeatReq();
	        }
	        static create(is) {
	            return bg_proto_cs.BGHeartbeatReq._readFrom(is);
	        }
	    }
	    BGHeartbeatReq._classname = "bg_proto_cs.BGHeartbeatReq";
	    bg_proto_cs.BGHeartbeatReq = BGHeartbeatReq;
	    class BGHeartbeatRsp {
	        constructor() {
	            this.seq_no = 0;
	            this.timestamp = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGHeartbeatRsp";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGHeartbeatRsp;
	            tmp.seq_no = is.readInt32(0, false, 0);
	            tmp.timestamp = is.readInt64(1, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt32(0, this.seq_no);
	            os.writeInt64(1, this.timestamp);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                seq_no: this.seq_no,
	                timestamp: this.timestamp
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "seq_no") && (this.seq_no = json.seq_no);
	            _hasOwnProperty.call(json, "timestamp") && (this.timestamp = json.timestamp);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGHeartbeatRsp();
	        }
	        static create(is) {
	            return bg_proto_cs.BGHeartbeatRsp._readFrom(is);
	        }
	    }
	    BGHeartbeatRsp._classname = "bg_proto_cs.BGHeartbeatRsp";
	    bg_proto_cs.BGHeartbeatRsp = BGHeartbeatRsp;
	    class BGVersionInfo {
	        constructor() {
	            this.major_version = 0;
	            this.minor_version = 0;
	            this.build_number = 0;
	            this.ext_number = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGVersionInfo";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGVersionInfo;
	            tmp.major_version = is.readInt32(0, true, 0);
	            tmp.minor_version = is.readInt32(1, true, 0);
	            tmp.build_number = is.readInt32(2, true, 0);
	            tmp.ext_number = is.readInt32(3, true, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt32(0, this.major_version);
	            os.writeInt32(1, this.minor_version);
	            os.writeInt32(2, this.build_number);
	            os.writeInt32(3, this.ext_number);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                major_version: this.major_version,
	                minor_version: this.minor_version,
	                build_number: this.build_number,
	                ext_number: this.ext_number
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "major_version") && (this.major_version = json.major_version);
	            _hasOwnProperty.call(json, "minor_version") && (this.minor_version = json.minor_version);
	            _hasOwnProperty.call(json, "build_number") && (this.build_number = json.build_number);
	            _hasOwnProperty.call(json, "ext_number") && (this.ext_number = json.ext_number);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGVersionInfo();
	        }
	        static create(is) {
	            return bg_proto_cs.BGVersionInfo._readFrom(is);
	        }
	    }
	    BGVersionInfo._classname = "bg_proto_cs.BGVersionInfo";
	    bg_proto_cs.BGVersionInfo = BGVersionInfo;
	    class BGDeviceInfo {
	        constructor() {
	            this.device = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGDeviceInfo";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGDeviceInfo;
	            tmp.device = is.readString(0, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.device);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                device: this.device
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "device") && (this.device = json.device);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGDeviceInfo();
	        }
	        static create(is) {
	            return bg_proto_cs.BGDeviceInfo._readFrom(is);
	        }
	    }
	    BGDeviceInfo._classname = "bg_proto_cs.BGDeviceInfo";
	    bg_proto_cs.BGDeviceInfo = BGDeviceInfo;
	    class BGEnvironmentInfo {
	        constructor() {
	            this.host_info = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGEnvironmentInfo";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGEnvironmentInfo;
	            tmp.host_info = is.readString(0, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.host_info);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                host_info: this.host_info
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "host_info") && (this.host_info = json.host_info);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGEnvironmentInfo();
	        }
	        static create(is) {
	            return bg_proto_cs.BGEnvironmentInfo._readFrom(is);
	        }
	    }
	    BGEnvironmentInfo._classname = "bg_proto_cs.BGEnvironmentInfo";
	    bg_proto_cs.BGEnvironmentInfo = BGEnvironmentInfo;
	    class Openid {
	        constructor() {
	            this.openid = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.Openid";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new Openid;
	            tmp.openid = is.readString(0, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.openid);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                openid: this.openid
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "openid") && (this.openid = json.openid);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new Openid();
	        }
	        static create(is) {
	            return bg_proto_cs.Openid._readFrom(is);
	        }
	    }
	    Openid._classname = "bg_proto_cs.Openid";
	    bg_proto_cs.Openid = Openid;
	    class Guest {
	        constructor() {
	            this.imei = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.Guest";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new Guest;
	            tmp.imei = is.readString(0, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.imei);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                imei: this.imei
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "imei") && (this.imei = json.imei);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new Guest();
	        }
	        static create(is) {
	            return bg_proto_cs.Guest._readFrom(is);
	        }
	    }
	    Guest._classname = "bg_proto_cs.Guest";
	    bg_proto_cs.Guest = Guest;
	    class OAuthAuthorizationCode {
	        constructor() {
	            this.code = "";
	            this.anonymous_code = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.OAuthAuthorizationCode";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new OAuthAuthorizationCode;
	            tmp.code = is.readString(0, true, "");
	            tmp.anonymous_code = is.readString(1, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.code);
	            os.writeString(1, this.anonymous_code);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                code: this.code,
	                anonymous_code: this.anonymous_code
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "code") && (this.code = json.code);
	            _hasOwnProperty.call(json, "anonymous_code") && (this.anonymous_code = json.anonymous_code);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new OAuthAuthorizationCode();
	        }
	        static create(is) {
	            return bg_proto_cs.OAuthAuthorizationCode._readFrom(is);
	        }
	    }
	    OAuthAuthorizationCode._classname = "bg_proto_cs.OAuthAuthorizationCode";
	    bg_proto_cs.OAuthAuthorizationCode = OAuthAuthorizationCode;
	    class OAuthAccessToken {
	        constructor() {
	            this.channel = "";
	            this.openid = "";
	            this.access_token = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.OAuthAccessToken";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new OAuthAccessToken;
	            tmp.channel = is.readString(0, true, "");
	            tmp.openid = is.readString(1, true, "");
	            tmp.access_token = is.readString(2, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.channel);
	            os.writeString(1, this.openid);
	            os.writeString(2, this.access_token);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                channel: this.channel,
	                openid: this.openid,
	                access_token: this.access_token
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "channel") && (this.channel = json.channel);
	            _hasOwnProperty.call(json, "openid") && (this.openid = json.openid);
	            _hasOwnProperty.call(json, "access_token") && (this.access_token = json.access_token);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new OAuthAccessToken();
	        }
	        static create(is) {
	            return bg_proto_cs.OAuthAccessToken._readFrom(is);
	        }
	    }
	    OAuthAccessToken._classname = "bg_proto_cs.OAuthAccessToken";
	    bg_proto_cs.OAuthAccessToken = OAuthAccessToken;
	    class Jwt {
	        constructor() {
	            this.id_token = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.Jwt";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new Jwt;
	            tmp.id_token = is.readString(0, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.id_token);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                id_token: this.id_token
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "id_token") && (this.id_token = json.id_token);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new Jwt();
	        }
	        static create(is) {
	            return bg_proto_cs.Jwt._readFrom(is);
	        }
	    }
	    Jwt._classname = "bg_proto_cs.Jwt";
	    bg_proto_cs.Jwt = Jwt;
	    class OAuthPassportSDK {
	        constructor() {
	            this.cookie = "";
	            this.x_tt_token = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.OAuthPassportSDK";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new OAuthPassportSDK;
	            tmp.cookie = is.readString(0, false, "");
	            tmp.x_tt_token = is.readString(1, false, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.cookie);
	            os.writeString(1, this.x_tt_token);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                cookie: this.cookie,
	                x_tt_token: this.x_tt_token
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "cookie") && (this.cookie = json.cookie);
	            _hasOwnProperty.call(json, "x_tt_token") && (this.x_tt_token = json.x_tt_token);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new OAuthPassportSDK();
	        }
	        static create(is) {
	            return bg_proto_cs.OAuthPassportSDK._readFrom(is);
	        }
	    }
	    OAuthPassportSDK._classname = "bg_proto_cs.OAuthPassportSDK";
	    bg_proto_cs.OAuthPassportSDK = OAuthPassportSDK;
	    class OAuthCustomized {
	        constructor() {
	            this.customized_auth_data = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.OAuthCustomized";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new OAuthCustomized;
	            tmp.customized_auth_data = is.readString(0, false, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeString(0, this.customized_auth_data);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                customized_auth_data: this.customized_auth_data
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "customized_auth_data") && (this.customized_auth_data = json.customized_auth_data);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new OAuthCustomized();
	        }
	        static create(is) {
	            return bg_proto_cs.OAuthCustomized._readFrom(is);
	        }
	    }
	    OAuthCustomized._classname = "bg_proto_cs.OAuthCustomized";
	    bg_proto_cs.OAuthCustomized = OAuthCustomized;
	    class BGClientLoginReq {
	        constructor() {
	            this.auth_type = 0;
	            this.auth_info = new tarsExports.BinBuffer;
	            this.version_info = new bg_proto_cs.BGVersionInfo;
	            this.device_info = new bg_proto_cs.BGDeviceInfo;
	            this.env_info = new bg_proto_cs.BGEnvironmentInfo;
	            this.gamesvr_insid = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGClientLoginReq";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGClientLoginReq;
	            tmp.auth_type = is.readInt32(0, true, 0);
	            tmp.auth_info = is.readBytes(1, true, tarsExports.BinBuffer);
	            tmp.version_info = is.readStruct(2, true, bg_proto_cs.BGVersionInfo);
	            tmp.device_info = is.readStruct(3, true, bg_proto_cs.BGDeviceInfo);
	            tmp.env_info = is.readStruct(4, true, bg_proto_cs.BGEnvironmentInfo);
	            tmp.gamesvr_insid = is.readInt64(5, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt32(0, this.auth_type);
	            os.writeBytes(1, this.auth_info);
	            os.writeStruct(2, this.version_info);
	            os.writeStruct(3, this.device_info);
	            os.writeStruct(4, this.env_info);
	            os.writeInt64(5, this.gamesvr_insid);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                auth_type: this.auth_type,
	                auth_info: this.auth_info.toObject(),
	                version_info: this.version_info.toObject(),
	                device_info: this.device_info.toObject(),
	                env_info: this.env_info.toObject(),
	                gamesvr_insid: this.gamesvr_insid
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "auth_type") && (this.auth_type = json.auth_type);
	            _hasOwnProperty.call(json, "auth_info") && (this.auth_info.readFromObject(json.auth_info));
	            _hasOwnProperty.call(json, "version_info") && (this.version_info.readFromObject(json.version_info));
	            _hasOwnProperty.call(json, "device_info") && (this.device_info.readFromObject(json.device_info));
	            _hasOwnProperty.call(json, "env_info") && (this.env_info.readFromObject(json.env_info));
	            _hasOwnProperty.call(json, "gamesvr_insid") && (this.gamesvr_insid = json.gamesvr_insid);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGClientLoginReq();
	        }
	        static create(is) {
	            return bg_proto_cs.BGClientLoginReq._readFrom(is);
	        }
	    }
	    BGClientLoginReq._classname = "bg_proto_cs.BGClientLoginReq";
	    bg_proto_cs.BGClientLoginReq = BGClientLoginReq;
	    class BGClientLoginRsp {
	        constructor() {
	            this.session_info = new bg_proto_cs.BGSessionInfo;
	            this.logid = "";
	            this.err_msg = "";
	            this.queue_pos = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGClientLoginRsp";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGClientLoginRsp;
	            tmp.session_info = is.readStruct(0, true, bg_proto_cs.BGSessionInfo);
	            tmp.logid = is.readString(1, false, "");
	            tmp.err_msg = is.readString(2, false, "");
	            tmp.queue_pos = is.readInt32(3, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeStruct(0, this.session_info);
	            os.writeString(1, this.logid);
	            os.writeString(2, this.err_msg);
	            os.writeInt32(3, this.queue_pos);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                session_info: this.session_info.toObject(),
	                logid: this.logid,
	                err_msg: this.err_msg,
	                queue_pos: this.queue_pos
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "session_info") && (this.session_info.readFromObject(json.session_info));
	            _hasOwnProperty.call(json, "logid") && (this.logid = json.logid);
	            _hasOwnProperty.call(json, "err_msg") && (this.err_msg = json.err_msg);
	            _hasOwnProperty.call(json, "queue_pos") && (this.queue_pos = json.queue_pos);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGClientLoginRsp();
	        }
	        static create(is) {
	            return bg_proto_cs.BGClientLoginRsp._readFrom(is);
	        }
	    }
	    BGClientLoginRsp._classname = "bg_proto_cs.BGClientLoginRsp";
	    bg_proto_cs.BGClientLoginRsp = BGClientLoginRsp;
	    class BGClientLogoutReq {
	        constructor() {
	            this.uid = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGClientLogoutReq";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGClientLogoutReq;
	            tmp.uid = is.readInt64(0, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt64(0, this.uid);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                uid: this.uid
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "uid") && (this.uid = json.uid);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGClientLogoutReq();
	        }
	        static create(is) {
	            return bg_proto_cs.BGClientLogoutReq._readFrom(is);
	        }
	    }
	    BGClientLogoutReq._classname = "bg_proto_cs.BGClientLogoutReq";
	    bg_proto_cs.BGClientLogoutReq = BGClientLogoutReq;
	    class BGClientLogoutRsp {
	        constructor() {
	            this.uid = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGClientLogoutRsp";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGClientLogoutRsp;
	            tmp.uid = is.readInt64(0, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt64(0, this.uid);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                uid: this.uid
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "uid") && (this.uid = json.uid);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGClientLogoutRsp();
	        }
	        static create(is) {
	            return bg_proto_cs.BGClientLogoutRsp._readFrom(is);
	        }
	    }
	    BGClientLogoutRsp._classname = "bg_proto_cs.BGClientLogoutRsp";
	    bg_proto_cs.BGClientLogoutRsp = BGClientLogoutRsp;
	    class BGClientRelayLoginReq {
	        constructor() {
	            this.uid = 0;
	            this.session_id = 0;
	            this.ticket = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGClientRelayLoginReq";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGClientRelayLoginReq;
	            tmp.uid = is.readInt64(0, true, 0);
	            tmp.session_id = is.readInt64(1, true, 0);
	            tmp.ticket = is.readString(2, true, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt64(0, this.uid);
	            os.writeInt64(1, this.session_id);
	            os.writeString(2, this.ticket);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                uid: this.uid,
	                session_id: this.session_id,
	                ticket: this.ticket
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "uid") && (this.uid = json.uid);
	            _hasOwnProperty.call(json, "session_id") && (this.session_id = json.session_id);
	            _hasOwnProperty.call(json, "ticket") && (this.ticket = json.ticket);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGClientRelayLoginReq();
	        }
	        static create(is) {
	            return bg_proto_cs.BGClientRelayLoginReq._readFrom(is);
	        }
	    }
	    BGClientRelayLoginReq._classname = "bg_proto_cs.BGClientRelayLoginReq";
	    bg_proto_cs.BGClientRelayLoginReq = BGClientRelayLoginReq;
	    class BGClientRelayLoginRsp {
	        constructor() {
	            this.uid = 0;
	            this.logid = "";
	            this.queue_pos = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGClientRelayLoginRsp";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGClientRelayLoginRsp;
	            tmp.uid = is.readInt64(0, false, 0);
	            tmp.logid = is.readString(1, false, "");
	            tmp.queue_pos = is.readInt32(2, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt64(0, this.uid);
	            os.writeString(1, this.logid);
	            os.writeInt32(2, this.queue_pos);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                uid: this.uid,
	                logid: this.logid,
	                queue_pos: this.queue_pos
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "uid") && (this.uid = json.uid);
	            _hasOwnProperty.call(json, "logid") && (this.logid = json.logid);
	            _hasOwnProperty.call(json, "queue_pos") && (this.queue_pos = json.queue_pos);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGClientRelayLoginRsp();
	        }
	        static create(is) {
	            return bg_proto_cs.BGClientRelayLoginRsp._readFrom(is);
	        }
	    }
	    BGClientRelayLoginRsp._classname = "bg_proto_cs.BGClientRelayLoginRsp";
	    bg_proto_cs.BGClientRelayLoginRsp = BGClientRelayLoginRsp;
	    class BGQueueInfoReq {
	        constructor() {
	            this.uid = 0;
	            this.session_id = 0;
	            this.cur_pos = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGQueueInfoReq";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGQueueInfoReq;
	            tmp.uid = is.readInt64(0, false, 0);
	            tmp.session_id = is.readInt64(1, false, 0);
	            tmp.cur_pos = is.readInt32(2, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt64(0, this.uid);
	            os.writeInt64(1, this.session_id);
	            os.writeInt32(2, this.cur_pos);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                uid: this.uid,
	                session_id: this.session_id,
	                cur_pos: this.cur_pos
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "uid") && (this.uid = json.uid);
	            _hasOwnProperty.call(json, "session_id") && (this.session_id = json.session_id);
	            _hasOwnProperty.call(json, "cur_pos") && (this.cur_pos = json.cur_pos);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGQueueInfoReq();
	        }
	        static create(is) {
	            return bg_proto_cs.BGQueueInfoReq._readFrom(is);
	        }
	    }
	    BGQueueInfoReq._classname = "bg_proto_cs.BGQueueInfoReq";
	    bg_proto_cs.BGQueueInfoReq = BGQueueInfoReq;
	    class BGQueueInfoNotify {
	        constructor() {
	            this.queue_pos = 0;
	            this.wait_time = 0;
	            this.is_ready = false;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGQueueInfoNotify";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGQueueInfoNotify;
	            tmp.queue_pos = is.readInt32(0, true, 0);
	            tmp.wait_time = is.readInt64(1, true, 0);
	            tmp.is_ready = is.readBoolean(2, false, false);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt32(0, this.queue_pos);
	            os.writeInt64(1, this.wait_time);
	            os.writeBoolean(2, this.is_ready);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                queue_pos: this.queue_pos,
	                wait_time: this.wait_time,
	                is_ready: this.is_ready
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "queue_pos") && (this.queue_pos = json.queue_pos);
	            _hasOwnProperty.call(json, "wait_time") && (this.wait_time = json.wait_time);
	            _hasOwnProperty.call(json, "is_ready") && (this.is_ready = json.is_ready);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGQueueInfoNotify();
	        }
	        static create(is) {
	            return bg_proto_cs.BGQueueInfoNotify._readFrom(is);
	        }
	    }
	    BGQueueInfoNotify._classname = "bg_proto_cs.BGQueueInfoNotify";
	    bg_proto_cs.BGQueueInfoNotify = BGQueueInfoNotify;
	    class BGSessionInfoNotify {
	        constructor() {
	            this.session_info = new bg_proto_cs.BGSessionInfo;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGSessionInfoNotify";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGSessionInfoNotify;
	            tmp.session_info = is.readStruct(0, true, bg_proto_cs.BGSessionInfo);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeStruct(0, this.session_info);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                session_info: this.session_info.toObject()
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "session_info") && (this.session_info.readFromObject(json.session_info));
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGSessionInfoNotify();
	        }
	        static create(is) {
	            return bg_proto_cs.BGSessionInfoNotify._readFrom(is);
	        }
	    }
	    BGSessionInfoNotify._classname = "bg_proto_cs.BGSessionInfoNotify";
	    bg_proto_cs.BGSessionInfoNotify = BGSessionInfoNotify;
	    class BGClientCloseNotify {
	        constructor() {
	            this.reason = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGClientCloseNotify";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGClientCloseNotify;
	            tmp.reason = is.readInt32(0, false, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeInt32(0, this.reason);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                reason: this.reason
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "reason") && (this.reason = json.reason);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGClientCloseNotify();
	        }
	        static create(is) {
	            return bg_proto_cs.BGClientCloseNotify._readFrom(is);
	        }
	    }
	    BGClientCloseNotify._classname = "bg_proto_cs.BGClientCloseNotify";
	    bg_proto_cs.BGClientCloseNotify = BGClientCloseNotify;
	    class BGReportStatistics {
	        constructor() {
	            this.is_relay_login = true;
	            this.connect_latency = 0;
	            this.negotiate_latency = 0;
	            this.auth_latency = 0;
	            this.total_latency = 0;
	            this.log_id = "";
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGReportStatistics";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGReportStatistics;
	            tmp.is_relay_login = is.readBoolean(0, false, true);
	            tmp.connect_latency = is.readInt64(1, false, 0);
	            tmp.negotiate_latency = is.readInt64(2, false, 0);
	            tmp.auth_latency = is.readInt64(3, false, 0);
	            tmp.total_latency = is.readInt64(4, false, 0);
	            tmp.log_id = is.readString(5, false, "");
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeBoolean(0, this.is_relay_login);
	            os.writeInt64(1, this.connect_latency);
	            os.writeInt64(2, this.negotiate_latency);
	            os.writeInt64(3, this.auth_latency);
	            os.writeInt64(4, this.total_latency);
	            os.writeString(5, this.log_id);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                is_relay_login: this.is_relay_login,
	                connect_latency: this.connect_latency,
	                negotiate_latency: this.negotiate_latency,
	                auth_latency: this.auth_latency,
	                total_latency: this.total_latency,
	                log_id: this.log_id
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "is_relay_login") && (this.is_relay_login = json.is_relay_login);
	            _hasOwnProperty.call(json, "connect_latency") && (this.connect_latency = json.connect_latency);
	            _hasOwnProperty.call(json, "negotiate_latency") && (this.negotiate_latency = json.negotiate_latency);
	            _hasOwnProperty.call(json, "auth_latency") && (this.auth_latency = json.auth_latency);
	            _hasOwnProperty.call(json, "total_latency") && (this.total_latency = json.total_latency);
	            _hasOwnProperty.call(json, "log_id") && (this.log_id = json.log_id);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGReportStatistics();
	        }
	        static create(is) {
	            return bg_proto_cs.BGReportStatistics._readFrom(is);
	        }
	    }
	    BGReportStatistics._classname = "bg_proto_cs.BGReportStatistics";
	    bg_proto_cs.BGReportStatistics = BGReportStatistics;
	    class BGCSMsg {
	        constructor() {
	            this.cs_msg = new tarsExports.BinBuffer;
	            this.result = 0;
	            this._proto_struct_name_ = "";
	            this._classname = "bg_proto_cs.BGCSMsg";
	        }
	        static _write(os, tag, val) { os.writeStruct(tag, val); }
	        static _read(is, tag, def) { return is.readStruct(tag, true, def); }
	        static _readFrom(is) {
	            const tmp = new BGCSMsg;
	            tmp.cs_msg = is.readBytes(0, true, tarsExports.BinBuffer);
	            tmp.result = is.readInt32(1, true, 0);
	            return tmp;
	        }
	        _writeTo(os) {
	            os.writeBytes(0, this.cs_msg);
	            os.writeInt32(1, this.result);
	        }
	        _equal() {
	            sim_assert.fail("this structure not define key operation");
	        }
	        _genKey() {
	            if (!this._proto_struct_name_) {
	                this._proto_struct_name_ = "STRUCT" + Math.random();
	            }
	            return this._proto_struct_name_;
	        }
	        toObject() {
	            return {
	                cs_msg: this.cs_msg.toObject(),
	                result: this.result
	            };
	        }
	        readFromObject(json) {
	            _hasOwnProperty.call(json, "cs_msg") && (this.cs_msg.readFromObject(json.cs_msg));
	            _hasOwnProperty.call(json, "result") && (this.result = json.result);
	            return this;
	        }
	        toBinBuffer() {
	            const os = new tarsExports.TarsOutputStream();
	            this._writeTo(os);
	            return os.getBinBuffer();
	        }
	        static new() {
	            return new BGCSMsg();
	        }
	        static create(is) {
	            return bg_proto_cs.BGCSMsg._readFrom(is);
	        }
	    }
	    BGCSMsg._classname = "bg_proto_cs.BGCSMsg";
	    bg_proto_cs.BGCSMsg = BGCSMsg;
	})(bg_proto_cs || (bg_proto_cs = {}));

	/*
	 *  The MurmurHash3 algorithm was created by Austin Appleby.  This JavaScript port was authored
	 *  by whitequark (based on Java port by Yonik Seeley) and is placed into the public domain.
	 *  The author hereby disclaims copyright to this source code.
	 *
	 *  This produces exactly the same hash values as the final C++ version of MurmurHash3 and
	 *  is thus suitable for producing the same hash values across platforms.
	 *
	 *  There are two versions of this hash implementation. First interprets the string as a
	 *  sequence of bytes, ignoring most significant byte of each codepoint. The second one
	 *  interprets the string as a UTF-16 codepoint sequence, and appends each 16-bit codepoint
	 *  to the hash independently. The latter mode was not written to be compatible with
	 *  any other implementation, but it should offer better performance for JavaScript-only
	 *  applications.
	 *
	 *  See http://github.com/whitequark/murmurhash3-js for future updates to this file.
	 */
	// js to typescript by chenyu 2021.10.19
	function mul32(m, n) {
	    var nlo = n & 0xffff;
	    var nhi = n - nlo;
	    return ((nhi * m | 0) + (nlo * m | 0)) | 0;
	}
	function hashBytes(data, len, seed) {
	    var c1 = 0xcc9e2d51, c2 = 0x1b873593;
	    var h1 = seed;
	    var roundedEnd = len & -4;
	    for (var i = 0; i < roundedEnd; i += 4) {
	        var k1 = (data.charCodeAt(i) & 0xff) |
	            ((data.charCodeAt(i + 1) & 0xff) << 8) |
	            ((data.charCodeAt(i + 2) & 0xff) << 16) |
	            ((data.charCodeAt(i + 3) & 0xff) << 24);
	        k1 = mul32(k1, c1);
	        k1 = ((k1 & 0x1ffff) << 15) | (k1 >>> 17); // ROTL32(k1,15);
	        k1 = mul32(k1, c2);
	        h1 ^= k1;
	        h1 = ((h1 & 0x7ffff) << 13) | (h1 >>> 19); // ROTL32(h1,13);
	        h1 = (h1 * 5 + 0xe6546b64) | 0;
	    }
	    k1 = 0;
	    switch (len % 4) {
	        case 3:
	            k1 = (data.charCodeAt(roundedEnd + 2) & 0xff) << 16;
	        // fallthrough
	        case 2:
	            k1 |= (data.charCodeAt(roundedEnd + 1) & 0xff) << 8;
	        // fallthrough
	        case 1:
	            k1 |= (data.charCodeAt(roundedEnd) & 0xff);
	            k1 = mul32(k1, c1);
	            k1 = ((k1 & 0x1ffff) << 15) | (k1 >>> 17); // ROTL32(k1,15);
	            k1 = mul32(k1, c2);
	            h1 ^= k1;
	    }
	    // finalization
	    h1 ^= len;
	    // fmix(h1);
	    h1 ^= h1 >>> 16;
	    h1 = mul32(h1, 0x85ebca6b);
	    h1 ^= h1 >>> 13;
	    h1 = mul32(h1, 0xc2b2ae35);
	    h1 ^= h1 >>> 16;
	    return h1;
	}

	// import * as Long from "long"
	let is_little_endian = null;
	function IsLittleEndian() {
	    if (null != is_little_endian) {
	        return is_little_endian;
	    }
	    is_little_endian = ((new Uint32Array((new Uint8Array([1, 2, 3, 4])).buffer))[0] === 0x04030201);
	    return is_little_endian;
	}
	//转换主机与网络字节序
	function HNSwitch32(val) {
	    if (IsLittleEndian()) {
	        return ((val & 0xFF000000) >>> 24) |
	            ((val & 0x00FF0000) >>> 8) |
	            ((val & 0x0000FF00) << 8) |
	            ((val & 0x000000FF) << 24);
	    }
	    return val;
	}
	function WriteToBuff32(val, buffer, buffer_offset, buffer_len) {
	    let view = new DataView(buffer, buffer_offset, buffer_len - buffer_offset);
	    view.setUint32(0, val);
	    return { error: 0, consumed_len: 4 };
	}
	function WriteToBuff64(val, buffer, buffer_offset, buffer_len) {
	    let view = new DataView(buffer, buffer_offset, buffer_len - buffer_offset);
	    view.setUint32(0, val.high);
	    view.setUint32(4, val.low);
	    return { error: 0, consumed_len: 8 };
	}
	function WriteToBuff16(val, buffer, buffer_offset, buffer_len) {
	    let view = new DataView(buffer, buffer_offset, buffer_len - buffer_offset);
	    view.setUint16(0, val);
	    return { error: 0, consumed_len: 2 };
	}
	function ReadFromBuff32(buffer, buffer_offset, buffer_len) {
	    let view = new DataView(buffer, buffer_offset, buffer_len);
	    return { val: view.getUint32(0), consumed_len: 4 };
	}
	function ReadFromBuff64(buffer, buffer_offset, buffer_len) {
	    let view = new DataView(buffer, buffer_offset, buffer_len);
	    return { val: long.fromValue({ low: view.getUint32(0), high: view.getUint32(4), unsigned: true }), consumed_len: 8 };
	}
	function ReadFromBuff16(buffer, buffer_offset, buffer_len) {
	    let view = new DataView(buffer, buffer_offset, buffer_len);
	    return { val: view.getUint16(0), consumed_len: 2 };
	}
	exports.EBGLogLevel = void 0;
	(function (EBGLogLevel) {
	    EBGLogLevel[EBGLogLevel["Debug"] = 1] = "Debug";
	    EBGLogLevel[EBGLogLevel["Info"] = 2] = "Info";
	    EBGLogLevel[EBGLogLevel["Warning"] = 3] = "Warning";
	    EBGLogLevel[EBGLogLevel["Error"] = 4] = "Error";
	})(exports.EBGLogLevel || (exports.EBGLogLevel = {}));
	let logFunc = function (logLevel, message, ...optionalParams) {
	    if (logLevel < exports.EBGLogLevel.Info) {
	        return;
	    }
	    switch (logLevel) {
	        case exports.EBGLogLevel.Debug:
	            console.debug(message, ...optionalParams);
	            break;
	        case exports.EBGLogLevel.Info:
	            console.info(message, ...optionalParams);
	            break;
	        case exports.EBGLogLevel.Warning:
	            console.warn(message, ...optionalParams);
	            break;
	        case exports.EBGLogLevel.Error:
	            console.error(message, ...optionalParams);
	            break;
	        default:
	            console.error(message, ...optionalParams);
	    }
	};
	function SetLogFunc(infunc) {
	    logFunc = infunc;
	}
	function BGLog(logLevel, message, ...optionalParams) {
	    logFunc(logLevel, "[stark]" + message, ...optionalParams);
	}

	// import { Buffer } from 'buffer';
	// globalThis.Buffer = Buffer
	globalThis.Buffer = Buffer$1;
	//消息缓存, 对nodejs Buffer的封装
	class BGMsgBuffer {
	    constructor(size) {
	        this.inner_buffer_read_st = 0;
	        this.inner_buffer_write_st = 0;
	        this.inner_buffer_end = size;
	        this.inner_buffer = Buffer.alloc(this.inner_buffer_end);
	    }
	    ;
	    Append(buffer) {
	        if (this.inner_buffer_write_st + buffer.length >= this.inner_buffer_end) {
	            //尝试移动接收缓存，将未读取消息移至缓存头部
	            let available = this.inner_buffer_write_st - this.inner_buffer_read_st;
	            if (available > 0) {
	                this.inner_buffer.copy(this.inner_buffer, 0, this.inner_buffer_read_st, this.inner_buffer_write_st);
	            }
	            this.inner_buffer_read_st = 0;
	            this.inner_buffer_write_st = available;
	            if (this.inner_buffer_write_st + buffer.length >= this.inner_buffer_end) {
	                console.error("Parse recved msg error: recv buff overflow");
	                return false;
	            }
	        }
	        buffer.copy(this.inner_buffer, this.inner_buffer_write_st, 0, buffer.length);
	        this.inner_buffer_write_st += buffer.length;
	        return true;
	    }
	    GetContent() {
	        let available = this.inner_buffer_write_st - this.inner_buffer_read_st;
	        return { content_buffer: this.inner_buffer.buffer /*nodejs的Buffer类型其成员字段.buffer为ArrayBuffer*/, read_pos: this.inner_buffer_read_st, available: available };
	    }
	    Consume(size) {
	        this.inner_buffer_read_st += size;
	    }
	} //class BGMsgBuffer {

	// Some numerical data is initialized as -1 even when it doesn't need initialization to help the JIT infer types
	// aliases for shorter compressed code (most minifers don't do this)
	var ab = ArrayBuffer, u8 = Uint8Array, u16 = Uint16Array, i16 = Int16Array, i32 = Int32Array;
	var slc = function (v, s, e) {
	    if (u8.prototype.slice)
	        return u8.prototype.slice.call(v, s, e);
	    if (s == null || s < 0)
	        s = 0;
	    if (e == null || e > v.length)
	        e = v.length;
	    var n = new u8(e - s);
	    n.set(v.subarray(s, e));
	    return n;
	};
	var fill = function (v, n, s, e) {
	    if (u8.prototype.fill)
	        return u8.prototype.fill.call(v, n, s, e);
	    if (s == null || s < 0)
	        s = 0;
	    if (e == null || e > v.length)
	        e = v.length;
	    for (; s < e; ++s)
	        v[s] = n;
	    return v;
	};
	var cpw = function (v, t, s, e) {
	    if (u8.prototype.copyWithin)
	        return u8.prototype.copyWithin.call(v, t, s, e);
	    if (s == null || s < 0)
	        s = 0;
	    if (e == null || e > v.length)
	        e = v.length;
	    while (s < e) {
	        v[t++] = v[s++];
	    }
	};
	// error codes
	var ec = [
	    'invalid zstd data',
	    'window size too large (>2046MB)',
	    'invalid block type',
	    'FSE accuracy too high',
	    'match distance too far back',
	    'unexpected EOF'
	];
	var err = function (ind, msg, nt) {
	    var e = new Error(msg || ec[ind]);
	    e.code = ind;
	    if (Error.captureStackTrace)
	        Error.captureStackTrace(e, err);
	    if (!nt)
	        throw e;
	    return e;
	};
	var rb = function (d, b, n) {
	    var i = 0, o = 0;
	    for (; i < n; ++i)
	        o |= d[b++] << (i << 3);
	    return o;
	};
	var b4 = function (d, b) { return (d[b] | (d[b + 1] << 8) | (d[b + 2] << 16) | (d[b + 3] << 24)) >>> 0; };
	// read Zstandard frame header
	var rzfh = function (dat, w) {
	    var n3 = dat[0] | (dat[1] << 8) | (dat[2] << 16);
	    if (n3 == 0x2FB528 && dat[3] == 253) {
	        // Zstandard
	        var flg = dat[4];
	        //    single segment       checksum             dict flag     frame content flag
	        var ss = (flg >> 5) & 1, cc = (flg >> 2) & 1, df = flg & 3, fcf = flg >> 6;
	        if (flg & 8)
	            err(0);
	        // byte
	        var bt = 6 - ss;
	        // dict bytes
	        var db = df == 3 ? 4 : df;
	        // dictionary id
	        var di = rb(dat, bt, db);
	        bt += db;
	        // frame size bytes
	        var fsb = fcf ? (1 << fcf) : ss;
	        // frame source size
	        var fss = rb(dat, bt, fsb) + ((fcf == 1) && 256);
	        // window size
	        var ws = fss;
	        if (!ss) {
	            // window descriptor
	            var wb = 1 << (10 + (dat[5] >> 3));
	            ws = wb + (wb >> 3) * (dat[5] & 7);
	        }
	        if (ws > 2145386496)
	            err(1);
	        var buf = new u8((w == 1 ? (fss || ws) : w ? 0 : ws) + 12);
	        buf[0] = 1, buf[4] = 4, buf[8] = 8;
	        return {
	            b: bt + fsb,
	            y: 0,
	            l: 0,
	            d: di,
	            w: (w && w != 1) ? w : buf.subarray(12),
	            e: ws,
	            o: new i32(buf.buffer, 0, 3),
	            u: fss,
	            c: cc,
	            m: Math.min(131072, ws)
	        };
	    }
	    else if (((n3 >> 4) | (dat[3] << 20)) == 0x184D2A5) {
	        // skippable
	        return b4(dat, 4) + 8;
	    }
	    err(0);
	};
	// most significant bit for nonzero
	var msb = function (val) {
	    var bits = 0;
	    for (; (1 << bits) <= val; ++bits)
	        ;
	    return bits - 1;
	};
	// read finite state entropy
	var rfse = function (dat, bt, mal) {
	    // table pos
	    var tpos = (bt << 3) + 4;
	    // accuracy log
	    var al = (dat[bt] & 15) + 5;
	    if (al > mal)
	        err(3);
	    // size
	    var sz = 1 << al;
	    // probabilities symbols  repeat   index   high threshold
	    var probs = sz, sym = -1, re = -1, i = -1, ht = sz;
	    // optimization: single allocation is much faster
	    var buf = new ab(512 + (sz << 2));
	    var freq = new i16(buf, 0, 256);
	    // same view as freq
	    var dstate = new u16(buf, 0, 256);
	    var nstate = new u16(buf, 512, sz);
	    var bb1 = 512 + (sz << 1);
	    var syms = new u8(buf, bb1, sz);
	    var nbits = new u8(buf, bb1 + sz);
	    while (sym < 255 && probs > 0) {
	        var bits = msb(probs + 1);
	        var cbt = tpos >> 3;
	        // mask
	        var msk = (1 << (bits + 1)) - 1;
	        var val = ((dat[cbt] | (dat[cbt + 1] << 8) | (dat[cbt + 2] << 16)) >> (tpos & 7)) & msk;
	        // mask (1 fewer bit)
	        var msk1fb = (1 << bits) - 1;
	        // max small value
	        var msv = msk - probs - 1;
	        // small value
	        var sval = val & msk1fb;
	        if (sval < msv)
	            tpos += bits, val = sval;
	        else {
	            tpos += bits + 1;
	            if (val > msk1fb)
	                val -= msv;
	        }
	        freq[++sym] = --val;
	        if (val == -1) {
	            probs += val;
	            syms[--ht] = sym;
	        }
	        else
	            probs -= val;
	        if (!val) {
	            do {
	                // repeat byte
	                var rbt = tpos >> 3;
	                re = ((dat[rbt] | (dat[rbt + 1] << 8)) >> (tpos & 7)) & 3;
	                tpos += 2;
	                sym += re;
	            } while (re == 3);
	        }
	    }
	    if (sym > 255 || probs)
	        err(0);
	    var sympos = 0;
	    // sym step (coprime with sz - formula from zstd source)
	    var sstep = (sz >> 1) + (sz >> 3) + 3;
	    // sym mask
	    var smask = sz - 1;
	    for (var s = 0; s <= sym; ++s) {
	        var sf = freq[s];
	        if (sf < 1) {
	            dstate[s] = -sf;
	            continue;
	        }
	        // This is split into two loops in zstd to avoid branching, but as JS is higher-level that is unnecessary
	        for (i = 0; i < sf; ++i) {
	            syms[sympos] = s;
	            do {
	                sympos = (sympos + sstep) & smask;
	            } while (sympos >= ht);
	        }
	    }
	    // After spreading symbols, should be zero again
	    if (sympos)
	        err(0);
	    for (i = 0; i < sz; ++i) {
	        // next state
	        var ns = dstate[syms[i]]++;
	        // num bits
	        var nb = nbits[i] = al - msb(ns);
	        nstate[i] = (ns << nb) - sz;
	    }
	    return [(tpos + 7) >> 3, {
	            b: al,
	            s: syms,
	            n: nbits,
	            t: nstate
	        }];
	};
	// read huffman
	var rhu = function (dat, bt) {
	    //  index  weight count
	    var i = 0, wc = -1;
	    //    buffer             header byte
	    var buf = new u8(292), hb = dat[bt];
	    // huffman weights
	    var hw = buf.subarray(0, 256);
	    // rank count
	    var rc = buf.subarray(256, 268);
	    // rank index
	    var ri = new u16(buf.buffer, 268);
	    // NOTE: at this point bt is 1 less than expected
	    if (hb < 128) {
	        // end byte, fse decode table
	        var _a = rfse(dat, bt + 1, 6), ebt = _a[0], fdt = _a[1];
	        bt += hb;
	        var epos = ebt << 3;
	        // last byte
	        var lb = dat[bt];
	        if (!lb)
	            err(0);
	        //  state1   state2   state1 bits   state2 bits
	        var st1 = 0, st2 = 0, btr1 = fdt.b, btr2 = btr1;
	        // fse pos
	        // pre-increment to account for original deficit of 1
	        var fpos = (++bt << 3) - 8 + msb(lb);
	        for (;;) {
	            fpos -= btr1;
	            if (fpos < epos)
	                break;
	            var cbt = fpos >> 3;
	            st1 += ((dat[cbt] | (dat[cbt + 1] << 8)) >> (fpos & 7)) & ((1 << btr1) - 1);
	            hw[++wc] = fdt.s[st1];
	            fpos -= btr2;
	            if (fpos < epos)
	                break;
	            cbt = fpos >> 3;
	            st2 += ((dat[cbt] | (dat[cbt + 1] << 8)) >> (fpos & 7)) & ((1 << btr2) - 1);
	            hw[++wc] = fdt.s[st2];
	            btr1 = fdt.n[st1];
	            st1 = fdt.t[st1];
	            btr2 = fdt.n[st2];
	            st2 = fdt.t[st2];
	        }
	        if (++wc > 255)
	            err(0);
	    }
	    else {
	        wc = hb - 127;
	        for (; i < wc; i += 2) {
	            var byte = dat[++bt];
	            hw[i] = byte >> 4;
	            hw[i + 1] = byte & 15;
	        }
	        ++bt;
	    }
	    // weight exponential sum
	    var wes = 0;
	    for (i = 0; i < wc; ++i) {
	        var wt = hw[i];
	        // bits must be at most 11, same as weight
	        if (wt > 11)
	            err(0);
	        wes += wt && (1 << (wt - 1));
	    }
	    // max bits
	    var mb = msb(wes) + 1;
	    // table size
	    var ts = 1 << mb;
	    // remaining sum
	    var rem = ts - wes;
	    // must be power of 2
	    if (rem & (rem - 1))
	        err(0);
	    hw[wc++] = msb(rem) + 1;
	    for (i = 0; i < wc; ++i) {
	        var wt = hw[i];
	        ++rc[hw[i] = wt && (mb + 1 - wt)];
	    }
	    // huf buf
	    var hbuf = new u8(ts << 1);
	    //    symbols                      num bits
	    var syms = hbuf.subarray(0, ts), nb = hbuf.subarray(ts);
	    ri[mb] = 0;
	    for (i = mb; i > 0; --i) {
	        var pv = ri[i];
	        fill(nb, i, pv, ri[i - 1] = pv + rc[i] * (1 << (mb - i)));
	    }
	    if (ri[0] != ts)
	        err(0);
	    for (i = 0; i < wc; ++i) {
	        var bits = hw[i];
	        if (bits) {
	            var code = ri[bits];
	            fill(syms, i, code, ri[bits] = code + (1 << (mb - bits)));
	        }
	    }
	    return [bt, {
	            n: nb,
	            b: mb,
	            s: syms
	        }];
	};
	// Tables generated using this:
	// https://gist.github.com/101arrowz/a979452d4355992cbf8f257cbffc9edd
	// default literal length table
	var dllt = /*#__PURE__*/ rfse(/*#__PURE__*/ new u8([
	    81, 16, 99, 140, 49, 198, 24, 99, 12, 33, 196, 24, 99, 102, 102, 134, 70, 146, 4
	]), 0, 6)[1];
	// default match length table
	var dmlt = /*#__PURE__*/ rfse(/*#__PURE__*/ new u8([
	    33, 20, 196, 24, 99, 140, 33, 132, 16, 66, 8, 33, 132, 16, 66, 8, 33, 68, 68, 68, 68, 68, 68, 68, 68, 36, 9
	]), 0, 6)[1];
	// default offset code table
	var doct = /*#__PURE__ */ rfse(/*#__PURE__*/ new u8([
	    32, 132, 16, 66, 102, 70, 68, 68, 68, 68, 36, 73, 2
	]), 0, 5)[1];
	// bits to baseline
	var b2bl = function (b, s) {
	    var len = b.length, bl = new i32(len);
	    for (var i = 0; i < len; ++i) {
	        bl[i] = s;
	        s += 1 << b[i];
	    }
	    return bl;
	};
	// literal length bits
	var llb = /*#__PURE__ */ new u8(( /*#__PURE__ */new i32([
	    0, 0, 0, 0, 16843009, 50528770, 134678020, 202050057, 269422093
	])).buffer, 0, 36);
	// literal length baseline
	var llbl = /*#__PURE__ */ b2bl(llb, 0);
	// match length bits
	var mlb = /*#__PURE__ */ new u8(( /*#__PURE__ */new i32([
	    0, 0, 0, 0, 0, 0, 0, 0, 16843009, 50528770, 117769220, 185207048, 252579084, 16
	])).buffer, 0, 53);
	// match length baseline
	var mlbl = /*#__PURE__ */ b2bl(mlb, 3);
	// decode huffman stream
	var dhu = function (dat, out, hu) {
	    var len = dat.length, ss = out.length, lb = dat[len - 1], msk = (1 << hu.b) - 1, eb = -hu.b;
	    if (!lb)
	        err(0);
	    var st = 0, btr = hu.b, pos = (len << 3) - 8 + msb(lb) - btr, i = -1;
	    for (; pos > eb && i < ss;) {
	        var cbt = pos >> 3;
	        var val = (dat[cbt] | (dat[cbt + 1] << 8) | (dat[cbt + 2] << 16)) >> (pos & 7);
	        st = ((st << btr) | val) & msk;
	        out[++i] = hu.s[st];
	        pos -= (btr = hu.n[st]);
	    }
	    if (pos != eb || i + 1 != ss)
	        err(0);
	};
	// decode huffman stream 4x
	// TODO: use workers to parallelize
	var dhu4 = function (dat, out, hu) {
	    var bt = 6;
	    var ss = out.length, sz1 = (ss + 3) >> 2, sz2 = sz1 << 1, sz3 = sz1 + sz2;
	    dhu(dat.subarray(bt, bt += dat[0] | (dat[1] << 8)), out.subarray(0, sz1), hu);
	    dhu(dat.subarray(bt, bt += dat[2] | (dat[3] << 8)), out.subarray(sz1, sz2), hu);
	    dhu(dat.subarray(bt, bt += dat[4] | (dat[5] << 8)), out.subarray(sz2, sz3), hu);
	    dhu(dat.subarray(bt), out.subarray(sz3), hu);
	};
	// read Zstandard block
	var rzb = function (dat, st, out) {
	    var _a;
	    var bt = st.b;
	    //    byte 0        block type
	    var b0 = dat[bt], btype = (b0 >> 1) & 3;
	    st.l = b0 & 1;
	    var sz = (b0 >> 3) | (dat[bt + 1] << 5) | (dat[bt + 2] << 13);
	    // end byte for block
	    var ebt = (bt += 3) + sz;
	    if (btype == 1) {
	        if (bt >= dat.length)
	            return;
	        st.b = bt + 1;
	        if (out) {
	            fill(out, dat[bt], st.y, st.y += sz);
	            return out;
	        }
	        return fill(new u8(sz), dat[bt]);
	    }
	    if (ebt > dat.length)
	        return;
	    if (btype == 0) {
	        st.b = ebt;
	        if (out) {
	            out.set(dat.subarray(bt, ebt), st.y);
	            st.y += sz;
	            return out;
	        }
	        return slc(dat, bt, ebt);
	    }
	    if (btype == 2) {
	        //    byte 3        lit btype     size format
	        var b3 = dat[bt], lbt = b3 & 3, sf = (b3 >> 2) & 3;
	        // lit src size  lit cmp sz 4 streams
	        var lss = b3 >> 4, lcs = 0, s4 = 0;
	        if (lbt < 2) {
	            if (sf & 1)
	                lss |= (dat[++bt] << 4) | ((sf & 2) && (dat[++bt] << 12));
	            else
	                lss = b3 >> 3;
	        }
	        else {
	            s4 = sf;
	            if (sf < 2)
	                lss |= ((dat[++bt] & 63) << 4), lcs = (dat[bt] >> 6) | (dat[++bt] << 2);
	            else if (sf == 2)
	                lss |= (dat[++bt] << 4) | ((dat[++bt] & 3) << 12), lcs = (dat[bt] >> 2) | (dat[++bt] << 6);
	            else
	                lss |= (dat[++bt] << 4) | ((dat[++bt] & 63) << 12), lcs = (dat[bt] >> 6) | (dat[++bt] << 2) | (dat[++bt] << 10);
	        }
	        ++bt;
	        // add literals to end - can never overlap with backreferences because unused literals always appended
	        var buf = out ? out.subarray(st.y, st.y + st.m) : new u8(st.m);
	        // starting point for literals
	        var spl = buf.length - lss;
	        if (lbt == 0)
	            buf.set(dat.subarray(bt, bt += lss), spl);
	        else if (lbt == 1)
	            fill(buf, dat[bt++], spl);
	        else {
	            // huffman table
	            var hu = st.h;
	            if (lbt == 2) {
	                var hud = rhu(dat, bt);
	                // subtract description length
	                lcs += bt - (bt = hud[0]);
	                st.h = hu = hud[1];
	            }
	            else if (!hu)
	                err(0);
	            (s4 ? dhu4 : dhu)(dat.subarray(bt, bt += lcs), buf.subarray(spl), hu);
	        }
	        // num sequences
	        var ns = dat[bt++];
	        if (ns) {
	            if (ns == 255)
	                ns = (dat[bt++] | (dat[bt++] << 8)) + 0x7F00;
	            else if (ns > 127)
	                ns = ((ns - 128) << 8) | dat[bt++];
	            // symbol compression modes
	            var scm = dat[bt++];
	            if (scm & 3)
	                err(0);
	            var dts = [dmlt, doct, dllt];
	            for (var i = 2; i > -1; --i) {
	                var md = (scm >> ((i << 1) + 2)) & 3;
	                if (md == 1) {
	                    // rle buf
	                    var rbuf = new u8([0, 0, dat[bt++]]);
	                    dts[i] = {
	                        s: rbuf.subarray(2, 3),
	                        n: rbuf.subarray(0, 1),
	                        t: new u16(rbuf.buffer, 0, 1),
	                        b: 0
	                    };
	                }
	                else if (md == 2) {
	                    // accuracy log 8 for offsets, 9 for others
	                    _a = rfse(dat, bt, 9 - (i & 1)), bt = _a[0], dts[i] = _a[1];
	                }
	                else if (md == 3) {
	                    if (!st.t)
	                        err(0);
	                    dts[i] = st.t[i];
	                }
	            }
	            var _b = st.t = dts, mlt = _b[0], oct = _b[1], llt = _b[2];
	            var lb = dat[ebt - 1];
	            if (!lb)
	                err(0);
	            var spos = (ebt << 3) - 8 + msb(lb) - llt.b, cbt = spos >> 3, oubt = 0;
	            var lst = ((dat[cbt] | (dat[cbt + 1] << 8)) >> (spos & 7)) & ((1 << llt.b) - 1);
	            cbt = (spos -= oct.b) >> 3;
	            var ost = ((dat[cbt] | (dat[cbt + 1] << 8)) >> (spos & 7)) & ((1 << oct.b) - 1);
	            cbt = (spos -= mlt.b) >> 3;
	            var mst = ((dat[cbt] | (dat[cbt + 1] << 8)) >> (spos & 7)) & ((1 << mlt.b) - 1);
	            for (++ns; --ns;) {
	                var llc = llt.s[lst];
	                var lbtr = llt.n[lst];
	                var mlc = mlt.s[mst];
	                var mbtr = mlt.n[mst];
	                var ofc = oct.s[ost];
	                var obtr = oct.n[ost];
	                cbt = (spos -= ofc) >> 3;
	                var ofp = 1 << ofc;
	                var off = ofp + (((dat[cbt] | (dat[cbt + 1] << 8) | (dat[cbt + 2] << 16) | (dat[cbt + 3] << 24)) >>> (spos & 7)) & (ofp - 1));
	                cbt = (spos -= mlb[mlc]) >> 3;
	                var ml = mlbl[mlc] + (((dat[cbt] | (dat[cbt + 1] << 8) | (dat[cbt + 2] << 16)) >> (spos & 7)) & ((1 << mlb[mlc]) - 1));
	                cbt = (spos -= llb[llc]) >> 3;
	                var ll = llbl[llc] + (((dat[cbt] | (dat[cbt + 1] << 8) | (dat[cbt + 2] << 16)) >> (spos & 7)) & ((1 << llb[llc]) - 1));
	                cbt = (spos -= lbtr) >> 3;
	                lst = llt.t[lst] + (((dat[cbt] | (dat[cbt + 1] << 8)) >> (spos & 7)) & ((1 << lbtr) - 1));
	                cbt = (spos -= mbtr) >> 3;
	                mst = mlt.t[mst] + (((dat[cbt] | (dat[cbt + 1] << 8)) >> (spos & 7)) & ((1 << mbtr) - 1));
	                cbt = (spos -= obtr) >> 3;
	                ost = oct.t[ost] + (((dat[cbt] | (dat[cbt + 1] << 8)) >> (spos & 7)) & ((1 << obtr) - 1));
	                if (off > 3) {
	                    st.o[2] = st.o[1];
	                    st.o[1] = st.o[0];
	                    st.o[0] = off -= 3;
	                }
	                else {
	                    var idx = off - (ll != 0);
	                    if (idx) {
	                        off = idx == 3 ? st.o[0] - 1 : st.o[idx];
	                        if (idx > 1)
	                            st.o[2] = st.o[1];
	                        st.o[1] = st.o[0];
	                        st.o[0] = off;
	                    }
	                    else
	                        off = st.o[0];
	                }
	                for (var i = 0; i < ll; ++i) {
	                    buf[oubt + i] = buf[spl + i];
	                }
	                oubt += ll, spl += ll;
	                var stin = oubt - off;
	                if (stin < 0) {
	                    var len = -stin;
	                    var bs = st.e + stin;
	                    if (len > ml)
	                        len = ml;
	                    for (var i = 0; i < len; ++i) {
	                        buf[oubt + i] = st.w[bs + i];
	                    }
	                    oubt += len, ml -= len, stin = 0;
	                }
	                for (var i = 0; i < ml; ++i) {
	                    buf[oubt + i] = buf[stin + i];
	                }
	                oubt += ml;
	            }
	            if (oubt != spl) {
	                while (spl < buf.length) {
	                    buf[oubt++] = buf[spl++];
	                }
	            }
	            else
	                oubt = buf.length;
	            if (out)
	                st.y += oubt;
	            else
	                buf = slc(buf, 0, oubt);
	        }
	        else if (out) {
	            st.y += lss;
	            if (spl) {
	                for (var i = 0; i < lss; ++i) {
	                    buf[i] = buf[spl + i];
	                }
	            }
	        }
	        else if (spl)
	            buf = slc(buf, spl);
	        st.b = ebt;
	        return buf;
	    }
	    err(2);
	};
	// concat
	var cct = function (bufs, ol) {
	    if (bufs.length == 1)
	        return bufs[0];
	    var buf = new u8(ol);
	    for (var i = 0, b = 0; i < bufs.length; ++i) {
	        var chk = bufs[i];
	        buf.set(chk, b);
	        b += chk.length;
	    }
	    return buf;
	};
	/**
	 * Decompresses Zstandard data
	 * @param dat The input data
	 * @param buf The output buffer. If unspecified, the function will allocate
	 *            exactly enough memory to fit the decompressed data. If your
	 *            data has multiple frames and you know the output size, specifying
	 *            it will yield better performance.
	 * @returns The decompressed data
	 */
	function decompress(dat, buf) {
	    var bufs = [], nb = +!buf;
	    var bt = 0, ol = 0;
	    for (; dat.length;) {
	        var st = rzfh(dat, nb || buf);
	        if (typeof st == 'object') {
	            if (nb) {
	                buf = null;
	                if (st.w.length == st.u) {
	                    bufs.push(buf = st.w);
	                    ol += st.u;
	                }
	            }
	            else {
	                bufs.push(buf);
	                st.e = 0;
	            }
	            for (; !st.l;) {
	                var blk = rzb(dat, st, buf);
	                if (!blk)
	                    err(5);
	                if (buf)
	                    st.e = st.y;
	                else {
	                    bufs.push(blk);
	                    ol += blk.length;
	                    cpw(st.w, 0, blk.length);
	                    st.w.set(blk, st.w.length - blk.length);
	                }
	            }
	            bt = st.b + (st.c * 4);
	        }
	        else
	            bt = st;
	        dat = dat.subarray(bt);
	    }
	    return cct(bufs, ol);
	}

	//BG相关预定义
	// // 包信息: magic_num + flag + pkg_size
	// typedef uint32_t BGCSPkgInfo; 
	const SIZE_OF_BGCSPKGINFO = 4; //(bytes)
	const BG_CS_MAGIC_NUM = 0xA;
	const RPC_INDEX_HASH_SEED = 0xEE6B27EB;
	const MAX_MSG_BUFFER_SIZE = 128 * 1024;
	//握手magic number
	// static const uint64_t MAGIC_NUM_1 = 0xc80718466076bd5a;
	// static const uint64_t MAGIC_NUM_2 = 0x5dec21480fc7f794;
	const MAGIC_NUM_1_32 = 0x6076bd5a;
	const MAGIC_NUM_1_64 = 0xc8071846;
	const MAGIC_NUM_2_32 = 0x0fc7f794;
	const MAGIC_NUM_2_64 = 0x5dec2148;
	//网络字节序初始握手信息
	const MAGIC_NUM_1_32_NET = HNSwitch32(MAGIC_NUM_1_32);
	const MAGIC_NUM_1_64_NET = HNSwitch32(MAGIC_NUM_1_64);
	const MAGIC_NUM_2_32_NET = HNSwitch32(MAGIC_NUM_2_32);
	const MAGIC_NUM_2_64_NET = HNSwitch32(MAGIC_NUM_2_64);
	var BGCryptoType;
	(function (BGCryptoType) {
	    BGCryptoType[BGCryptoType["BG_CRYPTO_TYPE_PLAIN"] = 1] = "BG_CRYPTO_TYPE_PLAIN";
	    BGCryptoType[BGCryptoType["BG_CRYPTO_TYPE_XCHACHA20"] = 2] = "BG_CRYPTO_TYPE_XCHACHA20";
	})(BGCryptoType || (BGCryptoType = {}));
	var BGCompressionType;
	(function (BGCompressionType) {
	    BGCompressionType[BGCompressionType["BG_COMPRESSION_TYPE_PLAIN"] = 1] = "BG_COMPRESSION_TYPE_PLAIN";
	    BGCompressionType[BGCompressionType["BG_COMPRESSION_TYPE_ZSTD"] = 2] = "BG_COMPRESSION_TYPE_ZSTD";
	})(BGCompressionType || (BGCompressionType = {}));
	var BGCSMsgType;
	(function (BGCSMsgType) {
	    BGCSMsgType[BGCSMsgType["BG_CS_MSG_BIZ_PAYLOAD"] = 4096] = "BG_CS_MSG_BIZ_PAYLOAD";
	    BGCSMsgType[BGCSMsgType["BG_SC_MSG_BIZ_PAYLOAD"] = 4097] = "BG_SC_MSG_BIZ_PAYLOAD";
	    BGCSMsgType[BGCSMsgType["BG_CS_MSG_HEARTBEAT"] = 4098] = "BG_CS_MSG_HEARTBEAT";
	    BGCSMsgType[BGCSMsgType["BG_SC_MSG_HEARTBEAT"] = 4099] = "BG_SC_MSG_HEARTBEAT";
	    BGCSMsgType[BGCSMsgType["BG_CS_MSG_LOGIN_REQ"] = 4100] = "BG_CS_MSG_LOGIN_REQ";
	    BGCSMsgType[BGCSMsgType["BG_SC_MSG_LOGIN_RSP"] = 4101] = "BG_SC_MSG_LOGIN_RSP";
	    BGCSMsgType[BGCSMsgType["BG_CS_MSG_RELAY_LOGIN_REQ"] = 4102] = "BG_CS_MSG_RELAY_LOGIN_REQ";
	    BGCSMsgType[BGCSMsgType["BG_SC_MSG_RELAY_LOGIN_RSP"] = 4103] = "BG_SC_MSG_RELAY_LOGIN_RSP";
	    BGCSMsgType[BGCSMsgType["BG_CS_MSG_LOGOUT_REQ"] = 4104] = "BG_CS_MSG_LOGOUT_REQ";
	    BGCSMsgType[BGCSMsgType["BG_SC_MSG_LOGOUT_RSP"] = 4105] = "BG_SC_MSG_LOGOUT_RSP";
	    BGCSMsgType[BGCSMsgType["BG_CS_MSG_QUEUE_INFO_REQ"] = 4106] = "BG_CS_MSG_QUEUE_INFO_REQ";
	    BGCSMsgType[BGCSMsgType["BG_SC_MSG_QUEUE_INFO_NOTIFY"] = 4107] = "BG_SC_MSG_QUEUE_INFO_NOTIFY";
	    BGCSMsgType[BGCSMsgType["BG_SC_MSG_SESSION_INFO_NOTIFY"] = 4108] = "BG_SC_MSG_SESSION_INFO_NOTIFY";
	    BGCSMsgType[BGCSMsgType["BG_SC_MSG_CLOSE_NOTIFY"] = 4109] = "BG_SC_MSG_CLOSE_NOTIFY";
	    BGCSMsgType[BGCSMsgType["BG_CS_MSG_REPORT_STATISTICS"] = 4110] = "BG_CS_MSG_REPORT_STATISTICS";
	})(BGCSMsgType || (BGCSMsgType = {}));
	var BGCSMsgFlag;
	(function (BGCSMsgFlag) {
	    BGCSMsgFlag[BGCSMsgFlag["BG_CS_MSG_FLAG_DEFAULT"] = 1] = "BG_CS_MSG_FLAG_DEFAULT";
	    BGCSMsgFlag[BGCSMsgFlag["BG_CS_MSG_FLAG_NEED_REFRESH_SESSION"] = 2] = "BG_CS_MSG_FLAG_NEED_REFRESH_SESSION";
	    BGCSMsgFlag[BGCSMsgFlag["BG_CS_MSG_FLAG_HAS_REFRESHED_SESSION"] = 3] = "BG_CS_MSG_FLAG_HAS_REFRESHED_SESSION";
	})(BGCSMsgFlag || (BGCSMsgFlag = {}));
	var BGCSMsgError;
	(function (BGCSMsgError) {
	    BGCSMsgError[BGCSMsgError["BG_WRITE_BUFFER_NOT_ENOUGH"] = -1e3] = "BG_WRITE_BUFFER_NOT_ENOUGH";
	    BGCSMsgError[BGCSMsgError["BG_READ_BUFFER_NOT_ENOUGH"] = -1001] = "BG_READ_BUFFER_NOT_ENOUGH";
	    BGCSMsgError[BGCSMsgError["BG_COMPRESS_BUFFER_NOT_ENOUGH"] = -1002] = "BG_COMPRESS_BUFFER_NOT_ENOUGH";
	    BGCSMsgError[BGCSMsgError["BG_DECOMPRESS_BUFFER_NOT_ENOUGH"] = -1003] = "BG_DECOMPRESS_BUFFER_NOT_ENOUGH";
	    BGCSMsgError[BGCSMsgError["BG_PARSE_ERROR_FLAG"] = -2e3] = "BG_PARSE_ERROR_FLAG";
	})(BGCSMsgError || (BGCSMsgError = {}));
	const SIZE_OF_BGCSHEADINFO = 4 /*seq_id*/ + 2 /*msg_cmd*/ + 8 /*tag_key*/ + 8 /*tag_val*/ + 8 /*session_id*/; // + 8 /*request_id*/;
	class BGCSHeadInfo {
	    constructor() {
	        this.seq_id = 0; //32bits
	        this.msg_cmd = 0; //16bits
	        this.tag_key = long.fromValue({ low: 0, high: 0, unsigned: true }); //new Long(0, 0, true); //64bits
	        this.tag_val = long.fromValue({ low: 0, high: 0, unsigned: true }); //new Long(0, 0, true); //64bits
	        this.session_id = long.fromValue({ low: 0, high: 0, unsigned: true }); //new Long(0, 0, true); //64bits // 0 if not specified
	        // request_id: Long = Long.fromValue({ low: 0, high: 0, unsigned: true });//new Long(0, 0, true); //64bits // 0 if not specified
	    }
	}
	class BGRawGateMsgInfo {
	    constructor() {
	        this.msg_cmd = 0;
	        this.msg_buff = new ArrayBuffer(0);
	        this.msg_offset = 0;
	        this.msg_len = 0;
	    }
	}
	//固定的初始握手消息
	function GetHandshakeStartMsg() {
	    let buffer = new ArrayBuffer(16);
	    let view = new Uint32Array(buffer);
	    view[0] = MAGIC_NUM_1_64_NET;
	    view[1] = MAGIC_NUM_1_32_NET;
	    view[2] = MAGIC_NUM_2_64_NET;
	    view[3] = MAGIC_NUM_2_32_NET;
	    return buffer;
	}
	function SimpleHash32(x) {
	    /**
	     static uint32_t simple_hash32(uint32_t x) {
	       x = (x + 0x7ed55d16) + (x << 12);
	       x = (x ^ 0xc761c23c) ^ (x >> 19);
	       x = (x + 0x165667b1) + (x << 5);
	       x = (x + 0xd3a2646c) ^ (x << 9);
	       x = (x + 0xfd7046c5) + (x << 3);
	       x = (x ^ 0xb55a4f09) ^ (x >> 16);
	       return x;
	       }
	     */
	    // x = (x + 0x7ed55d16) + (x << 12);
	    // x = (x ^ 0xc761c23c) ^ (x >>> 19);
	    // x = (x + 0x165667b1) + (x << 5);
	    // x = (x + 0xd3a2646c) ^ (x << 9);
	    // x = (x + 0xfd7046c5) + (x << 3);
	    // x = (x ^ 0xb55a4f09) ^ (x >>> 16);
	    return x;
	}
	function GetProveMsgOfChallenge(chal0, chal1, chal2, chal3) {
	    let prov0 = SimpleHash32(chal0);
	    let prov1 = SimpleHash32(chal1);
	    let prov2 = SimpleHash32(chal2);
	    let prov3 = SimpleHash32(chal3);
	    let buffer = new ArrayBuffer(16);
	    let send_msg = new Uint32Array(buffer);
	    send_msg[0] = HNSwitch32(prov0);
	    send_msg[1] = HNSwitch32(prov1);
	    send_msg[2] = HNSwitch32(prov2);
	    send_msg[3] = HNSwitch32(prov3);
	    BGLog(exports.EBGLogLevel.Debug, "server challenge:", chal0.toString(16), chal1.toString(16), chal2.toString(16), chal3.toString(16));
	    BGLog(exports.EBGLogLevel.Debug, "client prov:", prov0.toString(16), prov1.toString(16), prov2.toString(16), prov3.toString(16));
	    return buffer;
	}
	// /*uint16_t*/ flag, /*uint32_t*/ msg_size, /*char **/ buffer, /*uint32_t*/ buffer_len,
	function BGWritePkgInfoToBuffer(flag, msg_size, buffer, buffer_len) {
	    // assert((flag >> 4u) == 0);
	    // assert((msg_size >> 24u) == 0);
	    // uint32_t*  pkg_info_size
	    let rst = { error: 0, written: 0 };
	    let info = (BG_CS_MAGIC_NUM << 28) | (flag << 24) | msg_size;
	    let view = new DataView(buffer, 0, buffer_len);
	    view.setUint32(0, info); //memcpy(buffer, & info, sizeof(info));
	    rst.written = SIZE_OF_BGCSPKGINFO;
	    return rst;
	}
	// const char* buffer, uint32_t buffer_len, uint16_t * flag, uint32_t * msg_size, uint32_t * pkg_info_size
	function BGReadPkgInfoFromBuffer(buffer, buffer_offset, buffer_len) {
	    let rst = { error: 0, flag: 0, msg_size: 0, consumed_len: 0 };
	    if (buffer_len < SIZE_OF_BGCSPKGINFO) {
	        rst.error = BGCSMsgError.BG_READ_BUFFER_NOT_ENOUGH;
	        return rst;
	    }
	    let msg_32 = new DataView(buffer, buffer_offset, buffer_len);
	    let bg_cs_pkg_info = msg_32.getUint32(0);
	    let magic_num = bg_cs_pkg_info >>> 28;
	    if (magic_num != BG_CS_MAGIC_NUM) {
	        rst.error = BGCSMsgError.BG_PARSE_ERROR_FLAG;
	        return rst;
	    }
	    rst.flag = (bg_cs_pkg_info >> 24) & 0xF;
	    rst.msg_size = bg_cs_pkg_info & 0x00FFFFFF;
	    rst.consumed_len = SIZE_OF_BGCSPKGINFO;
	    return rst;
	}
	// BGCSHeadInfo * head_info, char * buffer, uint32_t buffer_len, uint32_t * consumed_len
	function BGWriteHeadInfoToBuffer(head_info, buffer, buffer_offset, buffer_len) {
	    let rst = { error: 0, consumed_len: 0 };
	    let tmp_rst = WriteToBuff32(head_info.seq_id, buffer, buffer_offset + 0, buffer_len);
	    rst.consumed_len += tmp_rst.consumed_len;
	    tmp_rst = WriteToBuff16(head_info.msg_cmd, buffer, buffer_offset + rst.consumed_len, buffer_len);
	    rst.consumed_len += tmp_rst.consumed_len;
	    tmp_rst = WriteToBuff64(head_info.tag_key, buffer, buffer_offset + rst.consumed_len, buffer_len);
	    rst.consumed_len += tmp_rst.consumed_len;
	    tmp_rst = WriteToBuff64(head_info.tag_val, buffer, buffer_offset + rst.consumed_len, buffer_len);
	    rst.consumed_len += tmp_rst.consumed_len;
	    tmp_rst = WriteToBuff64(head_info.session_id, buffer, buffer_offset + rst.consumed_len, buffer_len);
	    rst.consumed_len += tmp_rst.consumed_len;
	    // tmp_rst = BGHelper.WriteToBuff64(head_info.request_id, buffer, buffer_offset + rst.consumed_len, buffer_len);
	    // rst.consumed_len += tmp_rst.consumed_len;
	    return rst;
	}
	// const char* buffer, uint32_t buffer_len, BGCSHeadInfo * head_info, uint32_t * size_read
	function BGReadHeadInfoFromBuffer(buffer, buffer_offset, buffer_len, head_info) {
	    let rst = { error: 0, consumed_len: 0 };
	    if (buffer_len < SIZE_OF_BGCSHEADINFO) {
	        rst.error = BGCSMsgError.BG_READ_BUFFER_NOT_ENOUGH;
	        return rst;
	    }
	    // let head_info = new BGDefine.BGCSHeadInfo();
	    // memcpy(head_info, buffer, sizeof(* head_info));
	    // head_info -> seq_id = BG_NtoH32(head_info -> seq_id);
	    // head_info -> msg_cmd = BG_NtoH16(head_info -> msg_cmd);
	    // head_info -> tag_key = BG_NtoH64(head_info -> tag_key);
	    // head_info -> tag_val = BG_NtoH64(head_info -> tag_val);
	    // head_info -> session_id = BG_NtoH64(head_info -> session_id);
	    // head_info -> request_id = BG_NtoH64(head_info -> request_id);
	    let read_rst_32 = ReadFromBuff32(buffer, buffer_offset, buffer_len);
	    // tmp_get.val = BGHelper.HNSwitch32(tmp_get.val)
	    head_info.seq_id = read_rst_32.val;
	    rst.consumed_len += read_rst_32.consumed_len;
	    buffer_offset += read_rst_32.consumed_len;
	    buffer_len -= read_rst_32.consumed_len;
	    read_rst_32 = ReadFromBuff16(buffer, buffer_offset, buffer_len);
	    // tmp_get.val = BGHelper.HNSwitch16(tmp_get.val)
	    head_info.msg_cmd = read_rst_32.val;
	    rst.consumed_len += read_rst_32.consumed_len;
	    buffer_offset += read_rst_32.consumed_len;
	    buffer_len -= read_rst_32.consumed_len;
	    let read_rst_64 = ReadFromBuff64(buffer, buffer_offset, buffer_len);
	    // tmp_get.val = BGHelper.HNSwitch64(tmp_get.val)
	    head_info.tag_key = read_rst_64.val;
	    rst.consumed_len += read_rst_64.consumed_len;
	    buffer_offset += read_rst_64.consumed_len;
	    buffer_len -= read_rst_64.consumed_len;
	    read_rst_64 = ReadFromBuff64(buffer, buffer_offset, buffer_len);
	    // tmp_get.val = BGHelper.HNSwitch64(tmp_get.val)
	    head_info.tag_val = read_rst_64.val;
	    rst.consumed_len += read_rst_64.consumed_len;
	    buffer_offset += read_rst_64.consumed_len;
	    buffer_len -= read_rst_64.consumed_len;
	    read_rst_64 = ReadFromBuff64(buffer, buffer_offset, buffer_len);
	    // tmp_get.val = BGHelper.HNSwitch64(tmp_get.val)
	    head_info.session_id = read_rst_64.val;
	    rst.consumed_len += read_rst_64.consumed_len;
	    buffer_offset += read_rst_64.consumed_len;
	    buffer_len -= read_rst_64.consumed_len;
	    // read_rst_64 = BGHelper.ReadFromBuff64(buffer, buffer_offset, buffer_len);
	    // // tmp_get.val = BGHelper.HNSwitch64(tmp_get.val)
	    // head_info.request_id = read_rst_64.val;
	    // rst.consumed_len += read_rst_64.consumed_len;
	    return rst;
	}
	class ReadGateMsgRst {
	    constructor() {
	        this.error = 0;
	        this.consumed_len = 0;
	        this.head_info = null;
	        this.msg = null;
	    }
	}
	function GetCompressFlagBit(flag) {
	    return flag & 0x2;
	}
	function BGTryReadPkgFromBuffer(buffer, buffer_offset, buffer_len) {
	    let ret = new ReadGateMsgRst;
	    let read_pkg_info_rst = BGReadPkgInfoFromBuffer(buffer, buffer_offset, buffer_len);
	    if (0 != read_pkg_info_rst.error) {
	        ret.error = read_pkg_info_rst.error;
	        return ret;
	    }
	    if (read_pkg_info_rst.msg_size >= buffer_len) {
	        ret.error = BGCSMsgError.BG_READ_BUFFER_NOT_ENOUGH;
	        return ret;
	    }
	    buffer_offset += read_pkg_info_rst.consumed_len;
	    buffer_len -= read_pkg_info_rst.consumed_len;
	    let msg_size = read_pkg_info_rst.msg_size;
	    // 如果有压缩标记，先解压，再读取后续数据
	    const compressed = GetCompressFlagBit(read_pkg_info_rst.flag);
	    if (compressed) {
	        const compressed_data = Buffer.from(buffer, buffer_offset, read_pkg_info_rst.msg_size);
	        const after_decompress_data = decompress(compressed_data);
	        BGLog(exports.EBGLogLevel.Debug, "[StarkWebSDK] enable compress.", compressed_data.byteLength, after_decompress_data.byteLength, "rate:", after_decompress_data.byteLength / compressed_data.byteLength);
	        buffer = after_decompress_data.buffer;
	        buffer_offset = after_decompress_data.byteOffset;
	        buffer_len = after_decompress_data.byteLength;
	        msg_size = buffer_len;
	    }
	    let head_info = new BGCSHeadInfo();
	    let read_head_info_rst = BGReadHeadInfoFromBuffer(buffer, buffer_offset, buffer_len, head_info);
	    if (0 != read_head_info_rst.error) {
	        ret.error = BGCSMsgError.BG_PARSE_ERROR_FLAG;
	        return ret;
	    }
	    buffer_offset += read_head_info_rst.consumed_len;
	    ret.msg = new BGRawGateMsgInfo();
	    ret.head_info = head_info;
	    ret.msg.msg_cmd = head_info.msg_cmd;
	    ret.msg.msg_buff = buffer;
	    ret.msg.msg_offset = buffer_offset;
	    ret.msg.msg_len = msg_size - SIZE_OF_BGCSHEADINFO;
	    ret.consumed_len = SIZE_OF_BGCSPKGINFO + read_pkg_info_rst.msg_size;
	    return ret;
	}
	// 基本结构: 包头(大小，加密方式等)+pkghead(session, tag等)+业务消息体(tars打包)
	// BGCryptoContext* crypto_context, BGCSHeadInfo* head_info, const char* msg, uint32_t msg_len, char* buffer, uint32_t buffer_len, uint32_t* size_written
	function BGCSMsgWriteToBuffer(head_info, msg, msg_len, buffer, buffer_len) {
	    let rst = { error: 0, consumed_len: 0 };
	    // 1. write BGCSHeadInfo && msg
	    // 2. encrypt && compress buffer, set flag
	    // 3. write BGCSPkgInfo
	    // 4. fill encrypted && compressed msg
	    // TODO(@chenyu): Might add encryption padding size here.
	    // uint32_t maybe_size = sizeof(BGCSPkgInfo) + sizeof(*head_info) + msg_len;
	    let maybe_size = SIZE_OF_BGCSPKGINFO + SIZE_OF_BGCSHEADINFO + msg_len;
	    if (buffer_len < maybe_size) {
	        rst.error = BGCSMsgError.BG_WRITE_BUFFER_NOT_ENOUGH;
	        return rst;
	    }
	    let write_pkg_info = BGWritePkgInfoToBuffer(0, maybe_size - SIZE_OF_BGCSPKGINFO, buffer, buffer_len);
	    if (0 != write_pkg_info.error) {
	        rst.error = write_pkg_info.error;
	        return rst;
	    }
	    let write_head_rst = BGWriteHeadInfoToBuffer(head_info, buffer, SIZE_OF_BGCSPKGINFO, buffer_len);
	    if (0 != write_head_rst.error) {
	        rst.error = write_head_rst.error;
	        return rst;
	    }
	    let PRE_MSG_LEN = SIZE_OF_BGCSPKGINFO + SIZE_OF_BGCSHEADINFO;
	    let tmp_buff_len = buffer_len - PRE_MSG_LEN;
	    if (tmp_buff_len < msg_len) {
	        rst.error = BGCSMsgError.BG_WRITE_BUFFER_NOT_ENOUGH;
	        return rst;
	    }
	    // memcpy(tmp_buff + bytes_written, msg, msg_len);
	    // bytes_written += msg_len;
	    new Uint8Array(buffer, PRE_MSG_LEN, buffer_len - PRE_MSG_LEN).set(new Uint8Array(msg, 0, msg_len));
	    rst.consumed_len = PRE_MSG_LEN + msg_len;
	    return rst;
	}

	//BG相关预定义
	var ErrorCode;
	(function (ErrorCode) {
	    ErrorCode[ErrorCode["PARSE_MSG_FAILED"] = -3e3] = "PARSE_MSG_FAILED";
	    ErrorCode[ErrorCode["LOGIN_NETWORK_ERROR"] = -3001] = "LOGIN_NETWORK_ERROR";
	    ErrorCode[ErrorCode["LOGIN_FAILED"] = -3002] = "LOGIN_FAILED";
	    ErrorCode[ErrorCode["LOGIN_TIMEOUT"] = -3003] = "LOGIN_TIMEOUT";
	    ErrorCode[ErrorCode["RESUME_NO_VALID_SESSION"] = -3004] = "RESUME_NO_VALID_SESSION";
	    ErrorCode[ErrorCode["RESUME_RSP_INVALID_SESSION"] = -3005] = "RESUME_RSP_INVALID_SESSION";
	    ErrorCode[ErrorCode["LOGOUT_NO_VALID_SESSION"] = -3050] = "LOGOUT_NO_VALID_SESSION";
	    ErrorCode[ErrorCode["INGAMING_KICKED_BY_SERVER"] = -3100] = "INGAMING_KICKED_BY_SERVER";
	    ErrorCode[ErrorCode["INGAMING_TIMEOUT"] = -3101] = "INGAMING_TIMEOUT";
	    ErrorCode[ErrorCode["INGAMING_NETWORK_ERROR"] = -3102] = "INGAMING_NETWORK_ERROR";
	    ErrorCode[ErrorCode["LOGOUT_SUCCEED"] = -3200] = "LOGOUT_SUCCEED";
	})(ErrorCode || (ErrorCode = {}));
	var GateErrorCode;
	(function (GateErrorCode) {
	    GateErrorCode[GateErrorCode["BGCS_RET_SUCCESS"] = 0] = "BGCS_RET_SUCCESS";
	    GateErrorCode[GateErrorCode["BGCS_RET_SVR_ERROR"] = 1] = "BGCS_RET_SVR_ERROR";
	    GateErrorCode[GateErrorCode["BGCS_RET_PARAM_INVALID"] = 2] = "BGCS_RET_PARAM_INVALID";
	    GateErrorCode[GateErrorCode["BGCS_RET_AUTH_FAILED"] = 3] = "BGCS_RET_AUTH_FAILED";
	    GateErrorCode[GateErrorCode["BGCS_RET_GAMESVR_OFFLINE"] = 4] = "BGCS_RET_GAMESVR_OFFLINE";
	    GateErrorCode[GateErrorCode["BGCS_RET_DUPLICATED_LOGIN"] = 5] = "BGCS_RET_DUPLICATED_LOGIN";
	    GateErrorCode[GateErrorCode["BGCS_RET_ENQUEUE_ERROR"] = 6] = "BGCS_RET_ENQUEUE_ERROR";
	    GateErrorCode[GateErrorCode["BGCS_RET_ENQUEUE"] = 7] = "BGCS_RET_ENQUEUE";
	    GateErrorCode[GateErrorCode["BGCS_RET_INVALID_SESSION"] = 8] = "BGCS_RET_INVALID_SESSION";
	    GateErrorCode[GateErrorCode["BGCS_RET_KICK_TIMEOUT"] = 9] = "BGCS_RET_KICK_TIMEOUT";
	    GateErrorCode[GateErrorCode["BGCS_RET_AUTH_CODE_NOT_ZERO"] = 10] = "BGCS_RET_AUTH_CODE_NOT_ZERO";
	})(GateErrorCode || (GateErrorCode = {}));
	let ErrorCodeInfo = new Map([
	    [ErrorCode.PARSE_MSG_FAILED, "client: parse gate msg failed"],
	    [ErrorCode.LOGIN_NETWORK_ERROR, "login: network error"],
	    [ErrorCode.LOGIN_FAILED, "login: failed notification from gateserver"],
	    [ErrorCode.LOGIN_TIMEOUT, "login: time out"],
	    [ErrorCode.RESUME_NO_VALID_SESSION, "resume: resume without valid previous session info"],
	    [ErrorCode.RESUME_RSP_INVALID_SESSION, "resume: got resume response without valid previous session info"],
	    [ErrorCode.LOGOUT_NO_VALID_SESSION, "logout: logout without valid previous session info"],
	    [ErrorCode.INGAMING_KICKED_BY_SERVER, "in gameing: kicked by server"],
	    [ErrorCode.INGAMING_NETWORK_ERROR, "in gaming: network error"],
	    [ErrorCode.INGAMING_TIMEOUT, "in gaming: time out"],
	    [ErrorCode.LOGOUT_SUCCEED, "logout: succeed"],
	]);
	let GateErrorCodeInfo = new Map([
	    [GateErrorCode.BGCS_RET_SUCCESS, "gatesrv: no error"],
	    [GateErrorCode.BGCS_RET_SVR_ERROR, "gatesrv: server error"],
	    [GateErrorCode.BGCS_RET_PARAM_INVALID, "gatesrv: invalid request param"],
	    [GateErrorCode.BGCS_RET_AUTH_FAILED, "gatesrv: auth failed"],
	    [GateErrorCode.BGCS_RET_GAMESVR_OFFLINE, "gatesrv: no valid game server"],
	    [GateErrorCode.BGCS_RET_DUPLICATED_LOGIN, "gatesrv: duplicated login"],
	    [GateErrorCode.BGCS_RET_ENQUEUE_ERROR, "gatesrv: enqueue error"],
	    [GateErrorCode.BGCS_RET_ENQUEUE, "gatesrv: need enqueue"],
	    [GateErrorCode.BGCS_RET_INVALID_SESSION, "gatesrv: invalid session"],
	    [GateErrorCode.BGCS_RET_KICK_TIMEOUT, "gatesrv: kick last login failed"],
	    [GateErrorCode.BGCS_RET_AUTH_CODE_NOT_ZERO, "gatesrv: auth code not zero"],
	]);
	function GetErrorDesc(error_code) {
	    return ErrorCodeInfo.get(error_code) || "";
	}
	function GetGateErrorDesc(error_code) {
	    return GateErrorCodeInfo.get(error_code) || "";
	}

	var StarkError = /*#__PURE__*/Object.freeze({
		__proto__: null,
		get ErrorCode () { return ErrorCode; },
		GetErrorDesc: GetErrorDesc,
		GetGateErrorDesc: GetGateErrorDesc
	});

	var AuthType;
	(function (AuthType) {
	    AuthType[AuthType["AUTH_CODE"] = 1] = "AUTH_CODE";
	    AuthType[AuthType["AUTH_TOKEN"] = 2] = "AUTH_TOKEN";
	    AuthType[AuthType["AUTH_PASSPORT"] = 3] = "AUTH_PASSPORT";
	    AuthType[AuthType["AUTH_NONE"] = 4] = "AUTH_NONE";
	    AuthType[AuthType["AUTH_CUSTOMIZED"] = 5] = "AUTH_CUSTOMIZED";
	})(AuthType || (AuthType = {}));
	class AuthInfoCode {
	    constructor(code, anonymousCode) {
	        this.auth_type = AuthType.AUTH_CODE;
	        this.code = code;
	        this.anonymousCode = anonymousCode;
	    }
	}
	class AuthInfoAccessToken {
	    constructor(channel, openid, accessToken) {
	        this.auth_type = AuthType.AUTH_TOKEN;
	        this.channel = channel;
	        this.openid = openid;
	        this.accessToken = accessToken;
	    }
	}
	class AuthInfoPassportSDK {
	    constructor(cookie, x_tt_token) {
	        this.auth_type = AuthType.AUTH_PASSPORT;
	        this.cookie = cookie;
	        this.x_tt_token = x_tt_token;
	    }
	}
	class AuthInfoNone {
	    constructor(openid) {
	        this.auth_type = AuthType.AUTH_NONE;
	        this.openid = openid;
	    }
	}
	class AuthInfoCustomized {
	    constructor(customized_auth_data) {
	        this.customized_auth_data = customized_auth_data;
	        this.auth_type = AuthType.AUTH_CUSTOMIZED;
	    }
	}

	var StarkAuthInfo = /*#__PURE__*/Object.freeze({
		__proto__: null,
		AuthInfoAccessToken: AuthInfoAccessToken,
		AuthInfoCode: AuthInfoCode,
		AuthInfoCustomized: AuthInfoCustomized,
		AuthInfoNone: AuthInfoNone,
		AuthInfoPassportSDK: AuthInfoPassportSDK,
		get AuthType () { return AuthType; }
	});

	// 登录玩家
	var BGClientState;
	(function (BGClientState) {
	    BGClientState[BGClientState["Disconnected"] = 0] = "Disconnected";
	    BGClientState[BGClientState["WaitChallenge"] = 1] = "WaitChallenge";
	    BGClientState[BGClientState["InGaming"] = 2] = "InGaming";
	})(BGClientState || (BGClientState = {}));
	/**
	 * 一体化框架rpc客户端
	 * 1. 内外交互:
	 *    1)使用侧发起连接，连接成功后调用BGClient.InitClient(connection)初始化，传入的connection对象需要兼容IBGNetConnection接口(实现write方法向远端发送消息，例如nodejs的socket)
	 *    2)在收到服务器网络数据时，调用client.HandleSocketMsg(data)，由BGClient来处理网络收包(?目前为nodejs.Buffer)
	 * 2. 业务逻辑实现: 继承此类处理rpc，或者向外发出rpc调用
	 *    1)业务类定义OnBGConnected处理连接成功事件(握手成功)，调用this.StartLoginWithoutAuth()开始登录流程
	 *    2)业务类定义OnBGLoginResult方法处理登录结果
	 *    2)调用IssueRpcCall发起到服务器侧的rpc调用
	 *    3)成员方法自动成为rpc方法，可被服务器调用
	 */
	class BGClient {
	    constructor() {
	        this.client_id = 0;
	        this.cur_state = BGClient.State.WaitChallenge;
	        this.recv_buffer = null; //对nodejs Buffer的封装
	        this.send_buffer = null;
	        this.connection = null;
	        this.use_mc = true;
	        this.has_new_msg = true;
	        this.timeout_interval = 0;
	        this.session_info = null;
	        // private HandleMCMsg(mc_msg_parsed: RpcProto.bg_cs.CSMsgHead) {
	        //   //参数: mc_msg_parsed, 其类型: RpcProto.bg_cs.CSMsgHead
	        //   // this.msg_id = 0;
	        //   // this.msg_body = new TarsStream.BinBuffer
	        //   let is_mc_msg = new TarsStream.TarsInputStream(mc_msg_parsed.msg_body);
	        //   switch (mc_msg_parsed.msg_id) {
	        //     case RpcProto.bg_cs.EMsgId.CS_MSGID_SERVER_CALL:
	        //       let server_call = RpcProto.bg_cs.RpcCallInfo.create(is_mc_msg);
	        //       // let server_call = new RpcProto.bg_cs.RpcCallInfo._readFrom(is_mc_msg)
	        //       /*
	        //         0 require long async_id;
	        //         1 require RpcPeer call_src;
	        //         2 require RpcPeer call_tgt;
	        //         3 require string call_method;
	        //         4 require PACK_MODE pack_mode;
	        //         5 require vector<byte> packed_params
	        //        */
	        //       console.log("bytegame stark: rpc call from server:", server_call.async_id, server_call.call_tgt.peer_name, server_call.call_tgt.peer_insid, server_call.call_method);
	        //       this.OnRpcCall(server_call);
	        //       break;
	        //     default:
	        //       console.log(`bytegame stark: got unknown mc msg ${mc_msg_parsed.msg_id}`);
	        //   }
	        //   return 0;
	        // }
	        // private OnRpcCall(server_call: RpcProto.bg_cs.RpcCallInfo) {
	        //   let tmp_node_buff = server_call.packed_params.toNodeBuffer();
	        //   let tmp_arr_buff = tmp_node_buff.buffer.slice(tmp_node_buff.byteOffset, tmp_node_buff.byteOffset + tmp_node_buff.byteLength);
	        //   let params = fb_parser.toReference(tmp_arr_buff);
	        //   let rst_obj = params.toObject() as any[];
	        //   // let rst = this.GenModuleRegID("", "MaskMatch");
	        //   // console.log(`hash result is {${rst.error}, ${rst.hash_rst}}`, "call params", JSON.stringify(rst_obj));
	        //   let found_func = this[server_call.call_method as keyof typeof this];
	        //   if (typeof found_func == "function") {
	        //     found_func.apply(this, rst_obj.slice(1, rst_obj.length));
	        //   }
	        // }
	    }
	    OnBGConnected() {
	        BGLog(exports.EBGLogLevel.Warning, "bytegame stark: default OnBGConnected in BGClient");
	    }
	    OnBGClosed() {
	        BGLog(exports.EBGLogLevel.Warning, "bytegame stark: default OnBGClosed in BGClient");
	    }
	    OnBGError(error_code, error_desc, extra_info) {
	        BGLog(exports.EBGLogLevel.Warning, "bytegame stark: default OnNetworkError in BGClient", error_code, error_desc, extra_info);
	    }
	    OnBGRequestClose() {
	        BGLog(exports.EBGLogLevel.Warning, "bytegame stark: default OnBGRequestClose in BGClient");
	    }
	    //登录成功后由库回调
	    OnBGLoginResult(error_code, error_msg, uid, isresume) {
	        BGLog(exports.EBGLogLevel.Warning, "bytegame stark: default OnBGLoginResult in BGClient", error_code, error_msg, uid);
	    }
	    OnBGMsgFromGame(msg) {
	        BGLog(exports.EBGLogLevel.Warning, "bytegame stark: default OnBGMsgFromGame in BGClient");
	    }
	    ResetBGClient() {
	        BGLog(exports.EBGLogLevel.Info, "... bytegame stark: reset BGClient, client_id: ", this.client_id);
	        this.cur_state = BGClientState.Disconnected;
	        clearInterval(this.heartbeat_timer);
	        if (this.timeout_timer) {
	            clearInterval(this.timeout_timer);
	        }
	        this.recv_buffer = null;
	        this.heartbeat_timer = null;
	        this.timeout_timer = null;
	        this.session_info = null;
	    }
	    InitClient(connection, need_handshake, use_mc, timeout_interval) {
	        BGClient.client_id_alloc = BGClient.client_id_alloc + 1;
	        this.client_id = BGClient.client_id_alloc;
	        this.connection = connection;
	        this.use_mc = use_mc;
	        this.timeout_interval = timeout_interval * 1000;
	        let min_timeout_interval = BGClient.HEARTBEAT_INTERVAL * 5; //5次心跳都未收到回包，判定为断连
	        if ((this.timeout_interval > 0) && (this.timeout_interval < min_timeout_interval)) {
	            BGLog(exports.EBGLogLevel.Warning, `bytegame stark: init BGClient, error timeout_interval: ${this.timeout_interval}, use ${min_timeout_interval} instead`);
	            this.timeout_interval = min_timeout_interval;
	        }
	        BGLog(exports.EBGLogLevel.Info, `bytegame stark: init BGClient, client_id: ${this.client_id}, timeout_interval: ${this.timeout_interval} ...`);
	        this.recv_buffer = new BGMsgBuffer(MAX_MSG_BUFFER_SIZE);
	        this.send_buffer = new ArrayBuffer(MAX_MSG_BUFFER_SIZE);
	        if (!connection) {
	            BGLog(exports.EBGLogLevel.Warning, "bytegame stark: connect failed");
	            return true;
	        }
	        if (need_handshake) {
	            this.SendMsg(GetHandshakeStartMsg()); //握手完成再通知连接建立
	        }
	        else {
	            this.cur_state = BGClientState.InGaming; //状态直接设为游戏中
	            this.HandleSocketConnected();
	        }
	        return true;
	    }
	    FillLoginRequestWithAuthInfo(auth_info, login_request) {
	        if (!auth_info) {
	            BGLog(exports.EBGLogLevel.Error, "bytegame stark: no valid auth_info provided");
	            return false;
	        }
	        let oauth_info;
	        switch (auth_info.auth_type) {
	            case AuthType.AUTH_CODE:
	                {
	                    let tmp = auth_info;
	                    login_request.auth_type = bg_proto_cs.AuthType.AuthTypeMiniApp;
	                    oauth_info = new bg_proto_cs.OAuthAuthorizationCode;
	                    oauth_info.code = tmp.code;
	                    oauth_info.anonymous_code = tmp.anonymousCode;
	                }
	                break;
	            case AuthType.AUTH_CUSTOMIZED:
	                {
	                    let tmp = auth_info;
	                    login_request.auth_type = bg_proto_cs.AuthType.AuthTypeCustomized;
	                    oauth_info = new bg_proto_cs.OAuthCustomized;
	                    oauth_info.customized_auth_data = tmp.customized_auth_data;
	                }
	                break;
	            case AuthType.AUTH_NONE:
	                {
	                    let tmp = auth_info;
	                    login_request.auth_type = bg_proto_cs.AuthType.AuthTypeNone;
	                    oauth_info = new bg_proto_cs.Openid;
	                    oauth_info.openid = tmp.openid;
	                }
	                break;
	            case AuthType.AUTH_PASSPORT:
	                {
	                    let tmp = auth_info;
	                    login_request.auth_type = bg_proto_cs.AuthType.AuthTypePassportSDK;
	                    oauth_info = new bg_proto_cs.OAuthPassportSDK;
	                    oauth_info.cookie = tmp.cookie;
	                    oauth_info.x_tt_token = tmp.x_tt_token;
	                }
	                break;
	            case AuthType.AUTH_TOKEN:
	                {
	                    let tmp = auth_info;
	                    login_request.auth_type = bg_proto_cs.AuthType.AuthTypeGSDK;
	                    oauth_info = new bg_proto_cs.OAuthAccessToken;
	                    oauth_info.channel = tmp.channel;
	                    oauth_info.access_token = tmp.accessToken;
	                    oauth_info.openid = tmp.openid;
	                }
	                break;
	            default:
	                {
	                    BGLog(exports.EBGLogLevel.Error, "bytegame stark: unknown auth_info type", auth_info.auth_type);
	                    return false;
	                }
	        } //switch (auth_info.auth_type) {
	        login_request.auth_info = oauth_info.toBinBuffer();
	        return true;
	    }
	    StartLoginWithoutAuth() {
	        let msg_cmd = BGCSMsgType.BG_CS_MSG_LOGIN_REQ;
	        let login_msg = new bg_proto_cs.BGClientLoginReq();
	        /**
	              0 require int               auth_type;
	              1 require vector<byte>      auth_info;
	              2 require BGVersionInfo     version_info;
	              3 require BGDeviceInfo      device_info;
	              4 require BGEnvironmentInfo env_info
	         */
	        login_msg.auth_type = 0;
	        let oauth_info = new bg_proto_cs.OAuthInfoNone();
	        oauth_info.openid = "test tar account";
	        login_msg.auth_info = oauth_info.toBinBuffer();
	        let gate_msg = new bg_proto_cs.BGCSMsg();
	        login_msg.gamesvr_insid = 999;
	        gate_msg.result = 0;
	        gate_msg.cs_msg = login_msg.toBinBuffer();
	        let send_tars_binbuff = gate_msg.toBinBuffer().toNodeBuffer();
	        this.SendGateMsg(msg_cmd, send_tars_binbuff, send_tars_binbuff.byteLength);
	    }
	    StartLogout() {
	        if (!this.session_info) {
	            BGLog(exports.EBGLogLevel.Error, "StartLogout, no session_info, call closesocket directly");
	            this.CallBizOnError(ErrorCode.RESUME_NO_VALID_SESSION);
	            this.CallBizClose();
	            return;
	        }
	        BGLog(exports.EBGLogLevel.Info, "StartLogout, wait gate response ...");
	        let msg_cmd = BGCSMsgType.BG_CS_MSG_LOGOUT_REQ;
	        let logout_msg = new bg_proto_cs.BGClientLogoutReq();
	        let gate_msg = new bg_proto_cs.BGCSMsg();
	        gate_msg.result = 0;
	        gate_msg.cs_msg = logout_msg.toBinBuffer();
	        let send_tars_binbuff = gate_msg.toBinBuffer().toNodeBuffer();
	        this.SendGateMsg(msg_cmd, send_tars_binbuff, send_tars_binbuff.byteLength);
	        this.session_info = null;
	    }
	    StartResume(resume_info) {
	        if (!resume_info) {
	            this.CallBizOnError(ErrorCode.RESUME_NO_VALID_SESSION);
	            return;
	        }
	        this.session_info = resume_info;
	        let msg_cmd = BGCSMsgType.BG_CS_MSG_RELAY_LOGIN_REQ;
	        let relogin_msg = new bg_proto_cs.BGClientRelayLoginReq();
	        relogin_msg.uid = resume_info.uid;
	        relogin_msg.session_id = resume_info.session_id;
	        relogin_msg.ticket = resume_info.ticket;
	        let gate_msg = new bg_proto_cs.BGCSMsg();
	        gate_msg.result = 0;
	        gate_msg.cs_msg = relogin_msg.toBinBuffer();
	        let send_tars_binbuff = gate_msg.toBinBuffer().toNodeBuffer();
	        this.SendGateMsg(msg_cmd, send_tars_binbuff, send_tars_binbuff.byteLength);
	    }
	    StartLoginWithAuthInfo(auth_info, gamesvr_insid) {
	        let msg_cmd = BGCSMsgType.BG_CS_MSG_LOGIN_REQ;
	        let login_msg = new bg_proto_cs.BGClientLoginReq();
	        login_msg.gamesvr_insid = gamesvr_insid;
	        /**
	              0 require int               auth_type;
	              1 require vector<byte>      auth_info;
	              2 require BGVersionInfo     version_info;
	              3 require BGDeviceInfo      device_info;
	              4 require BGEnvironmentInfo env_info
	         */
	        this.FillLoginRequestWithAuthInfo(auth_info, login_msg);
	        let gate_msg = new bg_proto_cs.BGCSMsg();
	        gate_msg.result = 0;
	        gate_msg.cs_msg = login_msg.toBinBuffer();
	        let send_tars_binbuff = gate_msg.toBinBuffer().toNodeBuffer();
	        BGLog(exports.EBGLogLevel.Debug, "stark send login msg to gate");
	        this.SendGateMsg(msg_cmd, send_tars_binbuff, send_tars_binbuff.byteLength);
	    }
	    GetSessionInfo() {
	        return this.session_info;
	    }
	    CallBizOnError(errno, extra_info = null) {
	        this.OnBGError(errno, GetErrorDesc(errno) || "", extra_info);
	    }
	    CallBizClose() {
	        this.OnBGRequestClose();
	    }
	    HandleSocketConnected() {
	        this.heartbeat_timer = setInterval(this.SendHeartBeat.bind(this), BGClient.HEARTBEAT_INTERVAL); //启动定时心跳
	        if (this.timeout_interval > 0) {
	            this.has_new_msg = true;
	            this.timeout_timer = setInterval(this.CheckTimeOut.bind(this), this.timeout_interval); //启动超时检测
	        }
	        this.OnBGConnected();
	    }
	    CheckTimeOut() {
	        if (!this.has_new_msg) {
	            BGLog(exports.EBGLogLevel.Error, "bytegame stark: recv msg timeout, reset client now");
	            this.HandleSocketClose();
	            return;
	        }
	        this.has_new_msg = false;
	    }
	    HandleSocketClose() {
	        BGLog(exports.EBGLogLevel.Info, "bytegame stark: got close event from socket");
	        this.ResetBGClient();
	        this.OnBGClosed();
	    }
	    HandleSocketError(errno, errdesc) {
	        BGLog(exports.EBGLogLevel.Info, "bytegame stark: got event from socket:", errno, errdesc);
	        if (this.cur_state < BGClientState.InGaming) {
	            this.CallBizOnError(ErrorCode.LOGIN_NETWORK_ERROR);
	        }
	        else {
	            this.CallBizOnError(ErrorCode.INGAMING_NETWORK_ERROR);
	        }
	    }
	    HandleSocketMsg(buffer) {
	        BGLog(exports.EBGLogLevel.Debug, "bytegame stark: msg recved of length: %d", buffer.length); //, Date.now());
	        this.has_new_msg = true;
	        if (!this.recv_buffer) {
	            BGLog(exports.EBGLogLevel.Error, "bytegame stark: recv buffer is null"); //, Date.now());
	            return;
	        }
	        if (!this.recv_buffer.Append(buffer)) {
	            BGLog(exports.EBGLogLevel.Error, "bytegame stark: Parse recved msg error: append recv buff failed");
	            return;
	        }
	        switch (this.cur_state) {
	            case BGClient.State.WaitChallenge:
	                {
	                    let recv_buff_info = this.recv_buffer.GetContent();
	                    BGLog(exports.EBGLogLevel.Debug, 'bytegame stark: wait challenge, current recv buffer info', recv_buff_info.read_pos, recv_buff_info.available);
	                    let expected_len = BGClient.CHALLENGE_LEN;
	                    let msg_len = recv_buff_info.available;
	                    if (msg_len < expected_len) {
	                        return;
	                    }
	                    this.cur_state = BGClient.State.InGaming;
	                    let challenge = new Uint32Array(recv_buff_info.content_buffer, recv_buff_info.read_pos, expected_len);
	                    let net_chal0 = challenge[0];
	                    let net_chal1 = challenge[1];
	                    let net_chal2 = challenge[2];
	                    let net_chal3 = challenge[3];
	                    let chal0 = HNSwitch32(net_chal0);
	                    let chal1 = HNSwitch32(net_chal1);
	                    let chal2 = HNSwitch32(net_chal2);
	                    let chal3 = HNSwitch32(net_chal3);
	                    BGLog(exports.EBGLogLevel.Debug, "bytegame stark: got challenge from server: ", chal0.toString(16), chal1.toString(16), chal2.toString(16), chal3.toString(16));
	                    this.recv_buffer.Consume(expected_len);
	                    let prov_msg = GetProveMsgOfChallenge(chal0, chal1, chal2, chal3);
	                    this.SendMsg(prov_msg);
	                    this.HandleSocketConnected();
	                }
	                break;
	            case BGClient.State.InGaming:
	                {
	                    while (this.HandleInGamingMsg()) {
	                        BGLog(exports.EBGLogLevel.Debug, "bytegame stark: one game msg handled");
	                    }
	                }
	                break;
	            default:
	                BGLog(exports.EBGLogLevel.Error, `bytegame stark: got unknown cur state ${this.cur_state}.`);
	        }
	    }
	    SendMsg(msg_buff, offset, length) {
	        if (this.cur_state != BGClientState.InGaming) {
	            this.HandleInGamingMsg();
	            return;
	        }
	        if (this.connection) {
	            this.connection.write(Buffer.from(msg_buff, offset, length));
	        }
	        else {
	            BGLog(exports.EBGLogLevel.Error, "bytegame stark: invalid connection on SendMsg");
	        }
	    }
	    // IssueRpcCall(src_name: string, src_insid: number, tgt_name: string, tgt_insid: number, tgt_method: string, ...input_args: any[]) {
	    //   //1. 取源和目标模块hash
	    //   //2. 获取调用参数并用fb打包
	    //   //3. 填充RpcCallInfo
	    //   //4. 填充CSMsgHead
	    //   //5. 使用gate payload消息发送
	    //   //1. 取源和目标模块hash
	    //   console.log(`bytegame stark: src_name:${src_name}, src_insid:${src_insid}, tgt_name:${tgt_name}, tgt_insid:${tgt_insid}, tgt_method:${tgt_method}, args:`);
	    //   let src_hash = this.GenModuleRegID("", src_name);
	    //   let tgt_hash = this.GenModuleRegID("", tgt_name);
	    //   //2. 获取调用参数并用fb打包
	    //   if (!tgt_method) {
	    //     console.log("bytegame stark: IssueRpcCall, invalid tgt_method, ignore this call");
	    //     return -1;
	    //   }
	    //   let args = Array.prototype.slice.call(arguments, 5);
	    //   let fb_packed_params = this.PackRpcParams.apply(null, args);
	    //   let fb_packed_params_node_buffer = Buffer.from(fb_packed_params);
	    //   //3. 填充RpcCallInfo
	    //   /*
	    //     this.async_id = 0;
	    //     this.call_src = new bg_cs.RpcPeer;
	    //     this.call_tgt = new bg_cs.RpcPeer;
	    //     this.call_method = "";
	    //     this.pack_mode = bg_cs.PACK_MODE.PACK_MODE_FB;
	    //     this.packed_params = new TarsStream.BinBuffer;
	    //     this._classname = "bg_cs.RpcCallInfo";
	    //    */
	    //   let rpc_call_info = new RpcProto.bg_cs.RpcCallInfo();
	    //   rpc_call_info.call_src.peer_name = src_hash.hash_rst;
	    //   rpc_call_info.call_src.peer_insid = src_insid;
	    //   rpc_call_info.call_tgt.peer_name = tgt_hash.hash_rst;
	    //   rpc_call_info.call_tgt.peer_insid = tgt_insid;
	    //   rpc_call_info.call_method = tgt_method;
	    //   rpc_call_info.packed_params = new TarsStream.BinBuffer(fb_packed_params_node_buffer);
	    //   // let checkpoint_packed_params = rpc_call_info.packed_params.toNodeBuffer();
	    //   //4. 填充CSMsgHead
	    //   /*
	    //     this.msg_id = 0;
	    //     this.msg_body = new TarsStream.BinBuffer
	    //    */
	    //   let rpc_call_msg = new RpcProto.bg_cs.CSMsgHead();
	    //   rpc_call_msg.msg_id = RpcProto.bg_cs.EMsgId.CS_MSGID_CLIENT_CALL;
	    //   rpc_call_msg.msg_body = rpc_call_info.toBinBuffer();
	    //   // //////////////////////////////////
	    //   // // check rpc_call_info pack
	    //   // let checkpoint_rpc_call_info_node_buff = rpc_call_msg.msg_body.toNodeBuffer()
	    //   // let checkpoint_rpc_call_info_bin_buff = new TarsStream.BinBuffer(checkpoint_rpc_call_info_node_buff)
	    //   // let checkpoint_rpc_call_info_tar_stream = new TarsStream.TarsInputStream(checkpoint_rpc_call_info_bin_buff)
	    //   // let checkpoint_rpc_call_info = RpcProto.bg_cs.RpcCallInfo.create(checkpoint_rpc_call_info_tar_stream)
	    //   // // let checkpoint_rpc_call_info = RpcProto.bg_cs.RpcCallInfo._readFrom(checkpoint_rpc_call_info_tar_stream)
	    //   // ///////////////////////////////////
	    //   // //////////////////////////////////
	    //   // // 校验cs消息(CSMsgHead)
	    //   // let checkpoint_rpc_call_msg_node_buff = rpc_call_msg.toBinBuffer().toNodeBuffer()
	    //   // let checkpoint_rpc_call_msg_bin_buff = new TarsStream.BinBuffer(checkpoint_rpc_call_msg_node_buff)
	    //   // let checkpoint_rpc_call_msg_tar_stream = new TarsStream.TarsInputStream(checkpoint_rpc_call_msg_bin_buff)
	    //   // let checkpoint_rpc_call_msg = RpcProto.bg_cs.CSMsgHead.create(checkpoint_rpc_call_msg_tar_stream)
	    //   // // let checkpoint_rpc_call_msg = RpcProto.bg_cs.CSMsgHead._readFrom(checkpoint_rpc_call_msg_tar_stream)
	    //   // ///////////////////////////////////
	    //   // //////////////////////////////////
	    //   // // 校验cs消息(cs call)中的callinfo
	    //   // let checkpoint_msg_call_node_buff = checkpoint_rpc_call_msg.msg_body.toNodeBuffer()
	    //   // let checkpoint_msg_call_bin_buff = new TarsStream.BinBuffer(checkpoint_msg_call_node_buff)
	    //   // let checkpoint_msg_call_tar_stream = new TarsStream.TarsInputStream(checkpoint_msg_call_bin_buff)
	    //   // let checkpoint_msg_call = RpcProto.bg_cs.RpcCallInfo.create(checkpoint_msg_call_tar_stream)
	    //   // // let checkpoint_msg_call = RpcProto.bg_cs.RpcCallInfo._readFrom(checkpoint_msg_call_tar_stream)
	    //   // ///////////////////////////////////
	    //   // ///////////////////////////////////
	    //   // // 校验传参
	    //   // let tmp_param_node_buff = checkpoint_msg_call.packed_params.toNodeBuffer()
	    //   // let tmp_param_arr_buff = tmp_param_node_buff.buffer.slice(tmp_param_node_buff.byteOffset, tmp_param_node_buff.byteOffset + tmp_param_node_buff.byteLength);
	    //   // let tmp_fb_params = fb_parser.toReference(tmp_param_arr_buff)
	    //   // let tmp_params = tmp_fb_params.toObject()
	    //   // ///////////////////////////////////
	    //   //5. 使用gate payload消息发送  
	    //   this.SendRpcMsgToGate(rpc_call_msg);
	    // }
	    HandleInGamingMsg() {
	        if (!this.recv_buffer) {
	            BGLog(exports.EBGLogLevel.Error, 'bytegame stark: current recv buffer is null, cur state', BGClient.State[this.cur_state]);
	            return false;
	        }
	        let recv_buff_info = this.recv_buffer.GetContent();
	        BGLog(exports.EBGLogLevel.Debug, 'bytegame stark: in gaming, current recv buffer info', recv_buff_info.read_pos, recv_buff_info.available);
	        //1.处理未收全包
	        //2.如果收包完整，则进一步解出raw消息(消息id--heartbeat/payload)
	        //3.raw gate消息的处理
	        //1.解出raw pkg info, 处理未收全包
	        let msg_len = recv_buff_info.available;
	        if (msg_len < SIZE_OF_BGCSPKGINFO) {
	            //raw包头未收完
	            return false;
	        }
	        //2.如果收包完整，则进一步解出raw消息(消息id--heartbeat/payload)
	        let raw_gate_msg_info = BGTryReadPkgFromBuffer(recv_buff_info.content_buffer, recv_buff_info.read_pos, recv_buff_info.available);
	        if ((0 != raw_gate_msg_info.error) || !raw_gate_msg_info.msg) {
	            if (raw_gate_msg_info.error != BGCSMsgError.BG_READ_BUFFER_NOT_ENOUGH) {
	                BGLog(exports.EBGLogLevel.Error, "bytegame stark: parse raw gate msg failed with:", raw_gate_msg_info.error);
	                //TODO@chenyu, 关闭连接，错误返回
	            }
	            return false;
	        }
	        //3.raw gate消息的处理
	        this.OnGateMsg(raw_gate_msg_info.msg);
	        if (this.recv_buffer) {
	            this.recv_buffer.Consume(raw_gate_msg_info.consumed_len); //消耗消息长度(pkginfo+headinfo+msgsize) 
	        }
	        else {
	            BGLog(exports.EBGLogLevel.Error, 'bytegame stark: current recv buffer is null, cur state', BGClient.State[this.cur_state]);
	        }
	        return true;
	    }
	    OnGateMsg(gate_raw_msg_info) {
	        //3.若为payload，则进一步进行tars解包
	        /**
	          ret.msg.msg_cmd = head_info.msg_cmd
	          ret.msg.msg_buff = buffer
	          ret.msg.msg_offset = buffer_offset
	          ret.msg.msg_len = read_pkg_info_rst.msg_size
	         */
	        //分别消息类型处理，心跳/登录响应/payload
	        let gate_msg_parsed = null;
	        let is_sc_msg = null;
	        // let mc_msg_parsed: RpcProto.bg_cs.CSMsgHead | null = null;
	        if ((BGCSMsgType.BG_SC_MSG_BIZ_PAYLOAD != gate_raw_msg_info.msg_cmd) && (BGCSMsgType.BG_CS_MSG_BIZ_PAYLOAD != gate_raw_msg_info.msg_cmd)) {
	            //gate raw msg，定义于bg_cs_msg中
	            let node_buff = Buffer.from(gate_raw_msg_info.msg_buff, gate_raw_msg_info.msg_offset, gate_raw_msg_info.msg_len);
	            let tars_bin_buff = new tarsExports.BinBuffer(node_buff);
	            let is_gate_msg = new tarsExports.TarsInputStream(tars_bin_buff);
	            gate_msg_parsed = bg_proto_cs.BGCSMsg.create(is_gate_msg);
	            // gate_msg_parsed = new GateProto.bg_proto_cs.BGCSMsg._readFrom(is_gate_msg)
	            is_sc_msg = new tarsExports.TarsInputStream(gate_msg_parsed.cs_msg);
	        }
	        else {
	            BGLog(exports.EBGLogLevel.Debug, "bytegame stark: payload msg from game recved, length:", gate_raw_msg_info.msg_len);
	            if (this.use_mc) {
	                //payload msg, 定义于bg_game_cs_msg中
	                let node_buff = Buffer.from(gate_raw_msg_info.msg_buff, gate_raw_msg_info.msg_offset, gate_raw_msg_info.msg_len);
	                let tars_bin_buff = new tarsExports.BinBuffer(node_buff);
	                new tarsExports.TarsInputStream(tars_bin_buff);
	                // mc_msg_parsed = RpcProto.bg_cs.CSMsgHead.create(is_gate_msg);
	                // mc_msg_parsed = RpcProto.bg_cs.CSMsgHead._readFrom(is_gate_msg)
	            }
	            else {
	                // non-mc msg from gameserver
	                let start = gate_raw_msg_info.msg_offset;
	                let end = start + gate_raw_msg_info.msg_len;
	                this.OnBGMsgFromGame(gate_raw_msg_info.msg_buff.slice(start, end));
	                return;
	            }
	        }
	        if ((!gate_msg_parsed)) { //} && (!mc_msg_parsed)) {
	            BGLog(exports.EBGLogLevel.Error, "bytegame stark: parse msg failed, (!gate_msg_parsed) && (!mc_msg_parsed)");
	            return;
	        }
	        if (gate_msg_parsed) {
	            switch (gate_raw_msg_info.msg_cmd) {
	                case BGCSMsgType.BG_SC_MSG_HEARTBEAT:
	                    BGLog(exports.EBGLogLevel.Info, "heartbeat recved");
	                    break;
	                case BGCSMsgType.BG_SC_MSG_LOGIN_RSP:
	                    {
	                        BGLog(exports.EBGLogLevel.Debug, "bytegame stark: login rsp recved, error: ", gate_msg_parsed.result);
	                        let gate_msg_login_rsp = null;
	                        if (is_sc_msg) {
	                            gate_msg_login_rsp = bg_proto_cs.BGClientLoginRsp.create(is_sc_msg);
	                            BGLog(exports.EBGLogLevel.Debug, `bytegame stark: login rsp parsed: (result:${gate_msg_parsed.result}, errmsg:${gate_msg_login_rsp.err_msg}), ${gate_msg_login_rsp.logid}, ${gate_msg_login_rsp.session_info.session_id}`);
	                        }
	                        else {
	                            BGLog(exports.EBGLogLevel.Warning, "bytegame stark: login rsp parse, got null is_sc_msg");
	                        }
	                        if (gate_msg_login_rsp) {
	                            this.session_info = gate_msg_login_rsp.session_info;
	                            this.OnBGLoginResult(gate_msg_parsed.result, gate_msg_login_rsp.err_msg, this.session_info.uid, false);
	                        }
	                        else {
	                            this.CallBizOnError(ErrorCode.PARSE_MSG_FAILED);
	                        }
	                    }
	                    break;
	                case BGCSMsgType.BG_SC_MSG_RELAY_LOGIN_RSP:
	                    {
	                        BGLog(exports.EBGLogLevel.Debug, "bytegame stark: resume login rsp recved, error: ", gate_msg_parsed.result);
	                        if (!this.session_info) {
	                            this.CallBizOnError(ErrorCode.RESUME_RSP_INVALID_SESSION);
	                            return;
	                        }
	                        let gate_msg_resume_rsp = null;
	                        if (is_sc_msg) {
	                            gate_msg_resume_rsp = bg_proto_cs.BGClientRelayLoginRsp.create(is_sc_msg);
	                            BGLog(exports.EBGLogLevel.Debug, `bytegame stark: resume login rsp parsed: (result:${gate_msg_parsed.result}`);
	                        }
	                        else {
	                            BGLog(exports.EBGLogLevel.Debug, "bytegame stark: resume login rsp parse, got null is_sc_msg");
	                        }
	                        if (gate_msg_resume_rsp) {
	                            this.OnBGLoginResult(gate_msg_parsed.result, "", this.session_info.uid, true);
	                        }
	                        else {
	                            this.CallBizOnError(ErrorCode.PARSE_MSG_FAILED);
	                        }
	                    }
	                    break;
	                case BGCSMsgType.BG_SC_MSG_LOGOUT_RSP:
	                    BGLog(exports.EBGLogLevel.Debug, "bytegame stark: ... gate logout rsp recved, error: ", gate_msg_parsed.result);
	                    this.CallBizClose();
	                    break;
	                case BGCSMsgType.BG_SC_MSG_CLOSE_NOTIFY:
	                    BGLog(exports.EBGLogLevel.Debug, "bytegame stark: close notify from gate, close self now ...");
	                    let gate_msg_close_notify = null;
	                    if (is_sc_msg) {
	                        gate_msg_close_notify = bg_proto_cs.BGClientCloseNotify.create(is_sc_msg);
	                        let tmp_reason = gate_msg_close_notify.reason;
	                        let tmp_reason_str = bg_proto_cs.CloseReason[tmp_reason];
	                        this.CallBizOnError(ErrorCode.INGAMING_KICKED_BY_SERVER, { error_code: tmp_reason, error_msg: tmp_reason_str });
	                        BGLog(exports.EBGLogLevel.Warning, `bytegame stark: close notify parsed: (result:${gate_msg_parsed.result}`);
	                    }
	                    else {
	                        BGLog(exports.EBGLogLevel.Error, "bytegame stark: close notify parse, got null is_sc_msg");
	                    }
	                    this.CallBizClose();
	                    break;
	                default:
	                    BGLog(exports.EBGLogLevel.Error, `bytegame stark: got unknown raw msg cmd from gate ${gate_raw_msg_info.msg_cmd}`);
	            }
	        }
	        if (this.use_mc) {
	            BGLog(exports.EBGLogLevel.Error, "!!!!!!!, deprecated msg handle path");
	            // if (mc_msg_parsed) {
	            //   // must be payload from MC
	            //   switch (gate_raw_msg_info.msg_cmd) {
	            //     case BGDefine.BGCSMsgType.BG_SC_MSG_BIZ_PAYLOAD:
	            //       console.log("bytegame stark: payload msg(from MC) recved, mc msgid:", mc_msg_parsed.msg_id);
	            //       this.HandleMCMsg(mc_msg_parsed);
	            //       break;
	            //     case BGDefine.BGCSMsgType.BG_CS_MSG_BIZ_PAYLOAD:
	            //       console.log("bytegame stark: payload msg(self test) recved, mc msgid:", mc_msg_parsed.msg_id);
	            //       this.HandleMCMsg(mc_msg_parsed);
	            //       break;
	            //     default:
	            //       console.log(`bytegame stark: mc_msg_parsed, got unknown raw msg cmd from gate ${gate_raw_msg_info.msg_cmd}`);
	            //   }
	            // }
	        }
	    }
	    // const ConnectionPtr& cliconn, uint16_t msgtype, const char* msgbuf, size_t msglen, uint64_t tickinmsg, uint32_t seqid
	    SendGateMsg(msgtype, msgbuf, msglen, target) {
	        let cshead = new BGCSHeadInfo();
	        cshead.msg_cmd = msgtype;
	        cshead.seq_id = 0;
	        cshead.session_id = long.fromValue({ low: 0, high: 0, unsigned: true }); //new Long(0, 0, true);
	        if (target) {
	            //指定tag发送
	            let tgt_type = 0;
	            if (target.name) {
	                tgt_type = this.GenModuleRegID("", target.name).hash_rst;
	            }
	            else if (target.ins_type) {
	                tgt_type = target.ins_type;
	            }
	            cshead.tag_key = long.fromNumber(tgt_type);
	            cshead.tag_val = long.fromNumber(target.ins_id);
	            // cshead.request_id = Long.fromNumber(0);
	            // BGHelper.BGLog(BGHelper.EBGLogLevel.Error, "msg to ", cshead.tag_key, cshead.tag_val);
	        }
	        if (null == this.send_buffer) {
	            BGLog(exports.EBGLogLevel.Error, "error send buff invalid");
	            return 0;
	        }
	        let write_rst = BGCSMsgWriteToBuffer(cshead, msgbuf, msglen, this.send_buffer, MAX_MSG_BUFFER_SIZE);
	        if (0 != write_rst.error) {
	            return write_rst.error;
	        }
	        BGLog(exports.EBGLogLevel.Debug, "stark send msg ", msgtype, "to gate");
	        this.SendMsg(this.send_buffer, 0, write_rst.consumed_len);
	        return 0;
	    }
	    SendHeartBeat() {
	        let msg_cmd = BGCSMsgType.BG_CS_MSG_HEARTBEAT;
	        let heartbeat_msg = new bg_proto_cs.BGHeartbeatReq();
	        heartbeat_msg.last_ttl = 0;
	        heartbeat_msg.seq_no = 1;
	        heartbeat_msg.timestamp = 123;
	        let gate_msg = new bg_proto_cs.BGCSMsg();
	        gate_msg.result = 0;
	        gate_msg.cs_msg = heartbeat_msg.toBinBuffer();
	        let send_tars_binbuff = gate_msg.toBinBuffer().toNodeBuffer();
	        BGLog(exports.EBGLogLevel.Debug, "bytegame stark: send heartbeat to gate");
	        this.SendGateMsg(msg_cmd, send_tars_binbuff, send_tars_binbuff.byteLength);
	    }
	    // private SendRpcMsgToGate(bg_rpc_msg: RpcProto.bg_cs.CSMsgHead) {
	    //   let msg_cmd = BGDefine.BGCSMsgType.BG_CS_MSG_BIZ_PAYLOAD;
	    //   // let gate_msg = new GateProto.bg_proto_cs.BGCSMsg()
	    //   // gate_msg.result = 0
	    //   // gate_msg.cs_msg = bg_rpc_msg.toBinBuffer()
	    //   // let checkpoint_rpc_msg_head = gate_msg.cs_msg.toNodeBuffer()
	    //   // let gate_msg_node_buff = gate_msg.toBinBuffer().toNodeBuffer()
	    //   // let checkpoint_gate_msg = gate_msg.cs_msg.toNodeBuffer()
	    //   // console.log("send bg rpc msg, length:", gate_msg_node_buff.byteLength)
	    //   // let gate_raw_msg_info = {};
	    //   // gate_raw_msg_info.msg_buff = gate_msg_node_buff.buffer.slice(gate_msg_node_buff.byteOffset, gate_msg_node_buff.byteOffset + gate_msg_node_buff.byteLength);
	    //   let rpc_msg_node_buff = bg_rpc_msg.toBinBuffer().toNodeBuffer();
	    //   let rpc_msg_arr_buff = rpc_msg_node_buff.buffer.slice(rpc_msg_node_buff.byteOffset, rpc_msg_node_buff.byteOffset + rpc_msg_node_buff.byteLength);
	    //   // 本地自解压测试 ...
	    //   // gate_raw_msg_info.msg_buff = rpc_msg_arr_buff 
	    //   // gate_raw_msg_info.msg_offset = 0
	    //   // gate_raw_msg_info.msg_len = rpc_msg_node_buff.length
	    //   // gate_raw_msg_info.msg_cmd = msg_cmd
	    //   // this.OnGateMsg(gate_raw_msg_info)
	    //   // ... 本地自解压测试
	    //   this.SendGateMsg(msg_cmd, rpc_msg_arr_buff, rpc_msg_arr_buff.byteLength);
	    //   return;
	    // }
	    SendBizPayloadToGate(msgbuf, target) {
	        if (this.cur_state != BGClientState.InGaming) {
	            BGLog(exports.EBGLogLevel.Error, "not connected, skip msg sending, curstate:", this.cur_state);
	            return false;
	        }
	        let msg_cmd = BGCSMsgType.BG_CS_MSG_BIZ_PAYLOAD;
	        this.SendGateMsg(msg_cmd, msgbuf, msgbuf.byteLength, target);
	        return true;
	    }
	    // private PackRpcParams(...inargs: any[]) {
	    //   var args = Array.prototype.slice.call(arguments);
	    //   let fb_ins = new fb_builder.Builder();
	    //   let array_len = args.length;
	    //   fb_ins.startVector();
	    //   for (var i = 0; i < array_len; i++) {
	    //     fb_ins.add(i);
	    //     fb_ins.add(args[i]);
	    //   }
	    //   fb_ins.end();
	    //   return fb_ins.finish();
	    // }
	    //const char* game_zone_set, const char* module_type, uint32_t& reg_id, std::string& out_key
	    GenModuleRegID(game_zone_set, module_type) {
	        let rst = { error: 0, hash_rst: 0 };
	        let hash_key = game_zone_set;
	        hash_key += ".";
	        hash_key += module_type;
	        rst.hash_rst = hashBytes(hash_key, hash_key.length, RPC_INDEX_HASH_SEED);
	        return rst;
	    }
	} //class BGClient {
	BGClient.State = BGClientState;
	// readonly State = BGClient.State;  
	BGClient.CHALLENGE_LEN = 16;
	BGClient.HEARTBEAT_INTERVAL = 2000;
	BGClient.client_id_alloc = 1;

	exports.BGState = void 0;
	(function (BGState) {
	    BGState[BGState["Stopped"] = 1] = "Stopped";
	    BGState[BGState["Connecting"] = 2] = "Connecting";
	    BGState[BGState["Logining"] = 3] = "Logining";
	    BGState[BGState["InGaming"] = 4] = "InGaming";
	    BGState[BGState["Disconnecting"] = 5] = "Disconnecting";
	    BGState[BGState["ReopenStopped"] = 6] = "ReopenStopped";
	})(exports.BGState || (exports.BGState = {}));
	//内部client类，在通信层与option回调间转发
	class BGClientImp extends BGClient {
	    constructor(options, close_socket_functor, resume_info = null) {
	        super();
	        this.resume_info = null;
	        this.options = options;
	        this.close_socket_functor = close_socket_functor;
	        this.bg_state = exports.BGState.Stopped;
	        this.resume_info = resume_info;
	    }
	    SetConnectState(state) {
	        this.bg_state = state;
	    }
	    GetState() {
	        return this.bg_state;
	    }
	    BeforeReopen() {
	        this.bg_state = exports.BGState.ReopenStopped;
	        return;
	    }
	    //新连接建立处理(握手成功)
	    OnBGConnected() {
	        if (this.bg_state == exports.BGState.ReopenStopped) {
	            BGLog(exports.EBGLogLevel.Warning, "ReopenStopped: skip OnBGConnected");
	            return;
	        }
	        BGLog(exports.EBGLogLevel.Debug, "stark BGClientImp, server connected");
	        this.bg_state = exports.BGState.Logining;
	        if (!this.resume_info) {
	            //正常登录
	            this.StartLoginWithAuthInfo(this.options.authInfo, this.options.gamesvr_insid);
	        }
	        else {
	            //重连(reopen)
	            this.StartResume(this.resume_info);
	        }
	    }
	    //登录成功后由库回调
	    OnBGLoginResult(error_code, error_msg, uid, isresume) {
	        if (this.bg_state == exports.BGState.ReopenStopped) {
	            BGLog(exports.EBGLogLevel.Warning, "ReopenStopped: skip OnBGLoginResult");
	            return;
	        }
	        if (0 != error_code) {
	            if (error_msg.length <= 0) {
	                error_msg = GetGateErrorDesc(error_code);
	            }
	            BGLog(exports.EBGLogLevel.Info, "BGClientImp, login failed:", error_code, error_msg);
	            this.CallBizOnError(ErrorCode.LOGIN_FAILED, { error_code: error_code, error_msg: error_msg });
	            this.CallBizClose();
	            return;
	        }
	        this.bg_state = exports.BGState.InGaming;
	        BGLog(exports.EBGLogLevel.Info, "BGClientImp, login succeed");
	        if (this.options.onopen) {
	            this.options.onopen(uid, isresume);
	        }
	    }
	    OnBGMsgFromGame(msg) {
	        if (this.bg_state == exports.BGState.ReopenStopped) {
	            BGLog(exports.EBGLogLevel.Warning, "ReopenStopped: skip OnBGMsgFromGame");
	            return;
	        }
	        BGLog(exports.EBGLogLevel.Debug, `BGClientImp, msg from game, len:${msg.byteLength}`);
	        if (this.options.onmessage) {
	            this.options.onmessage(msg);
	        }
	        return;
	    }
	    OnBGError(error_code, error_desc, extra_info) {
	        if (this.bg_state == exports.BGState.ReopenStopped) {
	            BGLog(exports.EBGLogLevel.Warning, "ReopenStopped: skip OnBGError");
	            return;
	        }
	        BGLog(exports.EBGLogLevel.Warning, "BGClientImp, error from stark net:", error_code, error_desc);
	        if (this.options.onerror) {
	            this.options.onerror(error_code, error_desc, extra_info);
	        }
	        this.CallBizClose();
	        return;
	    }
	    OnBGClosed() {
	        if (this.bg_state == exports.BGState.ReopenStopped) {
	            BGLog(exports.EBGLogLevel.Warning, "ReopenStopped: skip OnBGClosed");
	            return;
	        }
	        BGLog(exports.EBGLogLevel.Info, "BGClientImp, close event from stark net");
	        if (this.options.onclose) {
	            this.options.onclose();
	        }
	        this.bg_state = exports.BGState.Stopped;
	        return;
	    }
	    OnBGRequestClose() {
	        if (this.bg_state == exports.BGState.ReopenStopped) {
	            BGLog(exports.EBGLogLevel.Warning, "ReopenStopped: skip OnBGRequestClose");
	            return;
	        }
	        BGLog(exports.EBGLogLevel.Info, "BGClientImp, request ending from stark net");
	        this.bg_state = exports.BGState.Disconnecting;
	        this.close_socket_functor();
	    }
	} //class MyClient extends bg.BGClient 
	class WSAdapter {
	    constructor(inws, isSocketService) {
	        this.wsins = inws;
	        this.use_base64 = false;
	        this.isSocketService = isSocketService;
	        this.base64_send_mode = "base64";
	    }
	    setUseBase64(base64_send_mode) {
	        this.use_base64 = true;
	        this.base64_send_mode = base64_send_mode ? base64_send_mode : "base64";
	    }
	    write(buffer, cb) {
	        if (this.use_base64) {
	            // BGHelper.BGLog(BGHelper.EBGLogLevel.Info, "send pkg before base64: ", buffer.toString(), buffer.length);
	            let base64data = Buffer.from(buffer).toString("base64");
	            // BGHelper.BGLog(BGHelper.EBGLogLevel.Info, "send pkg after base64: ", base64data, base64data.length);
	            this.wsins.send(base64data, this.base64_send_mode);
	            // let restored = Buffer.from(base64data, 'base64')
	            // BGHelper.BGLog(BGHelper.EBGLogLevel.Info, "restored binary: ", restored.toString('hex'), restored.length);
	        }
	        else {
	            if (this === null || this === void 0 ? void 0 : this.isSocketService) {
	                let clonebuf = new Uint8Array(buffer.byteLength);
	                clonebuf.set(buffer);
	                this.wsins.send(buffer, "arraybuffer");
	            }
	            else {
	                this.wsins.send(buffer);
	            }
	        }
	        return true;
	    }
	}
	class StarkWS {
	    constructor(options) {
	        this.options = options;
	        this.bg_client = new BGClientImp(options, this.closesocket.bind(this));
	        this.wsIns = null;
	        this.reopen_flag = false;
	    }
	    open() {
	        var _a, _b, _c, _d;
	        this.reopen_flag = false;
	        let headers = {};
	        // add 'use_base64' accord to options
	        if (this.options.use_base64) {
	            headers['use_base64'] = 'true';
	        }
	        if (!this.wsIns) {
	            //non-reopen
	            if (this.options.wsIns) {
	                this.wsIns = this.options.wsIns;
	            }
	            else if (null != this.options.wsType) {
	                if ((_a = this.options) === null || _a === void 0 ? void 0 : _a.isSocketService) {
	                    const clientSocket = new this.options.wsType();
	                    this.wsIns = clientSocket;
	                }
	                else {
	                    // this.wsIns = new this.options.wsType(this.options.url);
	                    // let headers:any = {
	                    // 	'X-Tt-Env': 'boe_avatar_chenyu',
	                    // 	'X-Use-Ppe': 1
	                    // };
	                    this.wsIns = new this.options.wsType(this.options.url, {
	                        headers: headers
	                    });
	                }
	            }
	            else {
	                //见下面的注释，标准WebSocket不支持设置headers
	                this.wsIns = new WebSocket(this.options.url);
	            }
	        }
	        if (this.wsIns) {
	            /**
	             * As for setting headers for the WebSocket connection in browser environments, the WebSocket API does not provide a native way to customize headers. It's because the WebSocket protocol does not have a concept of headers in the same way that HTTP does.
	             * TODO@chenyu.0101: 1.确定lynx websocket的header设置方式是否如此，如果不支持，则只能考虑URL传递，或者依据传递的内容是utf8还是binary来确定了; 2. 需确定这里dataType的设置,对于base64是否要设为'utf8';
	             */
	            this.bg_client.SetConnectState(exports.BGState.Connecting);
	            BGLog(exports.EBGLogLevel.Debug, "stark before setcallbacks, version:2.0.1 ...");
	            this.setcallbacks();
	            BGLog(exports.EBGLogLevel.Debug, "... stark after setcallbacks");
	            this.wsIns.binaryType = 'arraybuffer';
	            let dataType = 'arraybuffer';
	            // if (this.options.use_base64){
	            // 	dataType = 'utf8';
	            // }
	            // import { SocketService } from "@byted-dino/lynx-tools"; 的支持
	            if (((_b = this.options) === null || _b === void 0 ? void 0 : _b.isSocketService) && this.wsIns.init) {
	                this.wsIns.init();
	            }
	            // import { SocketService } from "@byted-dino/lynx-tools"; 的支持
	            if (((_c = this.options) === null || _c === void 0 ? void 0 : _c.isSocketService) && this.wsIns.connect) {
	                this.wsIns.connect({
	                    url: this.options.url,
	                    dataType: dataType,
	                    headers: headers,
	                });
	            }
	            // import { socket } from "@byted-dino/gaea"; 的支持
	            if (this.wsIns.open) {
	                this.wsIns.open(this.options.url, (_d = this.options) === null || _d === void 0 ? void 0 : _d.protocols);
	            }
	        }
	        return true;
	    }
	    reopen(wsIns = null) {
	        if (this.options.wsIns && !wsIns) {
	            BGLog(exports.EBGLogLevel.Error, "reopen param not consistent with initial options, should be called with a websocket instance");
	            return false;
	        }
	        if (!this.options.wsIns && wsIns) {
	            BGLog(exports.EBGLogLevel.Error, "reopen param not consistent with initial options, should not be called with a websocket instance");
	            return false;
	        }
	        let oldsession_info = this.bg_client.GetSessionInfo();
	        if (!oldsession_info) {
	            BGLog(exports.EBGLogLevel.Error, "reopen failed: old session is not valid");
	            return false;
	        }
	        this.bg_client.BeforeReopen();
	        this.bg_client.HandleSocketClose();
	        this.resetcallbacks();
	        this.closesocket();
	        this.wsIns = null;
	        if (wsIns) {
	            this.wsIns = wsIns;
	        }
	        this.bg_client = new BGClientImp(this.options, this.closesocket.bind(this), oldsession_info);
	        this.open();
	        return true;
	    }
	    send(buff, target) {
	        this.bg_client.SendBizPayloadToGate(buff, target);
	        return true;
	    }
	    close() {
	        if (this.wsIns) {
	            this.bg_client.SetConnectState(exports.BGState.Disconnecting);
	            this.bg_client.StartLogout();
	        }
	        return;
	    }
	    getstate() {
	        return exports.BGState[this.bg_client.GetState()];
	    }
	    static setlogfunc(logFunc) {
	        SetLogFunc(logFunc);
	    }
	    closesocket() {
	        if (this.wsIns) {
	            this.wsIns.close();
	            this.bg_client.SetConnectState(exports.BGState.Disconnecting);
	        }
	        else {
	            this.bg_client.SetConnectState(exports.BGState.Stopped);
	        }
	    }
	    setcallbacks() {
	        if (this.wsIns) {
	            this.wsIns.onopen = this.socketOnOpen.bind(this);
	            this.wsIns.onmessage = this.socketOnMessage.bind(this);
	            this.wsIns.onclose = this.socketOnClose.bind(this);
	            this.wsIns.onerror = this.socketOnError.bind(this);
	        }
	    }
	    resetcallbacks() {
	        if (this.wsIns) {
	            this.wsIns.onopen = null;
	            this.wsIns.onmessage = null;
	            this.wsIns.onclose = null;
	            this.wsIns.onerror = null;
	        }
	    }
	    socketOnOpen(event) {
	        var _a;
	        if (!this.wsIns) {
	            BGLog(exports.EBGLogLevel.Warning, "stark socketOnOpen, this.ws is not valid");
	            return;
	        }
	        let myws = new WSAdapter(this.wsIns, (_a = this.options) === null || _a === void 0 ? void 0 : _a.isSocketService);
	        if (this.options.use_base64) {
	            BGLog(exports.EBGLogLevel.Info, "stark socketOnOpen, use_base64: true, base64_send_mode:", this.options.base64_send_mode);
	            myws.setUseBase64(this.options.base64_send_mode);
	        }
	        this.bg_client.SetConnectState(exports.BGState.Logining);
	        if (!this.options.timeoutInterval) {
	            this.options.timeoutInterval = -1;
	        }
	        BGLog(exports.EBGLogLevel.Debug, `stark [CLIENT] socketOnOpen() with timeoutInterval: ${this.options.timeoutInterval}`);
	        this.bg_client.InitClient(myws, false, false, this.options.timeoutInterval);
	        return;
	    }
	    ;
	    socketOnMessage(message) {
	        var _a;
	        let buf;
	        if (this.options.use_base64) {
	            buf = Buffer.from(message.data ? message.data : message, 'base64');
	        }
	        else {
	            if ((_a = this.options) === null || _a === void 0 ? void 0 : _a.isSocketService) {
	                let realData = message;
	                buf = Buffer.from(new Uint8Array(realData));
	            }
	            else {
	                buf = Buffer.from(message.data ? message.data : message);
	            }
	        }
	        BGLog(exports.EBGLogLevel.Debug, `stark socketOnMessage be called: ${buf.byteLength}`);
	        this.bg_client.HandleSocketMsg(buf);
	        return;
	    }
	    ;
	    socketOnClose(event) {
	        BGLog(exports.EBGLogLevel.Info, "stark socketOnClose be called");
	        this.bg_client.HandleSocketClose();
	        this.wsIns = null;
	        return;
	    }
	    ;
	    socketOnError(event) {
	        let error_event = event;
	        let errno = -1;
	        if (error_event.error && error_event.error.errno) {
	            errno = error_event.error.errno;
	        }
	        BGLog(exports.EBGLogLevel.Warning, "stark socketOnError be called", errno, ", message", error_event.message);
	        this.bg_client.HandleSocketError(errno, error_event.message);
	        return;
	    }
	    ;
	} // export class StarkWS {

	let stringToUTF8;
	let lengthBytesUTF8;
	let UTF8ToString;
	let _malloc;
	let _free;
	let dynCall;
	let Module;
	function inject(wasm) {
	    stringToUTF8 = wasm.stringToUTF8;
	    lengthBytesUTF8 = wasm.lengthBytesUTF8;
	    UTF8ToString = wasm.UTF8ToString;
	    _malloc = wasm._malloc;
	    _free = wasm._free;
	    dynCall = wasm.dynCall;
	    Module = wasm.Module;
	}
	function strToPtr(str) {
	    const length = lengthBytesUTF8(str) + 1;
	    const ptr = _malloc(length);
	    stringToUTF8(str, ptr, length);
	    return ptr;
	}
	function strFromPtr(ptr) {
	    return UTF8ToString(ptr);
	}
	function u8ArrayToPtr(array, ptrOrNull) {
	    const length = array.byteLength;
	    const ptr = ptrOrNull || _malloc(length);
	    Module.HEAPU8.set(array, ptr);
	    return ptr;
	}
	function u8ArrayFromPtr(ptr, length, copy) {
	    const array = Module.HEAPU8.subarray(ptr, ptr + length);
	    if (copy) {
	        return array.slice();
	    }
	    return array;
	}
	function makeDynCaller(sig, ptr, args) {
	    return dynCall(sig, ptr, args);
	}
	function malloc(size) {
	    return _malloc(size);
	}
	function free(ptr) {
	    _free(ptr);
	}
	// memory growth 后 HEAPU8.buffer 会被替换/detach，必须在 malloc 之后再取，不得跨异步缓存
	function getHeapU8() {
	    return Module.HEAPU8;
	}
	const wasmUtils = {
	    strToPtr,
	    strFromPtr,
	    u8ArrayToPtr,
	    u8ArrayFromPtr,
	    makeDynCaller,
	    malloc,
	    free,
	    getHeapU8,
	    inject,
	};

	const DEFAULT_MESSAGE_DISPATCH_MODE = 0;
	// 与 C# 端 int.MaxValue 对齐：默认不限流、不设队列上限（仅当 VBridge/上层显式下发时才生效）。
	const INT32_MAX = 2147483647;
	const DEFAULT_DISPATCH_BUDGET_MESSAGES = INT32_MAX;
	const DEFAULT_DISPATCH_BUDGET_BYTES = INT32_MAX;
	const DEFAULT_QUEUE_HARD_LIMIT_MESSAGES = INT32_MAX;
	const DEFAULT_QUEUE_HARD_LIMIT_BYTES = INT32_MAX;
	const DISPATCH_FLAG_HAS_MORE = 1;
	const QUEUE_OVERFLOW_ERROR_CODE = -20001;
	// mode=2 常驻 batch buffer 相关配置。
	// useResidentBatchBuffer=true 时，batch 拼批复用一块常驻 WASM 内存，稳态每 tick 零 malloc/free；
	// 为 false 时回退到每 tick malloc+free 的旧路径（保留双路径用于灰度对比与兜底）。
	const DEFAULT_USE_RESIDENT_BATCH_BUFFER = false;
	// 常驻 buffer 的地板容量（连接存活期间的最小常驻字节数），可由 VBridge 下发覆盖。
	const DEFAULT_RESIDENT_BATCH_FLOOR_BYTES = 64 * 1024;
	// 扩容步进系数：不够用时按此系数累乘直到 >= 所需字节数，只 malloc 一次。
	const RESIDENT_BATCH_GROW_FACTOR = 1.5;
	// 缩容观察窗口（毫秒）：每满一个窗口评估一次是否回落容量。
	const RESIDENT_BATCH_SHRINK_WINDOW_MS = 10 * 1000;
	// 缩容松弛系数：当前容量 > 窗口峰值 * 此系数时才收缩，收缩目标同为 峰值 * 此系数。
	const RESIDENT_BATCH_SHRINK_SLACK = 1.5;
	class StarkNetUnity {
	    constructor() {
	        this._isConnecting = false;
	        this._isConnected = false;
	        this._onLoginSuccessCallback = null;
	        this._onLoginFailedCallback = null;
	        this._onCloseCallback = null;
	        this._onMessageCallback = null;
	        this._onMessageBatchCallback = null;
	        this._onDisconnectCallback = null;
	        this._messageDispatchMode = DEFAULT_MESSAGE_DISPATCH_MODE;
	        this._dispatchBudgetMessages = DEFAULT_DISPATCH_BUDGET_MESSAGES;
	        this._dispatchBudgetBytes = DEFAULT_DISPATCH_BUDGET_BYTES;
	        this._queueHardLimitMessages = DEFAULT_QUEUE_HARD_LIMIT_MESSAGES;
	        this._queueHardLimitBytes = DEFAULT_QUEUE_HARD_LIMIT_BYTES;
	        this._pendingMessages = [];
	        this._pendingBytes = 0;
	        this._isFlushing = false;
	        // 常驻 batch buffer 状态
	        this._useResidentBatchBuffer = DEFAULT_USE_RESIDENT_BATCH_BUFFER;
	        this._residentBatchFloorBytes = DEFAULT_RESIDENT_BATCH_FLOOR_BYTES;
	        this._batchScratchPtr = 0; // 常驻 WASM 线性内存指针，0 表示未分配
	        this._batchScratchCapacity = 0; // 当前常驻容量（字节）
	        this._batchScratchPeakSinceCheck = 0; // 本窗口内单 tick 实际 totalBytes 峰值
	        this._batchScratchWindowStartMs = 0; // 缩容窗口起点时间戳
	    }
	    makeAuthInfo(options) {
	        switch (options.authType) {
	            case AuthType.AUTH_CUSTOMIZED:
	                return new AuthInfoCustomized(options.customized_auth_data);
	            case AuthType.AUTH_NONE:
	                return new AuthInfoNone(options.openId);
	            default:
	                return new AuthInfoNone(options.openId);
	        }
	    }
	    open(options) {
	        console.log('[StarkNet] open');
	        this._isConnecting = false;
	        this._isConnected = false;
	        this._resetDispatchState();
	        this._onLoginSuccessCallback = typeof options.onLoginSuccess === 'function' ? options.onLoginSuccess : null;
	        this._onLoginFailedCallback = typeof options.onLoginFailed === 'function' ? options.onLoginFailed : null;
	        this._onCloseCallback = typeof options.onClose === 'function' ? options.onClose : null;
	        this._onMessageCallback = typeof options.onMessage === 'function' ? options.onMessage : null;
	        this._onMessageBatchCallback = typeof options.onMessageBatch === 'function' ? options.onMessageBatch : null;
	        this._onDisconnectCallback = typeof options.onDisconnect === 'function' ? options.onDisconnect : null;
	        this._messageDispatchMode = this._normalizePositiveInteger(options.messageDispatchMode, DEFAULT_MESSAGE_DISPATCH_MODE);
	        this._dispatchBudgetMessages = this._normalizePositiveInteger(options.dispatchBudgetMessages, DEFAULT_DISPATCH_BUDGET_MESSAGES);
	        this._dispatchBudgetBytes = this._normalizePositiveInteger(options.dispatchBudgetBytes, DEFAULT_DISPATCH_BUDGET_BYTES);
	        this._queueHardLimitMessages = this._normalizePositiveInteger(options.queueHardLimitMessages, DEFAULT_QUEUE_HARD_LIMIT_MESSAGES);
	        this._queueHardLimitBytes = this._normalizePositiveInteger(options.queueHardLimitBytes, DEFAULT_QUEUE_HARD_LIMIT_BYTES);
	        // useResidentBatchBuffer 以整型透传（1/0），非 0 即开启；缺省或非法值回落默认值（当前默认关闭）。
	        this._useResidentBatchBuffer = typeof options.useResidentBatchBuffer === 'number'
	            ? options.useResidentBatchBuffer !== 0
	            : DEFAULT_USE_RESIDENT_BATCH_BUFFER;
	        this._residentBatchFloorBytes = this._normalizePositiveInteger(options.residentBatchFloorBytes, DEFAULT_RESIDENT_BATCH_FLOOR_BYTES);
	        const serverUrl = 'wss://' + options.targetSvrList + '?proxy=' + options.proxyAppid;
	        this._client = new StarkWS({
	            url: serverUrl,
	            authInfo: this.makeAuthInfo(options),
	            gamesvr_insid: options.gamesvrInsid,
	            onopen: (uid, isresume) => {
	                console.log('[StarkNet] onopen', uid, isresume);
	                if (!this._isConnecting) {
	                    return;
	                }
	                this._isConnecting = false;
	                this._isConnected = true;
	                if (this._onLoginSuccessCallback) {
	                    this._onLoginSuccessCallback(isresume ? 1 : 0, uid);
	                }
	            },
	            onmessage: (arrayBuffer) => {
	                this._handleMessage(arrayBuffer);
	            },
	            onclose: () => {
	                console.log('[StarkNet] onclose');
	                this._isConnected = false;
	                if (this._isConnecting) {
	                    this._isConnecting = false;
	                    if (this._onLoginFailedCallback) {
	                        this._onLoginFailedCallback(0, -1, "");
	                    }
	                }
	                if (this._onCloseCallback) {
	                    this._onCloseCallback(0, "close");
	                }
	            },
	            onerror: (errCode, errMsg, extraInfo) => {
	                console.log('[StarkNet] onerror', errCode, errMsg, extraInfo);
	                if (this._onLoginFailedCallback) {
	                    this._onLoginFailedCallback(0, errCode, extraInfo);
	                }
	            }
	        });
	        this._isConnecting = true;
	        this._client.open();
	    }
	    tick() {
	        if (this._messageDispatchMode === 0 || this._pendingMessages.length <= 0 || this._isFlushing) {
	            return 0;
	        }
	        this._isFlushing = true;
	        try {
	            if (this._messageDispatchMode === 2 && this._onMessageBatchCallback) {
	                return this._flushBatchTick();
	            }
	            return this._flushMessageTick();
	        }
	        finally {
	            this._isFlushing = false;
	        }
	    }
	    close() {
	        console.log('[StarkNet] close');
	        this._client.close();
	    }
	    send(tagKey, tagVal, buffer) {
	        this._client.send(buffer, {
	            target: {
	                ins_type: tagKey,
	                ins_id: tagVal,
	            }
	        });
	    }
	    destroy() {
	        this._clearCallbacks();
	        this._freeBatchScratch();
	        if (this._isConnecting) {
	            this._client.close();
	        }
	        this._client.close();
	        console.log('[StarkNet] destroy');
	    }
	    _handleMessage(arrayBuffer) {
	        if (this._messageDispatchMode === 0) {
	            if (this._onMessageCallback) {
	                this._onMessageCallback(arrayBuffer);
	            }
	            return;
	        }
	        this._enqueueMessage(arrayBuffer);
	    }
	    _enqueueMessage(arrayBuffer) {
	        this._pendingMessages.push(arrayBuffer);
	        this._pendingBytes += arrayBuffer.byteLength;
	        if (this._pendingMessages.length > this._queueHardLimitMessages || this._pendingBytes > this._queueHardLimitBytes) {
	            console.error('[StarkNet] queue overflow', {
	                code: QUEUE_OVERFLOW_ERROR_CODE,
	                pendingMessages: this._pendingMessages.length,
	                pendingBytes: this._pendingBytes,
	            });
	            if (this._client) {
	                this._client.close();
	            }
	        }
	    }
	    _flushMessageTick() {
	        let dispatchedCount = 0;
	        while (this._pendingMessages.length > 0) {
	            const nextMessage = this._pendingMessages[0];
	            this._pendingMessages.shift();
	            this._pendingBytes -= nextMessage.byteLength;
	            dispatchedCount += 1;
	            if (this._onMessageCallback) {
	                this._onMessageCallback(nextMessage);
	            }
	        }
	        return dispatchedCount;
	    }
	    _flushBatchTick() {
	        const messages = this._takeMessagesForCurrentTick();
	        if (messages.length <= 0) {
	            return 0;
	        }
	        const hasMore = this._pendingMessages.length > 0;
	        const flags = hasMore ? DISPATCH_FLAG_HAS_MORE : 0;
	        // 拼批写进 WASM 线性内存后同步派发。整条 tick→回调→C# 解析链路全程同步，
	        // 回调返回时 native 侧已消费完，因此常驻 buffer 复用不会覆盖到仍在被读的数据。
	        const { ptr, totalBytes } = this._buildBatchBufferToWasm(messages, flags);
	        try {
	            if (this._onMessageBatchCallback) {
	                this._onMessageBatchCallback(ptr, totalBytes, messages.length, flags);
	            }
	        }
	        finally {
	            // 常驻路径：不 free，跨 tick 复用；旧路径：每 tick malloc 对应每 tick free。
	            if (!this._useResidentBatchBuffer) {
	                wasmUtils.free(ptr);
	            }
	        }
	        // 常驻路径按窗口评估是否回落容量（放在派发之后，不影响本 tick 的 ptr 有效性）。
	        if (this._useResidentBatchBuffer) {
	            this._maybeShrinkBatchScratch();
	        }
	        return messages.length;
	    }
	    _takeMessagesForCurrentTick() {
	        const selected = [];
	        let selectedBytes = 0;
	        while (this._pendingMessages.length > 0) {
	            const nextMessage = this._pendingMessages[0];
	            const hitsMessageBudget = selected.length >= this._dispatchBudgetMessages;
	            const hitsByteBudget = selectedBytes > 0 && selectedBytes + nextMessage.byteLength > this._dispatchBudgetBytes;
	            if (hitsMessageBudget || hitsByteBudget) {
	                break;
	            }
	            selected.push(nextMessage);
	            this._pendingMessages.shift();
	            this._pendingBytes -= nextMessage.byteLength;
	            selectedBytes += nextMessage.byteLength;
	        }
	        if (selected.length === 0 && this._pendingMessages.length > 0) {
	            const firstMessage = this._pendingMessages.shift();
	            this._pendingBytes -= firstMessage.byteLength;
	            selected.push(firstMessage);
	        }
	        return selected;
	    }
	    _buildBatchBufferToWasm(messages, flags) {
	        const headerBytes = 16;
	        const entryBytes = 8;
	        let payloadBytes = 0;
	        for (const message of messages) {
	            payloadBytes += message.byteLength;
	        }
	        const totalBytes = headerBytes + entryBytes * messages.length + payloadBytes;
	        let ptr;
	        if (this._useResidentBatchBuffer) {
	            // 常驻路径：复用/按需扩容常驻 buffer，并记录本窗口单 tick 峰值供缩容评估。
	            ptr = this._ensureBatchScratch(totalBytes);
	            if (totalBytes > this._batchScratchPeakSinceCheck) {
	                this._batchScratchPeakSinceCheck = totalBytes;
	            }
	        }
	        else {
	            // 旧路径：每 tick 精确分配 totalBytes，由 _flushBatchTick 在派发后 free。
	            ptr = wasmUtils.malloc(totalBytes);
	        }
	        // malloc/ensure 之后再取 HEAPU8：memory growth 时其 buffer 会被替换/detach，不得在分配前缓存
	        const heap = wasmUtils.getHeapU8();
	        const view = new DataView(heap.buffer, ptr, totalBytes);
	        let payloadOffset = headerBytes + entryBytes * messages.length;
	        view.setUint32(0, 1, true);
	        view.setUint32(4, messages.length, true);
	        view.setUint32(8, payloadBytes, true);
	        view.setUint32(12, flags, true);
	        for (let i = 0; i < messages.length; i++) {
	            const message = messages[i];
	            const entryOffset = headerBytes + i * entryBytes;
	            view.setUint32(entryOffset, payloadOffset, true);
	            view.setUint32(entryOffset + 4, message.byteLength, true);
	            heap.set(new Uint8Array(message), ptr + payloadOffset);
	            payloadOffset += message.byteLength;
	        }
	        return { ptr, totalBytes };
	    }
	    // 保证常驻 buffer 容量 >= 所需字节数；不够时按 GROW_FACTOR 累乘算出目标容量，只 malloc 一次。
	    // 单调增长：容量在连接存活期间不低于地板值 _residentBatchFloorBytes，缩容由窗口逻辑负责。
	    _ensureBatchScratch(requiredBytes) {
	        const floor = this._residentBatchFloorBytes;
	        if (this._batchScratchPtr && this._batchScratchCapacity >= requiredBytes) {
	            return this._batchScratchPtr; // 容量够，直接复用
	        }
	        // 从当前容量（或地板值）起纯算术累乘，直到 >= requiredBytes，得到最终目标容量。
	        let newCapacity = this._batchScratchCapacity > 0 ? this._batchScratchCapacity : floor;
	        if (newCapacity < floor) {
	            newCapacity = floor;
	        }
	        while (newCapacity < requiredBytes) {
	            newCapacity = Math.ceil(newCapacity * RESIDENT_BATCH_GROW_FACTOR);
	        }
	        // 先释放旧块再分配新块：扩容为低频事件，避免新旧两块并存抬高瞬时内存峰值。
	        if (this._batchScratchPtr) {
	            wasmUtils.free(this._batchScratchPtr);
	            this._batchScratchPtr = 0;
	            this._batchScratchCapacity = 0;
	        }
	        const newPtr = wasmUtils.malloc(newCapacity);
	        if (!newPtr) {
	            // 分配失败：保持归零状态，下个 tick 重建，状态自洽。
	            throw new Error('[StarkNet] resident batch scratch malloc failed, size=' + newCapacity);
	        }
	        this._batchScratchPtr = newPtr;
	        this._batchScratchCapacity = newCapacity;
	        return newPtr;
	    }
	    // 每满一个观察窗口评估一次容量回落：目标 = max(窗口峰值 * SLACK, 地板值)。
	    // 仅当当前容量明显偏大（> 峰值 * SLACK 且 > 目标）时才收缩，收缩同样先释放再分配更小块。
	    _maybeShrinkBatchScratch() {
	        const now = (typeof performance !== 'undefined' && performance.now)
	            ? performance.now() : Date.now();
	        if (this._batchScratchWindowStartMs === 0) {
	            this._batchScratchWindowStartMs = now;
	            return;
	        }
	        if (now - this._batchScratchWindowStartMs < RESIDENT_BATCH_SHRINK_WINDOW_MS) {
	            return;
	        }
	        const floor = this._residentBatchFloorBytes;
	        const peak = this._batchScratchPeakSinceCheck;
	        // 窗口完全没收包时 peak=0，目标自然落到地板值；有收包时收敛到 峰值 * SLACK。
	        const target = Math.max(Math.ceil(peak * RESIDENT_BATCH_SHRINK_SLACK), floor);
	        if (this._batchScratchPtr
	            && this._batchScratchCapacity > Math.ceil(peak * RESIDENT_BATCH_SHRINK_SLACK)
	            && this._batchScratchCapacity > target) {
	            wasmUtils.free(this._batchScratchPtr);
	            const newPtr = wasmUtils.malloc(target);
	            if (newPtr) {
	                this._batchScratchPtr = newPtr;
	                this._batchScratchCapacity = target;
	            }
	            else {
	                // 收缩时分配失败：归零，下个 tick 由 _ensureBatchScratch 从地板值重建。
	                this._batchScratchPtr = 0;
	                this._batchScratchCapacity = 0;
	            }
	        }
	        this._batchScratchPeakSinceCheck = 0;
	        this._batchScratchWindowStartMs = now;
	    }
	    // 连接销毁时释放常驻 buffer，避免常驻内存泄漏。
	    _freeBatchScratch() {
	        if (this._batchScratchPtr) {
	            wasmUtils.free(this._batchScratchPtr);
	        }
	        this._batchScratchPtr = 0;
	        this._batchScratchCapacity = 0;
	        this._batchScratchPeakSinceCheck = 0;
	        this._batchScratchWindowStartMs = 0;
	    }
	    _normalizePositiveInteger(value, fallback) {
	        if (typeof value !== 'number' || !Number.isFinite(value)) {
	            return fallback;
	        }
	        const normalized = Math.floor(value);
	        return normalized > 0 ? normalized : fallback;
	    }
	    _resetDispatchState() {
	        this._pendingMessages = [];
	        this._pendingBytes = 0;
	        this._isFlushing = false;
	    }
	    _clearCallbacks() {
	        this._onCloseCallback = null;
	        this._onMessageCallback = null;
	        this._onMessageBatchCallback = null;
	        this._onDisconnectCallback = null;
	        this._onLoginSuccessCallback = null;
	        this._onLoginFailedCallback = null;
	        this._resetDispatchState();
	    }
	}

	const _handles = (function () {
	    const _pool = {};
	    let _nextId = 1;
	    function register(obj) {
	        const id = _nextId++;
	        _pool[id] = obj;
	        return id;
	    }
	    function unregister(id) {
	        delete _pool[id];
	    }
	    function fetch(id) {
	        return _pool[id];
	    }
	    return {
	        register: register,
	        unregister: unregister,
	        fetch: fetch,
	    };
	})();
	function init(wasm) {
	    wasmUtils.inject(wasm);
	}
	function objectCreate() {
	    const id = _handles.register({});
	    console.log('[StarkNetLib] objectCreate', id);
	    return id;
	}
	function objectDestroy(handle) {
	    const obj = _handles.fetch(handle);
	    if (obj) {
	        console.log('[StarkNetLib] objectDestroy', handle);
	        _handles.unregister(handle);
	    }
	}
	function objectGetNumberValue(handle, key) {
	    const obj = _handles.fetch(handle);
	    if (obj) {
	        const keyStr = wasmUtils.strFromPtr(key);
	        const value = obj[keyStr];
	        if (typeof value === 'number') {
	            return value;
	        }
	    }
	    return 0;
	}
	function objectSetNumberValue(handle, key, valuel, valueh) {
	    const obj = _handles.fetch(handle);
	    if (obj) {
	        const keyStr = wasmUtils.strFromPtr(key);
	        if (valueh === undefined || valueh === 0) {
	            obj[keyStr] = valuel;
	            return;
	        }
	        // 将两个 32 位部分组合成 64 位数值
	        const value = ((valueh >>> 0) * 0x100000000) + (valuel >>> 0);
	        console.log('[StarkNetLib] objectSetValue', handle, keyStr, value);
	        obj[keyStr] = value;
	    }
	}
	function objectDelValue(handle, key) {
	    const obj = _handles.fetch(handle);
	    if (obj) {
	        const keyStr = wasmUtils.strFromPtr(key);
	        console.log('[StarkNetLib] objectDelValue', handle, keyStr);
	        delete obj[keyStr];
	    }
	}
	function objectGetStringValue(handle, key) {
	    const obj = _handles.fetch(handle);
	    if (obj) {
	        const keyStr = wasmUtils.strFromPtr(key);
	        const value = obj[keyStr];
	        if (typeof value === 'string') {
	            const ptr = wasmUtils.strToPtr(value);
	            try {
	                return ptr;
	            }
	            finally {
	                // csharp is using return type as IntPtr, free it here
	                wasmUtils.free(ptr);
	            }
	        }
	    }
	    return 0;
	}
	function objectSetStringValue(handle, key, value) {
	    const obj = _handles.fetch(handle);
	    if (obj) {
	        const keyStr = wasmUtils.strFromPtr(key);
	        const valueStr = wasmUtils.strFromPtr(value);
	        console.log('[StarkNetLib] objectSetValue', handle, keyStr, valueStr);
	        obj[keyStr] = valueStr;
	    }
	}
	function socketSend(handle, tagKey, tagVal, dataPtr, length) {
	    const inst = _handles.fetch(handle);
	    if (inst) {
	        const array = wasmUtils.u8ArrayFromPtr(dataPtr, length, true);
	        inst.send(tagKey, tagVal, array.buffer);
	    }
	}
	function socketTick(handle) {
	    const inst = _handles.fetch(handle);
	    if (inst && typeof inst.tick === 'function') {
	        return inst.tick();
	    }
	    return 0;
	}
	function _makeStarkNetOptions(handle, obj) {
	    const starkNetOptions = {};
	    starkNetOptions.openId = obj.openId || '';
	    starkNetOptions.customized_auth_data = obj.customized_auth_data || '';
	    starkNetOptions.authType = obj.authType || AuthType.AUTH_NONE;
	    starkNetOptions.gamesvrInsid = obj.gamesvrInsid || 0;
	    starkNetOptions.targetSvrList = obj.targetSvrList || '';
	    starkNetOptions.proxyAppid = obj.proxyAppid || '';
	    if (obj.onLoginSuccess && typeof obj.onLoginSuccess === 'number') {
	        const ptr = obj.onLoginSuccess;
	        starkNetOptions.onLoginSuccess = function (mode, starkUid) {
	            wasmUtils.makeDynCaller('viii', ptr, [handle, mode, starkUid]);
	        };
	    }
	    if (obj.onLoginFailed && typeof obj.onLoginFailed === 'number') {
	        const ptr = obj.onLoginFailed;
	        starkNetOptions.onLoginFailed = function (mode, errCode, errMsg) {
	            const errMsgPtr = wasmUtils.strToPtr(errMsg);
	            try {
	                wasmUtils.makeDynCaller('viiii', ptr, [handle, mode, errCode, errMsgPtr]);
	            }
	            finally {
	                wasmUtils.free(errMsgPtr);
	            }
	        };
	    }
	    if (obj.onMessage && typeof obj.onMessage === 'number') {
	        const ptr = obj.onMessage;
	        starkNetOptions.onMessage = function (arrayBuffer) {
	            const dataPtr = wasmUtils.u8ArrayToPtr(new Uint8Array(arrayBuffer), null);
	            try {
	                wasmUtils.makeDynCaller('viii', ptr, [handle, dataPtr, arrayBuffer.byteLength]);
	            }
	            finally {
	                wasmUtils.free(dataPtr);
	            }
	        };
	    }
	    if (obj.onMessageBatch && typeof obj.onMessageBatch === 'number') {
	        const cbPtr = obj.onMessageBatch;
	        // 释放责任已上移到 StarkNetUnity._flushBatchTick：拼批方 malloc，回调返回后立即 free。
	        // 此处直接透传 native ptr，省掉 onMessage 路径那次 u8ArrayToPtr 整批拷贝。
	        starkNetOptions.onMessageBatch = function (ptr, length, messageCount, flags) {
	            wasmUtils.makeDynCaller('viiiii', cbPtr, [handle, ptr, length, messageCount, flags]);
	        };
	    }
	    if (obj.onClose && typeof obj.onClose === 'number') {
	        const ptr = obj.onClose;
	        starkNetOptions.onClose = function (reason) {
	            wasmUtils.makeDynCaller('vii', ptr, [handle, reason]);
	        };
	    }
	    if (obj.onDisconnect && typeof obj.onDisconnect === 'number') {
	        const ptr = obj.onDisconnect;
	        starkNetOptions.onDisconnect = function () {
	            wasmUtils.makeDynCaller('vi', ptr, [handle]);
	        };
	    }
	    starkNetOptions.messageDispatchMode = obj.messageDispatchMode;
	    starkNetOptions.dispatchBudgetMessages = obj.dispatchBudgetMessages;
	    starkNetOptions.dispatchBudgetBytes = obj.dispatchBudgetBytes;
	    starkNetOptions.queueHardLimitMessages = obj.queueHardLimitMessages;
	    starkNetOptions.queueHardLimitBytes = obj.queueHardLimitBytes;
	    starkNetOptions.useResidentBatchBuffer = obj.useResidentBatchBuffer;
	    starkNetOptions.residentBatchFloorBytes = obj.residentBatchFloorBytes;
	    return starkNetOptions;
	}
	function socketStart(optionsHandle) {
	    const obj = _handles.fetch(optionsHandle);
	    console.log('[StarkNetLib] socketStart', optionsHandle, JSON.stringify(obj));
	    if (obj) {
	        const inst = new StarkNetUnity();
	        let handle = _handles.register(inst);
	        const options = _makeStarkNetOptions(handle, obj);
	        inst.open(options);
	        return handle;
	    }
	    return 0;
	}
	function socketDestroy(handle) {
	    const inst = _handles.fetch(handle);
	    console.log('[StarkNetLib] socketDestroy', handle);
	    if (inst) {
	        _handles.unregister(handle);
	        inst.destroy();
	    }
	}
	function socketClose(handle) {
	    const inst = _handles.fetch(handle);
	    console.log('[StarkNetLib] socketClose', handle);
	    if (inst) {
	        inst.close();
	    }
	}
	window.starkNetLib = {
	    init,
	    objectCreate,
	    objectDestroy,
	    objectDelValue,
	    objectGetNumberValue,
	    objectSetNumberValue,
	    objectGetStringValue,
	    objectSetStringValue,
	    socketStart,
	    socketDestroy,
	    socketClose,
	    socketSend,
	    socketTick,
	};

	exports.SetLogFunc = SetLogFunc;
	exports.StarkAuthInfo = StarkAuthInfo;
	exports.StarkError = StarkError;
	exports.StarkWS = StarkWS;

}));
