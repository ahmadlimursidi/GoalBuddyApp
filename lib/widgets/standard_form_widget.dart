import 'package:flutter/material.dart';

class StandardFormWidget extends StatelessWidget {
  final String title;
  final List<FormFieldConfig> fields;
  final String submitButtonText;
  final Color submitButtonColor;
  final VoidCallback? onSubmit;
  final bool isLoading;

  const StandardFormWidget({
    super.key,
    required this.title,
    required this.fields,
    required this.submitButtonText,
    required this.submitButtonColor,
    this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: submitButtonColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Form(
              child: Column(
                children: [
                  ...fields.map((field) => _buildField(field)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: submitButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            submitButtonText,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    switch (field.type) {
      case FieldType.text:
        return TextFormField(
          controller: field.controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(field.icon),
          ),
          keyboardType: field.keyboardType,
          validator: field.validator,
        );
      case FieldType.date:
        return TextFormField(
          controller: field.controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(field.icon),
          ),
          readOnly: true,
          onTap: field.onTap,
          validator: field.validator,
        );
      case FieldType.dropdown:
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: field.controller?.text,
                  hint: Text(field.hint ?? ''),
                  isExpanded: true,
                  underline: Container(),
                  items: field.options?.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    field.controller?.text = newValue ?? '';
                    if (field.onChanged != null) {
                      field.onChanged!(newValue);
                    }
                  },
                ),
              ),
            ],
          ),
        );
    }
  }
}

enum FieldType { text, date, dropdown }

class FormFieldConfig {
  final FieldType type;
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final List<String>? options;
  final IconData icon;
  final ValueChanged<String?>? onChanged;

  FormFieldConfig.text({
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
    required this.icon,
    this.onTap,
    this.options,
    this.onChanged,
  }) : type = FieldType.text;

  FormFieldConfig.date({
    required this.label,
    this.hint,
    this.controller,
    required this.onTap,
    this.validator,
    required this.icon,
    this.keyboardType,
    this.options,
    this.onChanged,
  }) : type = FieldType.date;

  FormFieldConfig.dropdown({
    required this.label,
    this.hint,
    this.controller,
    this.options,
    this.onChanged,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.onTap,
  }) : type = FieldType.dropdown;
}