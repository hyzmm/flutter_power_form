import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

class BuiltInFormValidation extends StatefulWidget {
  const BuiltInFormValidation({super.key});

  @override
  State<BuiltInFormValidation> createState() => _BuiltInFormValidationState();
}

class _BuiltInFormValidationState extends State<BuiltInFormValidation> {
  final formKey = GlobalKey<PowerFormState>();

  @override
  Widget build(BuildContext context) {
    return PowerForm(
      initialValues: const {"b": "a@gmail.com", "d": "A1"},
      key: formKey,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final form = formKey.currentState!;
            if (await form.validate()) {}
          },
          child: const Icon(Icons.save),
        ),
        appBar: AppBar(
          title: const Text("BuildIt Form Validation"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PowerFormItem<String>(
                name: 'a',
                validator:
                    PowerFormFieldValidator.required("Field is required"),
                builder: (value, onChanged, extra) {
                  return TextFormField(
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      helperText: "This field is required",
                    ),
                  );
                }),
            PowerFormItem<String>(
                name: 'b',
                validator:
                    PowerFormFieldValidator.email("Invalid email address"),
                builder: (value, onChanged, extra) {
                  return TextFormField(
                    initialValue: "a@gmail.com",
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      helperText: "Enter a valid email address",
                    ),
                  );
                }),
            PowerFormItem<String>(
                name: 'c',
                validator: PowerFormFieldValidator.compose([
                  PowerFormFieldValidator.minLength(5, "Minimum length is 5"),
                  PowerFormFieldValidator.maxLength(10, "Maximum length is 10"),
                ]),
                builder: (value, onChanged, extra) {
                  return TextFormField(
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      helperText:
                          "Enter a value between 5 and 10 characters long",
                    ),
                  );
                }),
            PowerFormItem<String>(
                name: 'd',
                validator: PowerFormFieldValidator.pattern(
                    RegExp("[A-Z][0-9]+"),
                    "You must enter a capital letter followed by a number"),
                builder: (value, onChanged, extra) {
                  return TextFormField(
                    initialValue: "A1",
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      helperText: "a capital letter followed by a number",
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
