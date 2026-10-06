import 'package:flutter/material.dart';
import 'package:tudee/core/theme/app_theme.dart';
import 'package:tudee/core/widgets/tudee_app_bar.dart';

/// Form for adding a task, or editing one when [initialTitle] is given.
/// Pops with the trimmed title when saved.
class TaskFormScreen extends StatefulWidget {
  final String? initialTitle;

  const TaskFormScreen({super.key, this.initialTitle});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late final _titleController = TextEditingController(
    text: widget.initialTitle,
  );

  bool get _isEditing => widget.initialTitle != null;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(context, title);
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
              Text(
                _isEditing ? 'Edit Task' : 'Add Task',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  hintText: 'What needs to be done?',
                ),
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
