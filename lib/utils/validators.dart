// File: lib/utils/validators.dart

class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMinLength(String? value, String fieldName, int minLength) {
    final requiredCheck = validateRequired(value, fieldName);
    if (requiredCheck != null) return requiredCheck;

    if (value!.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    final requiredCheck = validateRequired(value, fieldName);
    if (requiredCheck != null) return requiredCheck;

    final number = double.tryParse(value!.trim());
    if (number == null) {
      return 'Please enter a valid number for $fieldName';
    }
    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }
    return null;
  }

  static String? validateNonNegativeInteger(String? value, String fieldName) {
    final requiredCheck = validateRequired(value, fieldName);
    if (requiredCheck != null) return requiredCheck;

    final number = int.tryParse(value!.trim());
    if (number == null) {
      return 'Please enter a valid whole number for $fieldName';
    }
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final requiredCheck = validateRequired(value, 'Email');
    if (requiredCheck != null) return requiredCheck;

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&'
      r"'"
      r'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    );

    if (!emailRegExp.hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    return validateMinLength(value, 'Password', 6);
  }
}
 