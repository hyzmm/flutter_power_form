import 'dart:async';

import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

class AsyncValidation extends StatefulWidget {
  const AsyncValidation({super.key});

  @override
  State<AsyncValidation> createState() => _AsyncValidationState();
}

class _AsyncValidationState extends State<AsyncValidation> {
  final formKey = GlobalKey<PowerFormState>();

  FutureOr<String?> checkUsernameAvailable(String? name) async {
    setState(() {
      loading = true;
    });
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loading = false;
    });
    return "Username is already taken";
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Async Validation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PowerForm(
          key: formKey,
          child: ListView(
            children: [
              FormItem<String>(
                  name: "name",
                  validator: PowerFormFieldValidator.compose<String?>([
                    PowerFormFieldValidator.required(
                        "Please type your username"),
                    checkUsernameAvailable
                  ]),
                  builder: (value, onChanged, extra) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        helper: Text(
                            "Input something and click the submit button to see the async validation"),
                      ),
                    );
                  }),
              FilledButton(
                  onPressed: submit,
                  child: Text(loading ? "Loading..." : "Submit")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    final formState = formKey.currentState!;
    if (await formState.validate()) {}
  }
}
