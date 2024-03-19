import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SearchableMultiselect extends StatefulWidget {
  final List<OptionType> items;
  final List<OptionType> selectedValues;
  final Function(List<dynamic>) onSelect;

  const SearchableMultiselect(
      {Key? key,
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

  const _OptionList(
      {Key? key,
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
