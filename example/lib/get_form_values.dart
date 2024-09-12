import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:power_form/power_form.dart';

class GetFormValues extends StatefulWidget {
  const GetFormValues({super.key});

  @override
  State<GetFormValues> createState() => _GetFormValuesState();
}

class _GetFormValuesState extends State<GetFormValues> {
  final formKey = GlobalKey<PowerFormState>();

  // Usually, there is no need to use TextController unless you need to reset the text in a TextField.
  // Since Flutter's TextField is self-managed, you would need to do this in that case.
  TextEditingController? usernameTextController;
  TextEditingController? emailTextController;

  Map<String, dynamic> valueJsonString = {};

  @override
  void dispose() {
    usernameTextController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Get Form Values"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: PowerForm(
            initialValues: const {
              "name": "John Doe",
              "email": "a.gmail.com",
            },
            onReset: () {
              // Since flutter TextField is self-managed, you would need to reset the text manually.
              usernameTextController?.text =
                  formKey.currentState!.getFieldValue('name');
            },
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormItem<String>(
                    name: "name",
                    rebuildOnChanged: false,
                    builder: (value, onChanged, extra) {
                      usernameTextController ??=
                          TextEditingController(text: value);
                      return TextField(
                        controller: usernameTextController,
                        onChanged: onChanged,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                        ),
                      );
                    }),
                FormItem<String>(
                    name: "email",
                    builder: (value, onChanged, extra) {
                      emailTextController ??=
                          TextEditingController(text: value);
                      return TextField(
                        controller: emailTextController,
                        onChanged: onChanged,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                        ),
                      );
                    }),
                const SizedBox(height: 10),
                FilledButton(
                    onPressed: () {
                      formKey.currentState!.save();
                    },
                    child: const Text("Save")),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                          onPressed: () {
                            final values = formKey.currentState!.values;
                            setState(() {
                              valueJsonString = values;
                            });
                          },
                          child: const Text("Get Values")),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                          onPressed: () {
                            final values =
                                formKey.currentState!.getPatchValues();
                            setState(() {
                              valueJsonString = values;
                            });
                          },
                          child: const Text("Get Patch Values")),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: Text(jsonEncode(valueJsonString)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
