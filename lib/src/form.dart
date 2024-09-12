import 'package:flutter/material.dart';
import 'package:power_form/src/form_item.dart';

/// A form widget that holds the state of the form.
class PowerForm extends StatefulWidget {
  final Widget child;
  final ValidateMode validateMode;
  final void Function(String fieldName, Object value)? onChanged;
  final Widget Function(String? error)? errorWidget;

  const PowerForm({
    super.key,
    required this.child,
    this.onChanged,
    this.validateMode = ValidateMode.onChange,
    this.errorWidget = defaultErrorWidget,
  });

  @override
  State<PowerForm> createState() => PowerFormState();
}

class PowerFormState extends State<PowerForm> {
  final Map<String, Object> values = {};
  final Map<String, FormItemState> formItemStates = {};

  final _errors = <String, String>{};

  String? getError(String fieldName) => _errors[fieldName];

  @override
  Widget build(BuildContext context) {
    return FormScope(state: this, child: widget.child);
  }

  /// Validates the form
  /// [fields] is a list of field names to validate, if not provided, all fields will be validated.
  bool validate([List<String>? fields]) {
    final oldErrors = Map.from(_errors);

    for (final formItemState in formItemStates.values) {
      if (fields != null && !fields.contains(formItemState.widget.name)) {
        continue;
      }

      final fieldName = formItemState.widget.name;
      final fieldValue = values[fieldName];
      switch (formItemState.widget.validator?.call(fieldValue)) {
        case String message:
          _errors[fieldName] = message;
        case Future<String?> message:
          message.then((value) {
            if (value != null) {
              _errors[fieldName] = value;
            } else {
              _errors.remove(fieldName);
            }
          });
        case null:
          _errors.remove(fieldName);
      }
    }

    final Set<String> keys = {..._errors.keys, ...oldErrors.keys};
    for (final key in keys) {
      if (_errors[key] != oldErrors[key]) {
        formItemStates[key]!.rebuild();
      }
    }

    return _errors.isEmpty;
  }

  T? getFieldValue<T>(String fieldName) {
    return values[fieldName] as T?;
  }

  void setFieldValue<T>(String fieldName, T value) {
    values[fieldName] = value as Object;
    widget.onChanged?.call(fieldName, value);
    if (widget.validateMode == ValidateMode.onChange) {
      validate([fieldName]);
    }
  }

  void addFormItemState(FormItemState formItemState) {
    formItemStates[formItemState.widget.name] = formItemState;
  }

  void removeFormItemState(String name) {
    formItemStates.remove(name);
  }
}

enum ValidateMode {
  /// Do not auto validate the form, your app should call [PowerFormState.validate] manually.
  none,

  /// Validate the form when the form is changed.
  onChange,
}

class FormScope extends InheritedWidget {
  final PowerFormState state;

  const FormScope({super.key, required super.child, required this.state});

  T? getFieldValue<T>(String fieldName) {
    return state.getFieldValue(fieldName);
  }

  void setFieldValue<T>(String fieldName, T value) {
    state.setFieldValue(fieldName, value);
  }

  @override
  bool updateShouldNotify(FormScope oldWidget) {
    return state != oldWidget.state;
  }

  static FormScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FormScope>();
  }

  static FormScope of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<FormScope>();
    if (result == null) {
      throw Exception(
          'FormContext not found, please make sure PowerForm is in the widget tree');
    }
    return result;
  }
}

Widget defaultErrorWidget(String? error) {
  if (error == null) {
    return const SizedBox.shrink();
  }
  return Text(error, style: const TextStyle(color: Colors.red));
}
