import 'package:equatable/equatable.dart';
import 'package:kotobamate/features/vocabulary/domain/entities/vocabulary.dart';

abstract class VocabularyState extends Equatable {
  const VocabularyState();

  @override
  List<Object> get props => [];
}

class VocabularyInitial extends VocabularyState {}

class VocabularyLoading extends VocabularyState {}

class VocabularyLoaded extends VocabularyState {
  final Map<String, String> vocabularies;

  const VocabularyLoaded({required this.vocabularies});

  @override
  List<Object> get props => [vocabularies];
}

class VocabularyError extends VocabularyState {
  final String message;

  const VocabularyError({required this.message});

  @override
  List<Object> get props => [message];
} 