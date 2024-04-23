import 'package:flutter/material.dart';
import 'package:medrano_ass7/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medrano_ass7/map_screen.dart';

void main() async{
  WidgetsFlutterBinding();
  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );
  runApp(ass7());
}

class ass7 extends StatelessWidget {
  const ass7({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}