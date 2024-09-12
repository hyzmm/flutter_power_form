import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

class ReactiveDataChanged extends StatefulWidget {
  const ReactiveDataChanged({super.key});

  @override
  State<ReactiveDataChanged> createState() => _ReactiveDataChangedState();
}

class _ReactiveDataChangedState extends State<ReactiveDataChanged> {
  final formKey = GlobalKey<PowerFormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reactive dataChanged"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PowerForm(
          initialValues: const {"name": "John"},
          key: formKey,
          child: ListView(
            children: [
              const Text("Submit button will be enabled when data is changed"),
              FormItem<String>(
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
              FormDataChanged(builder: (context, dataChanged, _) {
                return FilledButton(
                    onPressed: dataChanged ? submit : null,
                    child: const Text("Submit"));
              }),
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
    }
  }
}
