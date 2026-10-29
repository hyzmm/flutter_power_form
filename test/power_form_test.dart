import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_form/power_form.dart';

void main() {
  Widget item(String name) => PowerFormItem<String>(
        name: name,
        validator: (value) => (value ?? '').isEmpty ? 'required' : null,
        builder: (value, onChanged, extra) => Text(name),
      );

  testWidgets('字段卸载后清掉它的错误，clearErrors 不会崩溃', (tester) async {
    final formKey = GlobalKey<PowerFormState>();
    final showPhone = ValueNotifier(true);

    await tester.pumpWidget(
      MaterialApp(
        home: PowerForm(
          key: formKey,
          initialValues: const {'phone': '', 'email': ''},
          validateMode: ValidateMode.manual,
          child: ValueListenableBuilder<bool>(
            valueListenable: showPhone,
            // Row 与下面的 PowerFormItem 类型不同，切换时手机号表单项会被卸载
            builder: (_, isPhone, __) => isPhone
                ? Row(mainAxisSize: MainAxisSize.min, children: [item('phone')])
                : item('email'),
          ),
        ),
      ),
    );

    expect(await formKey.currentState!.validate(['phone']), isFalse);
    expect(formKey.currentState!.getError('phone'), 'required');

    showPhone.value = false;
    await tester.pump();

    expect(formKey.currentState!.getError('phone'), isNull);
    formKey.currentState!.clearErrors();
    expect(await formKey.currentState!.validate(['email']), isFalse);
    expect(formKey.currentState!.getError('email'), 'required');
  });

  testWidgets('字段在同一个元素上改名后能按新 name 注册并校验', (tester) async {
    final formKey = GlobalKey<PowerFormState>();
    final fieldName = ValueNotifier('password');

    await tester.pumpWidget(
      MaterialApp(
        home: PowerForm(
          key: formKey,
          validateMode: ValidateMode.manual,
          child: ValueListenableBuilder<String>(
            valueListenable: fieldName,
            builder: (_, name, __) => item(name),
          ),
        ),
      ),
    );

    expect(await formKey.currentState!.validate(['password']), isFalse);
    expect(formKey.currentState!.getError('password'), 'required');

    fieldName.value = 'code';
    await tester.pump();

    expect(formKey.currentState!.getError('password'), isNull);
    expect(await formKey.currentState!.validate(['code']), isFalse);
    expect(formKey.currentState!.getError('code'), 'required');
  });
}
