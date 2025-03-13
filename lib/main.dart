import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ticket_booking/Intro/IntroScreen.dart';
import 'package:ticket_booking/Screens/BottomNavigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print("Firebase Initialization Error: $e");
    }
  }
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(     
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,       
      ),
      debugShowCheckedModeBanner: false,
      home: //IntroScreen(),
       Bottomnavigation(),
    );
  }
}

//  cd C:\Users\Softnova\Downloads\scrcpy-win64-v2.7\scrcpy-win64-v2.7
//  scrcpy --always-on-top
