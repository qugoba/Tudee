import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tudee/core/theme/app_theme.dart';
import 'package:tudee/firebase_options.dart';
import 'package:tudee/features/home/home.dart';
import 'package:tudee/data/services/local_storage_service.dart';
import 'package:tudee/features/welcome/welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(userName: LocalStorageService.getUserName()));
}

class MyApp extends StatelessWidget {
  final String? userName;

  const MyApp({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    final name = userName;

    return MaterialApp(
      title: 'Tudee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: name == null ? const Welcome() : HomeScreen(userName: name),
    );
  }
}
