
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recetapp/pages/login_page.dart';
import 'package:recetapp/pages/navigation_bar_page.dart';
import 'package:recetapp/pages/register_page.dart';
import 'package:recetapp/pages/splash_page.dart';
import 'package:recetapp/pages/update_profile_page.dart';

import 'firebase_options.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashPage(),
    );
  }
}
