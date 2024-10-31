import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

class GetValueUsingWidget extends StatefulWidget {
  const GetValueUsingWidget({super.key});

  @override
  State<GetValueUsingWidget> createState() => _GetValueUsingWidgetState();
}

class _GetValueUsingWidgetState extends State<GetValueUsingWidget> {
  final formKey = GlobalKey<PowerFormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Get Value Using Widget"),
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
                  builder: (value, onChanged, extra) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    );
                  }),
              FormValueRetriever<String>(
                fieldName: "name",
                builder: (context, value) {
                  return Text("Name: $value");
                },
              ),
              FormChange(
                builder: (context, changed, _) => FilledButton(
                  onPressed: changed ? save : null,
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> save() async {
    final formState = formKey.currentState!;
    if (await formState.validate()) {
      formState.save();
    }
  }
}
