import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/folder.dart';
import '../../data/database_helper.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final _databaseHelper = DatabaseHelper.instance;

  HomeCubit() : super(HomeInitial()) {
    loadFolders();
  }

  Future<void> loadFolders() async {
    try {
      emit(HomeLoading());
      final folders = await _databaseHelper.getAllFolders();
      print('Loaded folders with word counts: ${folders.map((f) => '${f.name}: ${f.wordCount}')}');
      emit(HomeLoaded(folders));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> createFolder(String name) async {
    try {
      emit(HomeLoading());
      final newFolder = Folder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: DateTime.now(),
        wordCount: 0,
      );

      await _databaseHelper.createFolder(newFolder);
      loadFolders();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> deleteFolder(String id) async {
    try {
      emit(HomeLoading());
      await _databaseHelper.deleteFolder(id);
      loadFolders();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> updateFolder(String id, String newName) async {
    try {
      emit(HomeLoading());
      await _databaseHelper.updateFolder(id, newName);
      loadFolders();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
