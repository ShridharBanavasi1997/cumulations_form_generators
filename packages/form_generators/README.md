# Cumulations Form Generator

## Getting started

This package is used to generate forms for data classes. It uses annotations to generate the form.
The package also includes a form generator that generates the form based on
the [cumulation_form_annotations]{https://pub.dev/packages/cumulations_form_annotations}.

### List of annotations and their uses:

- @FormGenerate: This annotation is used to generate a form for a data class. Simply annotate the
  class with this annotation to create the form. It take the following parameters:
    - name: The title of the form.
    - maxWidth: If you wish to define the width of form.
- @Field: This annotation is used to declare a variable as a field within the class. To use it,
  annotate the variable with this annotation. You can also specify what kind of input field it
  is by using one of the following parameters Field Type:
  This take the following parameters:
    - label: The label of the field.
    - isRequired: If the field is required or not, By default it is false.
    - FieldType: The type of the field.
        - FieldType.TextInput
        - FieldType.TextArea
        - FieldType.CheckBox
        - FieldType.SingleSelect
        - FieldType.MultiSelect
        - FieldType.DatePicker
- @Options: This annotation allows you to provide predefined options for single-select and
  multi-select fields.
- @DynamicOptions: By using this annotation, you can give dynamic options. To implement this, you'll
  need to create a static getDropdownItemByGroupId function under the CategoryMasterDataMapper class
  that provides options at runtime.

Install the package by adding the following to your `pubspec.yaml` file:

```yaml
dependencies:
  cumulation_form_annotations: ^1.0.0

dev_dependencies:
  build_runner:
  cumulations_form_generators: ^1.0.0
```

or
``dart pub add dev:cumulations_form_generators``
and
``dart pub add cumulation_form_annotations``

Then run `flutter pub get` or `dart pub get`.

## Usage

Crate file for data model with pattern like `*FileName_form.dart` and annotate the class
with `@FormGenerate` and the fields with `@Field` and `@Options` or `@DynamicOptions` if needed.

*Note: File name should contain `_form` at the end.*

```dart
import 'package:flutter/material.dart'; // import this package in your data model class
import 'package:cumulations_form_annotations/cumulations_form_annotations.dart';
import 'package:project_package/SearchableMultiSelect.dart'; // if you are using FieldType.MultiSelect
import 'package:project_package/date_picker_textfield.dart'; // if you are using FieldType.DatePicker

part 'FileName_form.g.dart'; // add this line at the top of the file

@FormGenerate("News letter subscription")
class FileName {
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

  Subscriber({this.fName,
    this.lName,
    this.email,
    this.gender,
    this.opt_for_promotion,
    this.multiSelect,
    this.date,
    this.address});
}
```

if you are using @DynamicOptions, you have to implement static getDropdownItemByGroupId function
under the CategoryMasterDataMapper class.

```dart
class CategoryMasterDataMapper {
  static List<Topics> getDropdownItemByGroupId(int formId) {
    switch (formId) {
      case 2:
        return [
          Topics(1, "Sports"),
          //here, Please maintain T  data type same as you defined data type for the field
          Topics(2, "Politics"),
          Topics(3, "International")
        ];
    //Based on formId you can return the list of options
      default:
        return [];
    }
  }
}

class Topics<T> {
  T id;
  String name;

  Topics(this.id, this.name);
}
```

For multi-select field, you have to add the following code in your project

```dart
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SearchableMultiselect extends StatefulWidget {
  final List<OptionType> items;
  final List<OptionType> selectedValues;
  final Function(List<dynamic>) onSelect;

  const SearchableMultiselect({Key? key,
    required this.items,
    required this.selectedValues,
    required this.onSelect})
      : super(key: key);

  @override
  State<SearchableMultiselect> createState() => _SearchableMultiselectState();
}

class _SearchableMultiselectState extends State<SearchableMultiselect> {
  final GlobalKey _widgetKey = GlobalKey();

  late final TextEditingController _textEditingController =
  TextEditingController();

  final FocusNode _focusNode1 = FocusNode();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.selectedValues.isNotEmpty
        ? "${widget.selectedValues.length} Selected"
        : "";
    print("new render");
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(fontSize: 12),
      key: _widgetKey,
      focusNode: _focusNode1,
      keyboardType: TextInputType.none,
      decoration: const InputDecoration(
          hintText: "Select", suffixIcon: Icon(Icons.arrow_drop_down)),
      controller: _textEditingController,
      onTap: () {
        showAlignedDialog(
            context: context,
            builder: _localDialogBuilder,
            followerAnchor: Alignment.topCenter,
            targetAnchor: Alignment.bottomCenter,
            avoidOverflow: true,
            barrierColor: Colors.transparent);
      },
    );
  }

  WidgetBuilder get _localDialogBuilder {
    final RenderBox renderBox =
    _widgetKey.currentContext?.findRenderObject() as RenderBox;
    return (BuildContext context) {
      return Container(
        constraints:
        BoxConstraints(maxWidth: renderBox.size.width, maxHeight: 250),
        child: Material(
            elevation: 4.0,
            child: _OptionList(
              items: widget.items,
              selectedValues: widget.selectedValues,
              onSelect: (value, data) {
                widget.onSelect(value);
                setState(() {
                  _textEditingController.text = data;
                });
              },
            )),
      );
    };
  }
}

class _OptionList extends StatefulWidget {
  final List<OptionType> items;
  final List<OptionType> selectedValues;
  final Function(List<dynamic>, String) onSelect;

  const _OptionList({Key? key,
    required this.items,
    required this.selectedValues,
    required this.onSelect})
      : super(key: key);

  @override
  State<_OptionList> createState() => _OptionListState();
}

class _OptionListState extends State<_OptionList> {
  late final TextEditingController _textFieldController =
  TextEditingController();
  final FocusNode _focusNode2 = FocusNode();

  List<OptionType> _searchResult = [];
  List<OptionType> _selectedList = [];

  @override
  void initState() {
    super.initState();
    _selectedList = widget.selectedValues;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(0.2),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: TextField(
                  style: TextStyle(fontSize: 12),
                  focusNode: _focusNode2,
                  controller: _textFieldController,
                  decoration: const InputDecoration(
                      hintText: 'Search', border: InputBorder.none),
                  onChanged: _onSearchTextChanged,
                ),
              ),
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(maxHeight: 180),
          child: _searchResult.length != 0 ||
              _textFieldController.text.isNotEmpty
              ? SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  itemCount: _searchResult.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context1, i) {
                    return GestureDetector(
                      onTap: () async {
                        if (_selectedList.contains(_searchResult[i])) {
                          _selectedList.remove(_searchResult[i]);
                        } else {
                          _selectedList.add(_searchResult[i]);
                        }
                        var selectedValue = <dynamic>[];
                        _selectedList.forEach((element) {
                          selectedValue.add(element.value);
                        });
                        widget.onSelect(
                            selectedValue,
                            _selectedList.isNotEmpty
                                ? "${_selectedList.length} Selected"
                                : "");
                        setState(() {});
                      },
                      child: Card(
                        color: _selectedList.contains(_searchResult[i])
                            ? Colors.green
                            : Colors.white,
                        margin: const EdgeInsets.all(0.0),
                        child: ListTile(
                          title: Text(
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              _searchResult[i].label),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  itemCount: widget.items.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (_selectedList.contains(widget.items[index])) {
                          _selectedList.remove(widget.items[index]);
                        } else {
                          _selectedList.add(widget.items[index]);
                        }

                        var selectedValue = <dynamic>[];
                        _selectedList.forEach((element) {
                          selectedValue.add(element.value);
                        });
                        widget.onSelect(
                            selectedValue,
                            _selectedList.isNotEmpty
                                ? "${_selectedList.length} Selected"
                                : "");
                        setState(() {});
                      },
                      child: Card(
                        color: _selectedList.contains(widget.items[index])
                            ? Colors.green
                            : Colors.white,
                        margin: const EdgeInsets.all(0.0),
                        child: ListTile(
                          title: Text(
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              widget.items[index].label),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _onSearchTextChanged(String text) async {
    print("text: $text");
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    RegExp pattern = RegExp(text, caseSensitive: false);
    widget.items.forEach((value) {
      if (value.label.contains(pattern)) {
        _searchResult.add(value);
      }
    });

    setState(() {});
  }
}

class _AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class OptionType extends Equatable {
  final dynamic value;
  final String label;

  OptionType({required this.value, required this.label});

  @override
  List<Object> get props => [value];
}
```

For date picker field, you have to add the following code in your project

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestPickerWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueSetter<DateTime> onSelectDate;
  final DateTime? initialDate;
  final DateTime? firstData;
  final DateTime? lastDate;

  const TestPickerWidget({
    Key? key,
    this.selectedDate,
    this.initialDate,
    this.firstData,
    this.lastDate,
    required this.onSelectDate,
  }) : super(key: key);

  @override
  _TestPickerWidgetState createState() => _TestPickerWidgetState();
}

