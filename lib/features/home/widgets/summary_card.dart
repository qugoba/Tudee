import 'package:flutter/material.dart';
import 'package:tudee/core/theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  final String userName;
  final int doneCount;
  final int todoCount;

  const SummaryCard({
    super.key,
    required this.userName,
    required this.doneCount,
    required this.todoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome $userName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    color: AppColors.done,
                    count: doneCount,
                    label: 'Done',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatTile(
                    color: AppColors.todo,
                    count: todoCount,
                    label: 'To-Do',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final Color color;
  final int count;
  final String label;

  const _StatTile({
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.loop, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
