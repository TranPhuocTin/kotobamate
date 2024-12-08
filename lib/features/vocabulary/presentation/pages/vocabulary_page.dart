import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kotobamate/features/home/domain/entities/folder.dart';
import 'package:kotobamate/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:kotobamate/features/vocabulary/presentation/cubit/vocabulary_cubit.dart';
import 'package:kotobamate/features/vocabulary/presentation/cubit/vocabulary_state.dart';
import 'package:kotobamate/features/vocabulary/presentation/widgets/vocabulary_list_item.dart';

class VocabularyPage extends StatelessWidget {
  final int folderId;

  const VocabularyPage({
    Key? key,
    required this.folderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyCubit, VocabularyState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Vocabularies'),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  context.read<VocabularyCubit>().processImage(
                    folderId: folderId,
                    source: ImageSource.camera,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: () {
                  context.read<VocabularyCubit>().processImage(
                    folderId: folderId,
                    source: ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(VocabularyState state) {
    if (state is VocabularyLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is VocabularyError) {
      return Center(child: Text(state.message));
    }
    
    if (state is VocabularyLoaded) {
      return ListView.builder(
        itemCount: state.vocabularies.length,
        itemBuilder: (context, index) {
          final entry = state.vocabularies.entries.elementAt(index);
          return ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value),
          );
        },
      );
    }
    
    return const Center(child: Text('No vocabularies yet'));
  }
} 