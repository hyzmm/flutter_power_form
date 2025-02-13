import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

/// A widget that rebuilds when the form data is changed & valid.
/// This widget can be used to enable/disable the save button.
class FormChange extends StatelessWidget {
  final Widget? child;
  final ValueWidgetBuilder<bool> builder;

  const FormChange({
    super.key,
    this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final formState = PowerForm.of(context);
    return FormValidity(builder: (context, valid, _) {
      return StreamBuilder<bool>(
        stream: formState.dataChanged,
        builder: (context, snapshot) {
          return builder(context, valid && (snapshot.data ?? false), child);
        },
      );
    });
  }
}
