import 'package:example/subscriber/subscriber_form.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Generator Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Subscriber subscriberForm = Subscriber();

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Form Generator Example',
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              subscriberForm.getView(),
              SizedBox(
                height: 20,
              ),
              TextButton(
                child: const Text('Submit'),
                onPressed: () {
                  print(subscriberForm.getFormData());
                  print(subscriberForm
                      .fromMap(subscriberForm.getFormData())
                      .email);
                },
              )
            ],
          ),
        ));
  }
}
