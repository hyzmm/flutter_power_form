import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

class ReactiveDataChangedAndReset extends StatefulWidget {
  const ReactiveDataChangedAndReset({super.key});

  @override
  State<ReactiveDataChangedAndReset> createState() =>
      _ReactiveDataChangedAndResetState();
}

class _ReactiveDataChangedAndResetState
    extends State<ReactiveDataChangedAndReset> {
  final formKey = GlobalKey<PowerFormState>();

  // Usually, there is no need to use TextController unless you need to reset the text in a TextField.
  // Since Flutter's TextField is self-managed, you would need to do this in that case.
  TextEditingController? textController;

  @override
  void dispose() {
    textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reactive dataChanged & Reset"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PowerForm(
          initialValues: const {"name": "John"},
          onReset: () {
            // Since flutter TextField is self-managed, you would need to reset the text manually.
            textController?.text = formKey.currentState!.getFieldValue('name');
          },
          key: formKey,
          child: ListView(
            children: [
              const Text("Submit button will be enabled when data is changed"),
              FormItem<String>(
                  name: "name",
                  validator:
                      PowerFormFieldValidator.required("Name is required"),
                  builder: (value, onChanged, extra) {
                    textController ??= TextEditingController(text: value);
                    return TextField(
                      controller: textController,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    );
                  }),
              const SizedBox(height: 10),
              FormDataChanged(
                  builder: (context, dataChanged, _) => FilledButton(
                      onPressed: dataChanged ? submit : null,
                      child: const Text("Submit"))),
              const SizedBox(height: 10),
              FilledButton(
                  onPressed: () {
                    formKey.currentState!.reset();
                  },
                  child: const Text("Reset")),
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
