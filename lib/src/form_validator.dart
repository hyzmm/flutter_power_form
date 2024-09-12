import 'dart:async';

/// Signature for a function that validates a form field.
/// Returns a string to use as an error message if the input is invalid, or null otherwise.
typedef PowerFormFieldValidatorCallback<T> = FutureOr<String?> Function(
    T? value);

/// A utility class that provides common form validators.
class PowerFormFieldValidator {
  PowerFormFieldValidator._();

  /// Composes multiple validators into a single validator.
  static PowerFormFieldValidatorCallback compose<T>(
      List<PowerFormFieldValidatorCallback<T>> validators) {
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

  static PowerFormFieldValidatorCallback<Object?> required(String message) {
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

  static PowerFormFieldValidatorCallback<String?> minLength(
      int length, String message) {
    return (value) {
      if ((value?.length ?? 0) < length) {
        return message;
      }
      return null;
    };
  }

  static PowerFormFieldValidatorCallback<String?> maxLength(
      int length, String message) {
    return (value) {
      if ((value?.length ?? 0) > length) {
        return message;
      }
      return null;
    };
  }

  static PowerFormFieldValidatorCallback<String?> email(String message) {
    return (value) {
      if (value == null) {
        return message;
      }
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }

  static PowerFormFieldValidatorCallback<String?> pattern(
      RegExp regex, String message) {
    return (value) {
      if (value == null) {
        return message;
      }
      if (!regex.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }
}
