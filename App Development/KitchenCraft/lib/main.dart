// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/signup_page.dart';
import 'features/home/presentation/home_page.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

late io.Socket socket;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Activate Firebase App Check with the debug provider during development/emulator runs.
  // This prevents the "No AppCheckProvider installed" exceptions while developing.
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      // webProvider can be set to RecaptchaV3Provider('<SITE_KEY>') if you configure web App Check.
    );
  } catch (e) {
    // If activation fails, log and continue for development.
    print('Firebase App Check activation skipped or failed in dev: $e');
  }
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await Hive.initFlutter();
  await Hive.openBox('chatHistoryBox'); //open the Hive box for chat history
  await Hive.openBox('kitchenCraftBox'); // Local cache box
  socket = io.io('https://your-backend-url.com', <String, dynamic>{ // Replace with your backend URL
    'transports': ['websocket'],
  });
  socket.onConnect((_) => print('WebSocket connected'));
  socket.onDisconnect((_) => print('WebSocket disconnected'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KitchenCraft',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const LoginPage(),
      routes: {
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}