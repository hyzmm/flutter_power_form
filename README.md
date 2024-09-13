# PowerForm

A Flutter package for making form validation and submission easier.

This package does not have any pure UI widgets, it's widgets just wrappers for form validation and submission, you can use any UI widget you want.

## Getting Started

It is currently not published on pub.dev.

## Features

1. No need to manage form state
2. Validate form using `PowerFormFieldValidator`
3. Support async validator
4. Use `FormChange` to listen to form data changes (Usually used to enable or disable the submit button in a modification form)
5. Use `FormValidity` to listen to form validity changes (Usually used to enable or disable the submit button in a creation form)
6. Get form values to submit to create resource
7. Get patch values to submit to update resource

## Usage

```dart
final formKey = GlobalKey<PowerFormState>();

// 1. Create a PowerForm
PowerForm(
  // 2. Pass the form key to manipulate the form later
  key: formKey,
  child: Column(
    children: [
      // 3. Specify the form value type
      PowerFormItem<String>(
          // 4. Specify the field name, corresponding to the data field name
          name: "name",
          // 5. Maybe a validator
          validator: PowerFormFieldValidator.compose<String?>([
            PowerFormFieldValidator.required("Please type your username"),
            PowerFormFieldValidator.minLength(3, "Username must be at least 3 characters"),
          ]),
          builder: (value, onChanged, extra) {
            // 6. Return a widget
            return TextFormField(
              // 7. Pass the value and onChanged to the widget
              initialValue: value,
              onChanged: onChanged,
            );
          })
    ],
  ),
)
```

## State Management

To make it less tedious to declare and update variables for each form field, `PowerForm` stores data for all form fields within its state, this makes users to focus on the UI.

Users only need to specify a `name` property for each `PowerFormItem`, this name corresponds to the key name the data returned by the form.

## Validator

`PowerFormItem` has a `validator` property, which is a `PowerFormFieldValidatorCallback` type. There are some built-in validators in `PowerFormFieldValidator`:

1. `PowerFormFieldValidator.required` - Check if the value is null or empty
2. `PowerFormFieldValidator.minLength` - Check if the value length is less than the specified length
3. `PowerFormFieldValidator.maxLength` - Check if the value length is greater than the specified length
4. `PowerFormFieldValidator.email` - Check if the value is a valid email address
5. `PowerFormFieldValidator.pattern` - Check if the value matches the specified pattern
6. `PowerFormFieldValidator.compose` - Combine multiple validators

And you can also create your own validator:

```dart
PowerFormItem<String>(
  name: "name",
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Please type your username";
    }
    if (value.length < 3) {
      return "Username must be at least 3 characters";
    }
    return null;
  },
)
```

### Combine multiple validators

You can use `PowerFormFieldValidator.compose` to combine multiple validators. For example, the above validator can be rewritten as:

```dart
PowerFormItem<String>(
  name: "name",
  validator: PowerFormFieldValidator.compose<String?>([
    PowerFormFieldValidator.required("Please type your username"),
    PowerFormFieldValidator.minLength(3, "Username must be at least 3 characters"),
  ]),
)
```

### Async validator

Sometimes you need to validate the form field asynchronously, you can write a function to implement this:

```dart
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

PowerFormItem<String>(
  name: "name",
  validator: checkUsernameAvailable,
)
```

### Listen to form data changed

You can use `FormDataChanged` to listen for changes in the data, which means that the data has ultimately been modified. This is usually used to enable/disable the submit button:

```dart
FormDataChanged(
  builder: (context, changed, _) => FilledButton(
    onPressed: changed ? submit : null,
    child: const Text("Submit"),
  ),
),
```

## Get form values

After the form is filled, user need to submit the form data to create a resource. You can use `PowerFormState.values` to get the form data:

```dart
final Map<String, dynamic> values = formKey.currentState!.values;
```

## Get patch values

Or maybe you need to submit the form data to update a resource, you can use `PowerFormState.getPatchValues` to get the patch data:

```dart
final values = formKey.currentState!.getPatchValues();
```

Patch data only contains the fields that have been modified. It corresponds to the `PATCH` method in RESTful API, which only updates the fields that have been modified.
