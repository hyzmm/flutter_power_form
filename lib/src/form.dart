import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ms_map_utils/ms_map_utils.dart';
import 'package:power_form/src/form_item.dart';

/// A form widget that holds the state of the form.
class PowerForm extends StatefulWidget {
  final Widget child;
  final Map<String, Object>? initialValues;
  final ValidateMode validateMode;
  final void Function(String fieldName, Object value)? onChanged;
  final VoidCallback? onReset;
  final Widget Function(String? error)? errorWidget;

  const PowerForm({
    super.key,
    this.initialValues,
    required this.child,
    this.onChanged,
    this.onReset,
    this.validateMode = ValidateMode.manual,
    this.errorWidget = defaultErrorWidget,
  });

  @override
  State<PowerForm> createState() => PowerFormState();
}

class PowerFormState extends State<PowerForm> {
  final Map<String, dynamic> values = {};
  final Map<String, dynamic> resetValues = {};
  final Map<String, PowerFormItemState<dynamic>> formItemStates = {};
  final StreamController<bool> _dataChanged = StreamController.broadcast();
  final _errors = <String, String>{};

  /// A stream that emits true when the form data is changed(not user interacted).
  /// This stream can be used to enable/disable the submit button.
  Stream<bool> get dataChanged => _dataChanged.stream;

  String? getError(String fieldName) => _errors[fieldName];

  @override
  void initState() {
    resetValues
      ..clear()
      ..addAll(widget.initialValues ?? {});
    values
      ..clear()
      ..addAll(resetValues);
    super.initState();
  }

  @override
  void dispose() {
    _dataChanged.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormScope(state: this, child: widget.child);
  }

  /// Validates the form
  /// [fields] is a list of field names to validate, if not provided, all fields will be validated.
  Future<bool> validate([List<String>? fields]) async {
    final oldErrors = Map.from(_errors);

    for (final formItemState in formItemStates.values) {
      if (fields != null && !fields.contains(formItemState.widget.name)) {
        continue;
      }

      final fieldName = formItemState.widget.name;
      final fieldValue = values[fieldName];
      switch (formItemState.validate(fieldValue)) {
        case String message:
          _errors[fieldName] = message;
        case Future<String?> future:
          final value = await future;
          if (value != null) {
            _errors[fieldName] = value;
          } else {
            _errors.remove(fieldName);
          }
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
    _dataChanged
        .add(!const DeepCollectionEquality().equals(values, resetValues));
    formItemStates[fieldName]?.rebuild();
    if (widget.validateMode == ValidateMode.onChange) {
      validate([fieldName]);
    }
  }

  void addFormItemState(PowerFormItemState formItemState) {
    formItemStates[formItemState.widget.name] = formItemState;
  }

  void removeFormItemState(String name) {
    formItemStates.remove(name);
  }

  void save() {
    resetValues.clear();
    resetValues.addAll(values);
    _dataChanged.add(false);
  }

  void reset() {
    values.clear();
    values.addAll(resetValues);
    _dataChanged.add(false);
    for (final formItemState in formItemStates.values) {
      formItemState.rebuild();
    }
    widget.onReset?.call();
  }

  Map<String, dynamic> getPatchValues() {
    return diff(resetValues, values).cast();
  }
}

enum ValidateMode {
  /// Call [PowerFormState.validate] manually to validate.
  manual,

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

/// A widget that rebuilds when the form data is changed.
class FormDataChanged extends StatefulWidget {
  final Widget? child;
  final ValueWidgetBuilder<bool> builder;

  const FormDataChanged({
    super.key,
    this.child,
    required this.builder,
  });

  @override
  State<FormDataChanged> createState() => _FormDataChangedState();
}

class _FormDataChangedState extends State<FormDataChanged> {
  @override
  Widget build(BuildContext context) {
    final formScope = FormScope.of(context);
    return StreamBuilder<bool>(
      stream: formScope.state.dataChanged,
      builder: (context, snapshot) {
        return widget.builder(context, snapshot.data ?? false, widget.child);
      },
    );
  }
}
