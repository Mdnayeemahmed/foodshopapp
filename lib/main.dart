import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foodshopapp/Screen/splashscreen.dart';
import 'package:foodshopapp/utilities/notification_handler.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);


  runApp(MyApp());
}
Future backgroundHandler(RemoteMessage msg) async {}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {

    super.initState();

    LocalNotificationService.initialize();

    // To initialise the sg
    FirebaseMessaging.instance.getInitialMessage().then((message) {

    });

    // To initialise when app is not terminated
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        LocalNotificationService.display(message);
      }
    });

    // To handle when app is open in
    // user divide and heshe is using it
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("on message opened app");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellowAccent),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

