import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:cumulations_form_annotations/cumulations_form_annotations.dart';
import 'package:source_gen/source_gen.dart';

class FormGeneratorBuilder implements Builder {
  final FormGenerator generator;

  FormGeneratorBuilder(this.generator);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    if (!inputId.path.endsWith('_form.dart')) {
      return;
    }

    final library = await buildStep.inputLibrary;
    final libraryReader = LibraryReader(library);
    final generatedCode = StringBuffer();
    for (var annotatedElement
        in libraryReader.annotatedWith(generator.typeChecker)) {
      final generated = generator.generateForAnnotatedElement(
          annotatedElement.element as ClassElement,
          annotatedElement.annotation,
          buildStep);
      generatedCode.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
      generatedCode.writeln("part of \'${inputId.pathSegments.last}\';");
      generatedCode.writeln(generated);
    }
    final outputId = inputId.changeExtension('.g.dart');
    await buildStep.writeAsString(outputId, generatedCode.toString());
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart'],
      };
}

class FormGenerator extends GeneratorForAnnotation<FormGenerate> {
  late var visitor;

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    visitor = ViewGeneratorModelVisitor();
    element.visitChildren(visitor);
    final classBuffer = StringBuffer();

    final String name = annotation.read('name').literalValue as String;
    final double maxWidth = annotation.read('maxWidth').literalValue as double;

    classBuffer.writeln(
        """// **************************************************************************
// FormGenerator
// **************************************************************************""");

    classBuffer.writeln("""extension GeneratedModel on ${visitor.className} {
      static Map<String, dynamic> formData = <String, dynamic>{};
  static final formKey = GlobalKey<FormState>();
                              getView() {
                              return _FormWidget(data: this);
                              }

                              getFormData() {
                                if (formKey.currentState?.validate() ?? false) {
                                  return formData;
                                }
                              }
                              
                              ${visitor.className} fromMap(Map<String, dynamic> json) {
                                return ${visitor.className}(
                                  ${visitor.fields.entries.map((e) => "${e.key}: json['${e.key}'],").join("\n")}
                                );
                              }
                              """);

    for (final field in visitor.options.entries) {
      classBuffer.writeln("""Map<dynamic, String> get${field.key}Entry() {
        return ${field.value};
        }""");
    }

    classBuffer.writeln("}");

    classBuffer.writeln("""class _FormWidget extends StatefulWidget {
                            _FormWidget({Key? key, required this.data}) : super(key: key);
                            ${visitor.className} data;

                            @override
                            State<_FormWidget> createState() => _FormWidgetState();
                          }""");

    classBuffer.writeln("class _FormWidgetState extends State<_FormWidget> {");

    for (final filed in visitor.fields.entries) {
      classBuffer.writeln(_fieldVariableInitilizer(filed));
    }

    classBuffer.writeln("""
                         @override
                         void initState() {""");

    for (final filed in visitor.fields.entries) {
      classBuffer.writeln(_fieldVariableDefine(filed));
    }
    classBuffer.writeln("}");

    ///initState

    classBuffer.writeln("""@override
  Widget build(BuildContext context) {
    var maxWidth = $maxWidth;""");

    classBuffer.writeln("""return Form(
      key: GeneratedModel.formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [""");

    classBuffer.writeln("""Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "$name",
          style: TextStyle(color: Colors.blue),
          textAlign: TextAlign.left,
        ),
      ),""");

    classBuffer.writeln("""LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth >= (maxWidth*3)) {
                  var ratio = constraints.maxWidth/220;
                  return buildWithGridRow(3,ratio,constraints.maxWidth);
                } else if(constraints.maxWidth < (maxWidth*3) && constraints.maxWidth >= (maxWidth*2)) {
                  var ratio = constraints.maxWidth/140;
                  return buildWithGridRow(2,ratio,constraints.maxWidth);
                }else {
                  var ratio = constraints.maxWidth/100;
                  // if(ratio>2.5) ratio+=3;
                  // else if(ratio>1.5) ratio+=2;
                  // else ratio+=1;
                  return buildWithGridRow(1,ratio,constraints.maxWidth);
                }
              },
            ),""");

    classBuffer.writeln("])"); //Column
    classBuffer.writeln(");");
    classBuffer.writeln("}");

    ///build

    classBuffer.writeln(
        """buildWithGridRow(int crossAxisCount,double childAspectRatio,double width){
    return GridView.count(
          crossAxisSpacing: 8,
          mainAxisSpacing: 0,
          padding: EdgeInsets.all(8),
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          physics: NeverScrollableScrollPhysics(),
      shrinkWrap : true,
          children: <Widget>[""");

    for (final field in visitor.fields.entries) {
      classBuffer.writeln("//${field.value.type}");
      classBuffer.writeln(_filedHandling(field));
    }

    classBuffer.writeln("""],);
    }""");

    ///end of buildWithGridRow

    classBuffer.writeln("}");

    ///_FormWidgetState

