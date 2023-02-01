import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/screens/home_screen.dart';
import 'package:yo_berry_2/splash_screen.dart';


Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print(message.data);
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  runApp(yo_berry_2());
}
// options: FirebaseOptions(
// apiKey: "AIzaSyBKEQcF0E8FDz-RCMI6IZfHUa7dh3jDw-E",
// authDomain: "yo-berry.firebaseapp.com",
// projectId: "yo-berry",
// storageBucket: "yo-berry.appspot.com",
// messagingSenderId: "953598410400",
// appId: "1:953598410400:web:d02b9860ceaab226e493c5",
// measurementId: "G-EZ290SCMQ4")

class yo_berry_2 extends StatelessWidget {
  //const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,

      home: AnimatedSplashScreen(
        splash: Container(
          height: 500,
          width: 300,
          child: FittedBox(
            child: Image.asset(
              'assets/images/yo_berries_logo_fb-r.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        duration: 3000,
        nextScreen: Splash_Screen(),
      ),
    );
  }
}
// class MyCustomScrollBehavior extends MaterialScrollBehavior {
//   // Override behavior methods and getters like dragDevices
//   @override
//   Set<PointerDeviceKind> get dragDevices => {
//     PointerDeviceKind.touch,
//     PointerDeviceKind.mouse,
//   };
// }