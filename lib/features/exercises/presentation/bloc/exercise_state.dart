import 'package:equatable/equatable.dart';
import '../../domain/models/exercise.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();

  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<Exercise> exercises;
  final String? searchQuery;
  final String? selectedCategory;

  const ExerciseLoaded({
    required this.exercises,
    this.searchQuery,
    this.selectedCategory,
  });

  ExerciseLoaded copyWith({
    List<Exercise>? exercises,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ExerciseLoaded(
      exercises: exercises ?? this.exercises,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [exercises, searchQuery, selectedCategory];
}

class ExerciseError extends ExerciseState {
  final String message;

  const ExerciseError(this.message);

  @override
  List<Object?> get props => [message];
}
