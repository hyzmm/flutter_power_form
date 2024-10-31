import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ms_map_utils/ms_map_utils.dart';
import 'package:power_form/src/form_item.dart';

/// A form widget that holds the state of the form.
class PowerForm extends StatefulWidget {
  static Function(String error)? errorWidgetBuilder;

  static PowerFormState of(BuildContext context) {
    final result = context.findAncestorStateOfType<PowerFormState>();
    if (result == null) {
      throw Exception('PowerFormState not found, please make sure PowerForm is in the widget tree');
    }
    return result;
  }

  static PowerFormState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<PowerFormState>();
  }

  final Widget child;
  final Map<String, dynamic>? initialValues;
  final ValidateMode validateMode;
  final void Function(String fieldName, Object? value)? onChanged;
  final VoidCallback? onReset;
  final Widget Function(String error)? errorWidget;

  /// If true, the error state will be hidden. It's useful when you don't want
  /// to show the error message but still want to validate the form.
  /// You can get the error state by calling [PowerFormState.getError].
  final bool hideError;

  const PowerForm({
    super.key,
    this.initialValues,
    required this.child,
    this.onChanged,
    this.onReset,
    this.validateMode = ValidateMode.onChange,
    this.errorWidget = defaultErrorWidget,
    this.hideError = false,
  });

  @override
  State<PowerForm> createState() => PowerFormState();
}

class PowerFormState extends State<PowerForm> {
  late Map<String, dynamic> values = {};
  late Map<String, dynamic> resetValues = {};
  final Map<String, PowerFormItemState<dynamic>> formItemStates = {};
  final StreamController<bool> _dataChanged = StreamController.broadcast();
  final _errors = <String, String>{};
  final Map<String, _FormValueRetrieverState> _valueRetrievers = {};

  // Whether the form data is valid.
  final ValueNotifier<bool> dataValid = ValueNotifier(false);

  /// A stream that emits true when the form data is changed(not user interacted).
  /// This stream can be used to enable/disable the submit button.
  Stream<bool> get dataChanged => _dataChanged.stream;

  // A flag to make sure all validators are triggered once to make the [dataValid] and [dataChanged] work correctly.
  bool triggerAllValidatorOnce = false;

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
    dataValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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

    if (!widget.hideError) {
      final Set<String> keys = {..._errors.keys, ...oldErrors.keys};
      for (final key in keys) {
        if (_errors[key] != oldErrors[key]) {
          formItemStates[key]!.rebuild();
        }
      }
    }

    dataValid.value = _errors.isEmpty;
    return _errors.isEmpty;
  }

  T? getFieldValue<T>(String fieldName) {
    return values[fieldName] as T?;
  }

  void setFieldValue<T>(String fieldName, T? value) {
    values[fieldName] = value as Object?;

    widget.onChanged?.call(fieldName, value);
    _dataChanged.add(!const DeepCollectionEquality().equals(values, resetValues));
    formItemStates[fieldName]?.rebuild();
    _valueRetrievers[fieldName]?.setState(() {});
    if (widget.validateMode == ValidateMode.onChange) {
      if (triggerAllValidatorOnce) {
        validate([fieldName]);
      } else {
        validate();
        triggerAllValidatorOnce = true;
      }
    }
  }

  void addFormItemState(PowerFormItemState formItemState) {
    formItemStates[formItemState.widget.name] = formItemState;
  }

  void removeFormItemState(String name) {
    formItemStates.remove(name);
  }

  void _addValueRetriever(_FormValueRetrieverState valueRetriever) {
    _valueRetrievers[valueRetriever.widget.fieldName] = valueRetriever;
  }

  void _removeValueRetriever(String fieldName) {
    _valueRetrievers.remove(fieldName);
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

  void clearErrors() {
    final errorKeys = _errors.keys.toList();
    _errors.clear();
    for (final key in errorKeys) {
      formItemStates[key]!.rebuild();
    }
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

Widget defaultErrorWidget(String error) {
  return Text(error, style: const TextStyle(color: Colors.red));
}

/// A widget that rebuilds when the form data is changed & valid.
/// This widget can be used to enable/disable the save button.
class FormChange extends StatefulWidget {
  final Widget? child;
  final ValueWidgetBuilder<bool> builder;

  const FormChange({
    super.key,
    this.child,
    required this.builder,
  });

  @override
  State<FormChange> createState() => _FormChangeState();
}

class _FormChangeState extends State<FormChange> {
  @override
  Widget build(BuildContext context) {
    final formState = PowerForm.of(context);
    return FormValidity(builder: (context, valid, _) {
      return StreamBuilder<bool>(
        stream: formState.dataChanged,
        builder: (context, snapshot) {
          return widget.builder(context, valid && (snapshot.data ?? false), widget.child);
        },
      );
    });
  }
}

class FormValidity extends StatelessWidget {
  final Widget? child;
  final ValueWidgetBuilder<bool> builder;

  const FormValidity({
    super.key,
    this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final formState = PowerForm.of(context);
    return ValueListenableBuilder(
      valueListenable: formState.dataValid,
      child: child,
      builder: (context, value, child) {
        return builder(context, value, child);
      },
    );
  }
}

/// A widget that retrieves the value of a form field.
class FormValueRetriever<T> extends StatefulWidget {
  final String fieldName;
  final Widget Function(BuildContext, T?) builder;

  const FormValueRetriever({
    super.key,
    required this.fieldName,
    required this.builder,
  });

  @override
  State<FormValueRetriever<T>> createState() => _FormValueRetrieverState<T>();
}

class _FormValueRetrieverState<T> extends State<FormValueRetriever<T>> {
  @override
  Widget build(BuildContext context) {
    final formState = PowerForm.of(context);
    formState._addValueRetriever(this);

    return widget.builder(context, formState.getFieldValue<T>(widget.fieldName));
  }

  @override
  void deactivate() {
    PowerForm.of(context)._removeValueRetriever(widget.fieldName);
    super.deactivate();
  }
}
