class FormValdators {
  String? checkRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }

    return null;
  }
}

FormValdators formValdators = FormValdators();
