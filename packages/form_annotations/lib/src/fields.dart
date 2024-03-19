import '../cumulations_form_annotations.dart';

class Field {
  final String label;
  final FieldType type;
  final bool requiredFiled;

  const Field(this.label, this.type, {this.requiredFiled = false});
}

class Options {
  final Map<dynamic, String> options;

  const Options({required this.options});
}

class DynamicOptions {
  final int fieldId;

  const DynamicOptions(this.fieldId);
}
