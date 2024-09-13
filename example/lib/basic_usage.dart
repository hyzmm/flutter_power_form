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
          validateMode: ValidateMode.onChange,
          child: ListView(
            children: [
              PowerFormItem<String>(
                  name: "name",
                  validator:
                      PowerFormFieldValidator.required("Name is required"),
                  builder: (value, onChanged, extra) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    );
                  }),
              PowerFormItem<Gender>(
                  name: "gender",
                  builder: (value, onChanged, extra) {
                    return Column(
                      children: [
                        RadioListTile<Gender>(
                            value: Gender.male,
                            groupValue: value,
                            onChanged: (v) => onChanged(v!),
                            title: const Text("Male")),
                        RadioListTile<Gender>(
                            value: Gender.female,
                            groupValue: value,
                            onChanged: (v) => onChanged(v!),
                            title: const Text("Female")),
                      ],
                    );
                  }),
              FormChange(
                builder: (context, changed, _) => FilledButton(
                  onPressed: changed ? submit : null,
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    final formState = formKey.currentState!;
    if (await formState.validate()) {
      formState.save();
      final values = formState.values;
      print(values);
    }
  }
}

enum Gender {
  male,
  female,
}
