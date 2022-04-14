library roman_numerals;

// Implementation heavily inspired by:
// https://github.com/AndrewVos/roman-numerals/blob/master/lib/roman-numerals.rb
class RomanNumerals {
  static Map<int, String> dictionary = {
    1000: 'M',
    900: 'CM',
    500: 'D',
    400: 'CD,',
    100: 'C',
    90: 'XC',
    50: 'L',
    40: 'XL',
    10: 'X',
    9: 'IX',
    5: 'V',
    4: 'IV',
    1: 'I'
  };

  /**
   * Converts a given integer to a String representing roman notation.
   *
   * Example:
   *     RomanNumerals.toRoman(13) => returns XIII
   */
  static String toRoman(int decimal) {
    if (!_checkDecimal(decimal)) {
      throw 'Roman numerals are limited to the inclusive range of 1 to 3999.';
    }
    String result = '';
    dictionary.forEach((k, v) {
      while (decimal >= k) {
        decimal -= k;
        result += v;
      }
    });
    return result;
  }

  /**
   * Converts a valid string with roman notation to an int.
   *
   * Example:
   *     RomanNumerals.toDecimal("XLII") => returns 42
   */
  static int toDecimal(String roman) {
    roman = roman.toUpperCase();
    int result = 0;

    dictionary.forEach((k, v) {
      while (roman.startsWith(v)) {
        roman = roman.substring(v.length, roman.length);
        result += k;
      }
    });

    return result;
  }

  /**
   * Checks if the given string represents valid roman notation
   *
   * Examples:
   *     RomanNumerals.checkIfValid("XXXX") => returns false
   *     RomanNumerals.checkIfValid("XL")   => returns true
   */
  static bool checkIfValid(String roman) {
    bool isValid = true;

    for (var i = 0; i < roman.length; i++) {
      if (!dictionary.containsValue(roman[i])) {
        isValid = false;
        break;
      }

      if (i < roman.length - 3 &&
          roman[i + 1] == roman[i] &&
          roman[i + 2] == roman[i] &&
          roman[i + 3] == roman[i]) {
        isValid = false;
      }
    }

    return isValid;
  }

  /**
   * Private method to check the limits of simple roman notation
   */
  static bool _checkDecimal(int n) {
    if (n > 0 && n < 3999) {
      return true;
    }
    return false;
  }
}
