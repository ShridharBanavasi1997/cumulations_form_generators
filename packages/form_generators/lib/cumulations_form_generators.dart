import 'package:build/build.dart';

import 'src/form_generator.dart';

Builder cumulationFormGenerators(BuilderOptions options) =>
    FormGeneratorBuilder(FormGenerator());
