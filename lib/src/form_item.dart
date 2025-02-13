import 'dart:async';

import 'package:flutter/widgets.dart';

import '../power_form.dart';

/// A form item that can be used to build form fields.
class PowerFormItem<T> extends StatefulWidget {
  /// The name of the form item, corresponds to the field name in the data.
  final String name;
  final Widget Function(T? value, ValueChanged<T> onChanged, FormItemBuilderExtraArgs) builder;

  /// A validator function that can be used to validate the field.
  final PowerFormFieldValidatorCallback<T>? validator;

  /// A widget that can be used to display the error message.
  final Widget Function(String? error)? errorWidget;

  /// If true, the form item will rebuild when the form data is changed.
  /// Default is true.
  /// It can be set to false if the form item contains a self-managed widget, e.g. a TextField.
  final bool rebuildOnChanged;

  const PowerFormItem({
    super.key,
    required this.name,
    this.validator,
    required this.builder,
    this.errorWidget,
    this.rebuildOnChanged = true,
  });

  @override
  State<PowerFormItem> createState() => PowerFormItemState<T>();
}

class PowerFormItemState<T> extends State<PowerFormItem<T>> {
  PowerFormState? formState;
  @override
  void dispose() {
    formState?.removeFormItemState(widget.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    formState ??= PowerForm.of(context)..addFormItemState(this);

    final value = formState!.getFieldValue<T>(widget.name);
    final error = formState!.getError(widget.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.builder(
          value,
          didChange,
          FormItemBuilderExtraArgs(
            formState: formState!,
            hasError: error != null,
          ),
        ),
        if (!formState!.widget.hideError && error != null)
          _FormHelperError(
            errorText: error,
            errorWidget: widget.errorWidget,
          ),
      ],
    );
  }

  void didChange(T value) {
    final formState = PowerForm.of(context);
    formState.setFieldValue(widget.name, value);
  }

  void rebuild() {
    if (mounted) setState(() {});
  }

  FutureOr<String?>? validate(T? value) {
    return widget.validator?.call(value);
  }
}

class FormItemBuilderExtraArgs {
  final PowerFormState formState;
  final bool hasError;

  FormItemBuilderExtraArgs({
    required this.formState,
    required this.hasError,
  });
}

class _FormHelperError extends StatelessWidget {
  final String errorText;
  final Widget Function(String error)? errorWidget;

  const _FormHelperError({
    required this.errorText,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return (errorWidget ?? PowerForm.errorWidgetBuilder ?? defaultErrorWidget)(errorText);
  }
}