    ///end extension
    return classBuffer.toString();
  }

  String _fieldVariableDefine(MapEntry<String, Field> data) {
    switch (data.value.type) {
      case FieldType.TextInput:
        {
          return """${data.key} = widget.data.${data.key} != null ? widget.data.${data.key}.toString() : null;
                    GeneratedModel.formData["${data.key}"] = ${data.key};""";
        }
      case FieldType.TextArea:
        {
          return """${data.key} = widget.data.${data.key} != null ? widget.data.${data.key}.toString() : null;
                    GeneratedModel.formData["${data.key}"] = ${data.key};""";
        }
      case FieldType.CheckBox:
        {
          return """${data.key} = widget.data.${data.key} != null ? widget.data.${data.key} as bool : null;
                    GeneratedModel.formData["${data.key}"] = ${data.key};""";
        }
      case FieldType.SingleSelect:
        {
          return """${data.key} = widget.data.${data.key} != null ? widget.data.${data.key} : null;
                    GeneratedModel.formData["${data.key}"] = ${data.key};""";
        }
      case FieldType.MultiSelect:
        {
          return """${data.key} = widget.data.${data.key} != null ? widget.data.${data.key} as List : null;
                    GeneratedModel.formData["${data.key}"] = ${data.key};""";
        }
      case FieldType.DatePicker:
        {
          return """${data.key} = widget.data.${data.key} != null ? widget.data.${data.key} as DateTime : null;
                    GeneratedModel.formData["${data.key}"] = ${data.key};""";
        }
    }
  }

  String _fieldVariableInitilizer(MapEntry<String, Field> data) {
    switch (data.value.type) {
      case FieldType.TextInput:
        {
          return """String? ${data.key};""";
        }
      case FieldType.TextArea:
        {
          return """String? ${data.key};""";
        }
      case FieldType.CheckBox:
        {
          return """bool? ${data.key};""";
        }
      case FieldType.SingleSelect:
        {
          return """dynamic ${data.key};""";
        }
      case FieldType.MultiSelect:
        {
          return """List<dynamic>? ${data.key};""";
        }
      case FieldType.DatePicker:
        {
          return """DateTime? ${data.key};""";
        }
    }
  }

  String _filedHandling(MapEntry<String, Field> data) {
    String star = "";
    if (data.value.requiredFiled) {
      star = """TextSpan(
        text: "*", 
        style: TextStyle(color: Colors.red)),""";
    }

    switch (data.value.type) {
      case FieldType.TextInput:
        {
          String validator = "";
          if (data.value.requiredFiled) {
            validator = """validator: (data){
                  if(data == null || data.isEmpty) return "Enter ${data.value.label}";

                  return null;
                },""";
          }
          return """Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Container(
              width:(width/crossAxisCount)-50,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: "${data.value.label}",
                    style: TextStyle(color: Colors.grey),
                    children: [$star]),
              ),
            ),
          TextFormField(
            initialValue: ${data.key},
            textInputAction: TextInputAction.next,
            // decoration: InputDecoration(hintText: "hint"),
            onChanged: (value) {
              setState(() {
            ${data.key} = value;
            GeneratedModel.formData["${data.key}"] = value;
          });
            },
            $validator
          ),
        ],
      ),""";
        }
      case FieldType.TextArea:
        {
          String validator = "";
          if (data.value.requiredFiled) {
            validator = """validator: (data){
                  if(data == null || data.isEmpty) return "Enter ${data.value.label}";

                  return null;
                },""";
          }
          return """Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width:(width/crossAxisCount)-50,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: "${data.value.label}",
                    style: TextStyle(color: Colors.grey),
                    children: [$star]),
              ),
            ),
          Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:TextFormField(
            initialValue: ${data.key},
            minLines: 1,
            maxLines: null,
            textInputAction: TextInputAction.next,
            // decoration: InputDecoration(hintText: "hint"),
            onChanged: (value) {
              setState(() {
            ${data.key} = value;
            GeneratedModel.formData["${data.key}"] = value;
          });
            },
            $validator
          ),
          ),
          ),
        ],
      ),""";
        }
      case FieldType.CheckBox:
        {
          return """Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: ${data.key} ?? false,
            onChanged: (val) {
              setState(() {
                ${data.key} = val!;
                GeneratedModel.formData["${data.key}"] = val;
              });
            },
          ),
          Container(
              width:(width/crossAxisCount)-80,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: "${data.value.label}",
                    style: TextStyle(color: Colors.grey),
                    children: [$star]),
              ),
            ),
        ],
      ),""";
        }
      case FieldType.SingleSelect:
        {
          String option = visitor.options.containsKey(data.key)
              ? """widget.data
            .get${data.key}Entry().entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList()"""
              : visitor.dynamicOption.containsKey(data.key)
                  ? """CategoryMasterDataMapper.getDropdownItemByGroupId(${visitor.dynamicOption[data.key]}).map((value) => DropdownMenuItem(
                    value: value.id,
                    child: Text(value.name),
                    ))
                .toList()
              """
                  : """widget.data
            .get${data.key.toUpperCase()}Entry().entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList()""";
          return """Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width:(width/crossAxisCount)-50,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: "${data.value.label}",
                    style: TextStyle(color: Colors.grey),
                    children: [$star]),
              ),
            ),
DropdownButtonFormField(
        isExpanded: true,
        value: ${data.key},
        items: $option,
        onChanged: (val) {
          setState(() {
            ${data.key} = val;
            GeneratedModel.formData["${data.key}"] = val;
          });
        },
        validator: (data) {
                    if (data == null) return "Select ${data.value.label}";

                    return null;
                  },
      ),
      ]),""";
        }
      case FieldType.MultiSelect:
        {
          String option = """widget.data
            .get${data.key.toUpperCase()}Entry().entries
            .map((e) => OptionType(value: e.key, label: e.value.toString()))
            .toList()""";

          if (visitor.options.containsKey(data.key)) {
            option = """widget.data
            .get${data.key}Entry().entries
            .map((e) => OptionType(value: e.key, label: e.value.toString()))
            .toList()""";
          } else if (visitor.dynamicOption.containsKey(data.key)) {
            option =
                """CategoryMasterDataMapper.getDropdownItemByGroupId(${visitor.dynamicOption[data.key]}).map((value) => OptionType(
                    value: value.id,
                    label: value.name,
                    ))
                .toList()
              """;
          }
          return """Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width:(width/crossAxisCount)-50,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: "${data.value.label}",
                    style: TextStyle(color: Colors.grey),
                    children: [$star]),
              ),
            ),
          SearchableMultiselect(
        items: $option,
        selectedValues: ${data.key}?.map((e) => OptionType(value: e, label: e.toString()))
                .toList() ?? [],
        onSelect: (value) {
          setState(() {
            ${data.key} = value;
            GeneratedModel.formData["${data.key}"] = value;
          });
        },
      ),
      ]),""";
        }

      case FieldType.DatePicker:
        {
          return """Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width:(width/crossAxisCount)-50,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: "${data.value.label}",
                    style: TextStyle(color: Colors.grey),
                    children: [$star]),
              ),
            ),
          TestPickerWidget(
        selectedDate:${data.key},
        onSelectDate: (value) {
          setState(() {
            ${data.key} = value;
            GeneratedModel.formData["${data.key}"] = value;
          });
        },
      ),
      ]),""";
        }
    }
  }
}

