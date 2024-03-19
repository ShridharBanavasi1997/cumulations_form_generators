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
            DateTime.fromMillisecondsSinceEpoch(DateTime.now().year - 10),
        lastDate: widget.lastDate ?? DateTime(DateTime.now().year + 10),
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
