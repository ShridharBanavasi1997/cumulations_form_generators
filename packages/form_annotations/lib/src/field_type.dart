enum FieldType {
  TextInput("TextInput"),
  TextArea("TextArea"),
  CheckBox("CheckBox"),
  SingleSelect("SingleSelect"),
  MultiSelect("MultiSelect"),
  DatePicker("DatePicker");

  final String value;

  const FieldType(this.value);
}
