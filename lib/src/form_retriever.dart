import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

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
  State<FormValueRetriever<T>> createState() => FormValueRetrieverState<T>();
}

class FormValueRetrieverState<T> extends State<FormValueRetriever<T>> {
  PowerFormState? formState;
  @override
  Widget build(BuildContext context) {
    formState ??= PowerForm.of(context)..addValueRetriever(this);

    return widget.builder(context, formState!.getFieldValue<T>(widget.fieldName));
  }

  @override
  void dispose() {
    formState!.removeValueRetriever(widget.fieldName, this);
    super.dispose();
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}
