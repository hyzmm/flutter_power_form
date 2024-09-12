import 'dart:async';

/// Signature for a function that validates a form field.
/// Returns a string to use as an error message if the input is invalid, or null otherwise.
typedef PowerFormFieldValidator<T> = FutureOr<String?> Function(T value);

/// A utility class that provides common form validators.
class PowerFormFieldValidatorPresets {
  PowerFormFieldValidatorPresets._();

  /// Composes multiple validators into a single validator.
  static PowerFormFieldValidator<String> compose(
      List<PowerFormFieldValidator<String>> validators) {
    return (value) async {
      for (final validator in validators) {
        final message = await validator(value);
        if (message != null) {
          return message;
        }
      }
      return null;
    };
  }

  static PowerFormFieldValidator<Object?> required(String message) {
    return (value) {
      switch (value) {
        case String stringValue:
          if (stringValue.isEmpty) {
            return message;
          }
        case bool boolValue:
          if (!boolValue) {
            return message;
          }
        default:
          if (value == null) {
            return message;
          }
      }
      return null;
    };
  }

  static PowerFormFieldValidator<String> minLength(int length, String message) {
    return (value) {
      if (value.length < length) {
        return message;
      }
      return null;
    };
  }

  static PowerFormFieldValidator<String> maxLength(int length, String message) {
    return (value) {
      if (value.length > length) {
        return message;
      }
      return null;
    };
  }

  static PowerFormFieldValidator<String> email(String message) {
    return (value) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }

  static PowerFormFieldValidator<String> pattern(RegExp regex, String message) {
    return (value) {
      if (!regex.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }
}
