import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/folder.dart';
import '../cubit/home_cubit.dart';

class SelectFolderDialog extends StatefulWidget {
  const SelectFolderDialog({super.key});

  @override
  State<SelectFolderDialog> createState() => _SelectFolderDialogState();
}

class _SelectFolderDialogState extends State<SelectFolderDialog> {
  List<String> selectedFolderIds = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Folders'),
      content: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(child: Text(state.message));
          }

          if (state is HomeLoaded) {
            if (state.folders.isEmpty) {
              return const Center(
                child: Text('No folders available'),
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.folders.length,
                itemBuilder: (context, index) {
                  final folder = state.folders[index];
                  return CheckboxListTile(
                    title: Text(folder.name),
                    subtitle: Text('${folder.wordCount} từ'),
                    value: selectedFolderIds.contains(folder.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedFolderIds.add(folder.id);
                        } else {
                          selectedFolderIds.remove(folder.id);
                        }
                      });
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedFolderIds.isEmpty
              ? null
              : () {
                  Navigator.pop(context, selectedFolderIds);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
          ),
          child: const Text('Start Game'),
        ),
      ],
    );
  }
} 