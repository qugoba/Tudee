import 'package:flutter/material.dart';

class TudeeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const TudeeAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Tudee'), actions: actions);
  }
}
