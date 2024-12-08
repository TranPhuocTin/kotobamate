import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/vocabulary_service.dart';
import 'package:kotobamate/features/vocabulary/presentation/cubit/vocabulary_state.dart';

class VocabularyCubit extends Cubit<VocabularyState> {
  final VocabularyService _vocabularyService;
  
  VocabularyCubit({
    required VocabularyService vocabularyService,
  }) : _vocabularyService = vocabularyService,
       super(VocabularyInitial());

  Future<void> processImage({
    required int folderId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      emit(VocabularyLoading());
      
      await _vocabularyService.processImage(source: source);
      await _vocabularyService.saveVocabularies(folderId);
      
      final vocabularies = await _vocabularyService.getVocabulariesByFolder(folderId);
      
      emit(VocabularyLoaded(vocabularies: vocabularies));
    } catch (e) {
      emit(VocabularyError(message: e.toString()));
    }
  }

  Future<void> loadVocabularies(int folderId) async {
    try {
      emit(VocabularyLoading());
      
      final vocabularies = await _vocabularyService.getVocabulariesByFolder(folderId);
      
      emit(VocabularyLoaded(vocabularies: vocabularies));
    } catch (e) {
      emit(VocabularyError(message: e.toString()));
    }
  }

  Future<void> loadVocabulariesFromFolders(List<String> folderIds) async {
    try {
      emit(VocabularyLoading());
      final Map<String, String> allVocabularies = {};
      
      for (final folderId in folderIds) {
        final vocabularies = await _vocabularyService.getVocabulariesByFolder(int.parse(folderId));
        allVocabularies.addAll(vocabularies);
      }
      
      emit(VocabularyLoaded(vocabularies: allVocabularies));
    } catch (e) {
      emit(VocabularyError(message: e.toString()));
    }
  }
} 