class ViewGeneratorModelVisitor extends SimpleElementVisitor<dynamic> {
  String className = "";

  Map<String, Field> fields = <String, Field>{};
  Map<String, Map<dynamic, String>> options = <String, Map<dynamic, String>>{};
  Map<String, int> dynamicOption = <String, int>{};

  @override
  dynamic visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();

    // DartType ends with '*', which needs to be eliminated
    // for the generated code to be accurate.
    className = elementReturnType.replaceFirst('*', '');
  }

  @override
  dynamic visitFieldElement(FieldElement element) {
    if (!element.name.startsWith("_")) {
      for (final annotation in element.metadata) {
        if (annotation.toString().contains("Field")) {
          DartObject? field = annotation.computeConstantValue();
          fields[element.name] = Field(
              field?.getField("label")?.toStringValue() ?? "",
              field?.getField("type")?.toFieldTypeValue() ??
                  FieldType.TextInput,
              requiredFiled:
                  field?.getField("requiredFiled")?.toBoolValue() ?? false);
        }

        if (annotation.toString().contains("@Options")) {
          DartObject? option = annotation.computeConstantValue();
          options[element.name] = option
                  ?.getField("options")
                  ?.toMapValue()
                  ?.map((key, value) {
                if (key.toString().contains("String")) {
                  return MapEntry("\"${key?.toStringValue() ?? " "}\"",
                      "\"${value?.toStringValue() ?? " "}\"");
                } else if (key.toString().contains("int")) {
                  return MapEntry("${key?.toIntValue() ?? " "}",
                      "\"${value?.toStringValue() ?? " "}\"");
                } else if (key.toString().contains("bool")) {
                  return MapEntry("${key?.toBoolValue() ?? " "}",
                      "\"${value?.toStringValue() ?? " "}\"");
                } else {
                  return MapEntry(key, "\"${value?.toStringValue() ?? " "}\"");
                }
              }) ??
              {};
        }

        if (annotation.toString().contains("@DynamicOptions")) {
          DartObject? option = annotation.computeConstantValue();
          dynamicOption[element.name] =
              option?.getField("fieldId")?.toIntValue() ?? 1;
        }
      }
    }
  }
}

extension ValueExtract on DartObject {
  FieldType? toFieldTypeValue() {
    String? stringValue = this.getField("value")?.toStringValue();
    if (stringValue != null) {
      if (stringValue.contains("TextInput")) {
        return FieldType.TextInput;
      } else if (stringValue.contains("TextArea")) {
        return FieldType.TextArea;
      } else if (stringValue.contains("CheckBox")) {
        return FieldType.CheckBox;
      } else if (stringValue.contains("SingleSelect")) {
        return FieldType.SingleSelect;
      } else if (stringValue.contains("MultiSelect")) {
        return FieldType.MultiSelect;
      } else if (stringValue.contains("DatePicker")) {
        return FieldType.DatePicker;
      } else
        return null;
    } else
      return null;
  }
}
