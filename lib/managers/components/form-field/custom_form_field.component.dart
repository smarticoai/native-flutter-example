import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool? enabled;

  const CustomFormField(
      {super.key,
      this.initialValue,
      this.validator,
      this.onSaved,
      this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: initialValue,
        validator: validator,
        onSaved: onSaved,
        enabled: enabled,
      ),
    );
  }
}
