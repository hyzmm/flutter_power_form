import 'package:flutter/widgets.dart';

import '../power_form.dart';
import 'form.dart';

/// A form item that can be used to build form fields.
class FormItem<T> extends StatefulWidget {
  /// The name of the form item, corresponds to the field name in the data.
  final String name;
  final Widget Function(
      T? value, ValueChanged<T> onChanged, FormItemBuilderExtraArgs) builder;
  final PowerFormFieldValidator<T>? validator;
  final Widget Function(String? error)? errorWidget;

  const FormItem({
    super.key,
    required this.name,
    this.validator,
    required this.builder,
    this.errorWidget,
  });

  @override
  State<FormItem> createState() => FormItemState<T>();
}

class FormItemState<T> extends State<FormItem<T>> {
  @override
  void deactivate() {
    final formContext = FormScope.of(context);
    formContext.state.removeFormItemState(widget.name);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final formContext = FormScope.of(context);
    formContext.state.addFormItemState(this);

    final value = formContext.getFieldValue<T>(widget.name);
    final error = formContext.state.getError(widget.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.builder(
          value,
          didChange,
          FormItemBuilderExtraArgs(
            formState: formContext.state,
            hasError: error != null,
          ),
        ),
        Visibility(
          visible: error != null,
          child: FormHelperError(
            errorText: error,
            errorWidget: widget.errorWidget,
          ),
        ),
      ],
    );
  }

  void didChange(T value) {
    final formContext = FormScope.of(context);
    formContext.setFieldValue(widget.name, value);
  }

  void rebuild() {
    setState(() {});
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

class FormHelperError extends StatelessWidget {
  final String? errorText;
  final Widget Function(String? error)? errorWidget;

  const FormHelperError({
    super.key,
    this.errorText,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return errorWidget != null
        ? errorWidget!(errorText)
        : defaultErrorWidget(errorText);
  }
}
