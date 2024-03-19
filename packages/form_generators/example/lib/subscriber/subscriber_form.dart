import 'package:cumulations_form_annotations/cumulations_form_annotations.dart';
import 'package:example/SearchableMultiSelect.dart';
import 'package:example/date_picker_textfield.dart';
import 'package:flutter/material.dart';

import '../common_functions.dart';

part "subscriber_form.g.dart";

@FormGenerate("News letter subscription")
class Subscriber {
  //For TextFiled in Form
  //String is preferred for TextInput and TextArea. However, you can use any type, But have to convert from String to preferred data type once you get map of data onSubmit
  @Field("First Name", FieldType.TextInput, requiredFiled: true)
  String? fName;

  @Field("Last Name", FieldType.TextInput)
  String? lName;

  @Field("Email", FieldType.TextInput)
  String? email;

  //For FieldType.SingleSelect or FieldType.MultiSelect, Along with Filed you have to use @Options or @DynamicOptions
  //If you use @Options, you have to pass Map<T, String> as options. Where T as type of key and String as type of value, in this cake we are using int for key type
  //Also Please keep the variable data type as T, in Our case T is int
  //If you use @DynamicOptions, you have to pass the number of options you want to show in the dropdown
  //In this case, you have to implement static getDropdownItemByGroupId function under the CategoryMasterDataMapper class.
  @Field("Gender", FieldType.SingleSelect, requiredFiled: true)
  @Options(options: {1: "Male", 2: "Female"})
  int? gender;

  //If you want to use FieldType.MultiSelect in your form add code of SearchableMultiselect in your project and import it in the data model class
  @Field("Topic interested In", FieldType.MultiSelect, requiredFiled: true)
  @DynamicOptions(2)
  List<int>? multiSelect;

  //For FieldType.DatePicker, you have to use DatePickerTextField in your project and import it in the data model class
  @Field("Date of Birth", FieldType.DatePicker, requiredFiled: true)
  DateTime? date;

  //For FieldType.CheckBox, you have to use bool? as data type
  @Field("Do you want to opt in for promotions", FieldType.CheckBox)
  bool? opt_for_promotion;

  //For TextArea in Form
  @Field("Address", FieldType.TextArea, requiredFiled: true)
  String? address;

  Subscriber(
      {this.fName,
      this.lName,
      this.email,
      this.gender,
      this.opt_for_promotion,
      this.multiSelect,
      this.date,
      this.address});
}
