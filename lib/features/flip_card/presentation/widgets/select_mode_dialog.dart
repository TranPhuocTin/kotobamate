import 'package:flutter/material.dart';

class SelectModeDialog extends StatelessWidget {
  const SelectModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Mode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.arrow_forward, color: Color(0xFF3498DB)),
            title: const Text('Japanese → Vietnamese'),
            onTap: () {
              Navigator.pop(context, true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Color(0xFF3498DB)),
            title: const Text('Vietnamese → Japanese'),
            onTap: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      ),
    );
  }
} 