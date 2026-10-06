import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tudee/core/theme/app_theme.dart';
import 'package:tudee/features/home/home.dart';
import 'package:tudee/data/services/local_storage_service.dart';
import 'package:tudee/data/services/task_service.dart';
import 'package:tudee/features/welcome/welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await Hive.initFlutter();
  await TaskService.init();
  runApp(MyApp(userName: LocalStorageService.getUserName()));
}

class MyApp extends StatelessWidget {
  /// The saved user name, or null when the user hasn't signed in yet.
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
