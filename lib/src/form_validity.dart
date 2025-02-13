import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

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
