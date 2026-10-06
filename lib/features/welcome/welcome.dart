import 'package:flutter/material.dart';
import 'package:tudee/core/theme/app_theme.dart';
import 'package:tudee/features/home/home.dart';
import 'package:tudee/data/services/local_storage_service.dart';
import 'package:tudee/core/widgets/tudee_app_bar.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await LocalStorageService.saveUserName(name);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(userName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TudeeAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Let's get started",
                style: TextStyle(
                  fontSize: 28,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'What should we call you?',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: const InputDecoration(hintText: 'Your name'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
