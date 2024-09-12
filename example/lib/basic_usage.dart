import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

class BasicUsage extends StatefulWidget {
  const BasicUsage({super.key});

  @override
  State<BasicUsage> createState() => _BasicUsageState();
}

class _BasicUsageState extends State<BasicUsage> {
  final formKey = GlobalKey<PowerFormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Basic Usage"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PowerForm(
          key: formKey,
          child: ListView(
            children: [
              FormItem<String>(
                  name: "name",
                  validator: PowerFormFieldValidatorPresets.required(
                      "Name is required"),
                  builder: (value, onChanged, extra) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    );
                  }),
              FilledButton(onPressed: submit, child: const Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }

  void submit() {
    final formState = formKey.currentState!;
    if (formState.validate()) {}
  }
}
