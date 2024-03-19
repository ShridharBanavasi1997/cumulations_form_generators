import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

class ModelVisitor extends SimpleElementVisitor<dynamic> {
  String className = "";

  Map<String, Pair> fields = <String, Pair>{};
  Map<String, dynamic> metaData = {};

  @override
  dynamic visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();

    // DartType ends with '*', which needs to be eliminated
    // for the generated code to be accurate.
    className = elementReturnType.replaceFirst('*', '');
  }

  @override
  dynamic visitFieldElement(FieldElement element) {
    final elementType = element.type.toString();

    // DartType ends with '*', which needs to be eliminated
    // for the generated code to be accurate.
    fields[element.name] =
        Pair(elementType.replaceFirst('*', ''), element.metadata);
    var data = "";
    element.metadata.forEach((element) {
      dynamic v =
          element.computeConstantValue()?.getField("type")?.toStringValue();
      data =
          "$v, ${element.computeConstantValue()},${element.source}, ${element.toString()}";
    });
    metaData[element.name] = data;
  }
}

class Pair {
  dynamic first;
  dynamic last;

  Pair(this.first, this.last);
}
