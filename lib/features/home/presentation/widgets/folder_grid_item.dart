import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotobamate/features/home/domain/entities/folder.dart';
import 'package:kotobamate/features/home/presentation/cubit/home_cubit.dart';
import 'package:kotobamate/features/vocabulary/data/repositories/vocabulary_repository.dart';
import 'package:kotobamate/features/vocabulary/presentation/cubit/vocabulary_cubit.dart';
import 'package:kotobamate/features/vocabulary/presentation/pages/vocabulary_page.dart';
import 'package:kotobamate/core/database/sqlite_database.dart';
import 'package:kotobamate/features/vocabulary/services/vocabulary_service.dart';
import 'package:kotobamate/features/home/data/database_helper.dart';

class FolderGridItem extends StatelessWidget {
  final Folder folder;

  const FolderGridItem({
    super.key,
    required this.folder,
  });

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Folder Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context
                    .read<HomeCubit>()
                    .updateFolder(folder.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HomeCubit>().deleteFolder(folder.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      canRequestFocus: false,
      child: Card(
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => VocabularyCubit(
                    vocabularyService: VocabularyService(
                      vocabularyRepository: VocabularyRepository(
                        DatabaseHelper.instance,
                      ),
                    ),
                  )..loadVocabularies(int.parse(folder.id)),
                  child: VocabularyPage(folderId: int.parse(folder.id)),
                ),
              ),
            );

            if (context.mounted) {
              context.read<HomeCubit>().loadFolders();
            }
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                      title: const Text('Edit Folder'),
                      onTap: () {
                        Navigator.pop(context);
                        _showEditDialog(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Delete Folder'),
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder,
                  size: 48,
                  color: Colors.blue[300],
                ),
                const SizedBox(height: 8),
                Text(
                  folder.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${folder.wordCount} words',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
