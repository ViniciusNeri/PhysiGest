import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'exercise_event.dart';
import 'exercise_state.dart';
import '../../domain/models/exercise.dart';

@lazySingleton
class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  // Mock inicial de exercícios em vídeo reais ou representativos
  final List<Exercise> _allExercises = [
    const Exercise(
      id: '1',
      title: 'Mobilidade Cervical',
      description:
          'Movimentos suaves de rotação e inclinação para aliviar tensão no pescoço. Ideal para quem trabalha horas no computador.',
      videoUrl: 'https://www.youtube.com/watch?v=placeholder1',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      category: 'Cervical',
      recommendedRepetitions: '3 séries de 10 movimentos',
    ),
    const Exercise(
      id: '2',
      title: 'Fortalecimento Manguito Rotador',
      description:
          'Uso de elástico ou mola para rotação externa. Auxilia muito na estabilidade e evita pinçamentos no ombro.',
      videoUrl: 'https://www.youtube.com/watch?v=placeholder2',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      category: 'Ombro',
      recommendedRepetitions: '3 séries de 15 repetições (leve)',
    ),
    const Exercise(
      id: '3',
      title: 'Ponte Pélvica Clássica',
      description:
          'Deitado de barriga para cima, elevar o quadril ativando os glúteos e abdômen. Ajuda a estabilizar a lombar.',
      videoUrl: 'https://www.youtube.com/watch?v=placeholder3',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      category: 'Lombar',
      recommendedRepetitions: '3 séries de 12 levantamentos',
    ),
    const Exercise(
      id: '4',
      title: 'Alongamento Isquiotibiais',
      description:
          'Deitado, elevar uma perna estendida puxando a ponta do pé com toalha ou faixa.',
      videoUrl: 'https://www.youtube.com/watch?v=placeholder4',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      category: 'Membros Inferiores',
      recommendedRepetitions: 'Sustentar 40 segundos, 3x cada perna',
    ),
    const Exercise(
      id: '5',
      title: 'Respiração Diafragmática',
      description:
          'Estimulação de oxigenação e expansão da caixa torácica inferior com as mãos sob as costelas.',
      videoUrl: 'https://www.youtube.com/watch?v=placeholder5',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      category: 'Respiratório',
      recommendedRepetitions: '10 respirações profundas relaxantes',
    ),
  ];

  ExerciseBloc() : super(ExerciseInitial()) {
    on<LoadExercises>(_onLoadExercises);
    on<AddExercise>(_onAddExercise);
    on<UpdateExercise>(_onUpdateExercise);
    on<DeleteExercise>(_onDeleteExercise);
    on<SearchExercises>(_onSearchExercises);
    on<FilterByCategory>(_onFilterByCategory);
  }

  void _onLoadExercises(LoadExercises event, Emitter<ExerciseState> emit) {
    emit(ExerciseLoading());
    // Simulando tempo de resposta
    emit(ExerciseLoaded(exercises: List.from(_allExercises)));
  }

  void _onAddExercise(AddExercise event, Emitter<ExerciseState> emit) {
    if (state is ExerciseLoaded) {
      _allExercises.add(event.exercise);
      final currentState = state as ExerciseLoaded;

      emit(
        ExerciseLoaded(
          exercises: _getFilteredExercises(
            currentState.searchQuery,
            currentState.selectedCategory,
          ),
          searchQuery: currentState.searchQuery,
          selectedCategory: currentState.selectedCategory,
        ),
      );
    }
  }

  void _onUpdateExercise(UpdateExercise event, Emitter<ExerciseState> emit) {
    if (state is ExerciseLoaded) {
      final index = _allExercises.indexWhere((e) => e.id == event.exercise.id);
      if (index != -1) {
        _allExercises[index] = event.exercise;
        final currentState = state as ExerciseLoaded;
        emit(
          ExerciseLoaded(
            exercises: _getFilteredExercises(
              currentState.searchQuery,
              currentState.selectedCategory,
            ),
            searchQuery: currentState.searchQuery,
            selectedCategory: currentState.selectedCategory,
          ),
        );
      }
    }
  }

  void _onDeleteExercise(DeleteExercise event, Emitter<ExerciseState> emit) {
    if (state is ExerciseLoaded) {
      _allExercises.removeWhere((e) => e.id == event.exerciseId);
      final currentState = state as ExerciseLoaded;
      emit(
        ExerciseLoaded(
          exercises: _getFilteredExercises(
            currentState.searchQuery,
            currentState.selectedCategory,
          ),
          searchQuery: currentState.searchQuery,
          selectedCategory: currentState.selectedCategory,
        ),
      );
    }
  }

  void _onSearchExercises(SearchExercises event, Emitter<ExerciseState> emit) {
    if (state is ExerciseLoaded) {
      final currentState = state as ExerciseLoaded;
      emit(
        ExerciseLoaded(
          exercises: _getFilteredExercises(
            event.query,
            currentState.selectedCategory,
          ),
          searchQuery: event.query,
          selectedCategory: currentState.selectedCategory,
        ),
      );
    }
  }

  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<ExerciseState> emit,
  ) {
    if (state is ExerciseLoaded) {
      final currentState = state as ExerciseLoaded;
      emit(
        ExerciseLoaded(
          exercises: _getFilteredExercises(
            currentState.searchQuery,
            event.category,
          ),
          searchQuery: currentState.searchQuery,
          selectedCategory: event.category,
        ),
      );
    }
  }

  List<Exercise> _getFilteredExercises(String? query, String? category) {
    return _allExercises.where((e) {
      final matchesQuery =
          query == null ||
          query.isEmpty ||
          e.title.toLowerCase().contains(query.toLowerCase());
      final matchesCategory =
          category == null || category == 'Todos' || e.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }
}