class _TestPickerWidgetState extends State<TestPickerWidget> {
  late DateTime _selectedDate;
  late final TextEditingController _textEditingController =
  TextEditingController(
      text: (widget.selectedDate != null)
          ? DateFormat("MM/dd/yyy").format(widget.selectedDate!)
          : "");

  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextFormField(
          focusNode: AlwaysDisabledFocusNode(),
          controller: _textEditingController,
          onTap: () {
            _selectDate(context);
          },
          decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_month), hintText: "MM/DD/YYYY"),
        ));
  }

  ///show datePicker and return selected date
  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate:
        widget.initialDate ?? widget.selectedDate ?? DateTime.now(),
        firstDate: widget.firstData ??
            DateTime.fromMillisecondsSinceEpoch(DateTime
                .now()
                .year - 10),
        lastDate: widget.lastDate ?? DateTime(DateTime
            .now()
            .year + 10),
        currentDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF2E2E48),
                  onPrimary: Colors.white,
                ),
                // Here I Chaged the overline to my Custom TextStyle.
                textTheme: TextTheme(
                    overline:
                    TextStyle(color: Color(0xFF2E2E48), fontSize: 12)),
                primaryTextTheme: TextTheme(
                    overline: TextStyle(color: Color(0xFF2E2E48), fontSize: 12))
              // dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        });

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _textEditingController
        ..text = DateFormat("MM/dd/yyyy").format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController.text.length,
            affinity: TextAffinity.upstream));
      widget.onSelectDate(_selectedDate);
    }
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
```

Command to generate the form:
`flutter pub run build_runner build`

Once you run the above command, a new file will be generated with the name `FileName_form.g.dart` in
the same directory as the data model file.

You can use the data model object to get the form by calling the `getForm` method.

```dart
 @override
Widget build(BuildContext context) {
  return Scaffold(
      body: SingleChildScrollView(
          child: Column(
              children: [
                dataModelObject.getForm()
              ]
          )));
}
```

If you want to get the data from the form, you can call the `getFormData` method. THis will return
in the form of a map.

```dart
dataModelObject.getFormData
()
```

***Note:If you want to give any initial value before loading view, use can use object of the data
model and assign the value to the fields and then pass the object to the getForm method.***