import 'package:flutter/material.dart';
import 'package:kotobamate/features/vocabulary/domain/entities/vocabulary.dart';

class VocabularyListItem extends StatelessWidget {
  final Vocabulary vocabulary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VocabularyListItem({
    super.key,
    required this.vocabulary,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          vocabulary.word,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(vocabulary.meaning),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: Colors.blue,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
} 