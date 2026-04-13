import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:physigest/core/storage/local_storage.dart';
import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_event.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';

import 'package:physigest/features/settings/domain/usecases/settings_usecases.dart';
import 'package:physigest/features/schedule/domain/repositories/i_schedule_repository.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetPaymentMethodsUseCase _getPaymentMethodsUseCase;
  final GetDashboardPreferencesUseCase _getDashboardPreferencesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final CreatePaymentMethodUseCase _createPaymentMethodUseCase;
  final UpdatePaymentMethodUseCase _updatePaymentMethodUseCase;
  final DeletePaymentMethodUseCase _deletePaymentMethodUseCase;
  final UpdateDashboardPreferencesUseCase _updateDashboardPreferencesUseCase;
  final IScheduleRepository _scheduleRepository;
  final LocalStorage _localStorage;
  final _uuid = const Uuid();

  SettingsBloc(
    this._getCategoriesUseCase,
    this._getPaymentMethodsUseCase,
    this._getDashboardPreferencesUseCase,
    this._createCategoryUseCase,
    this._updateCategoryUseCase,
    this._deleteCategoryUseCase,
    this._createPaymentMethodUseCase,
    this._updatePaymentMethodUseCase,
    this._deletePaymentMethodUseCase,
    this._updateDashboardPreferencesUseCase,
    this._scheduleRepository,
    this._localStorage,
  ) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateDashboardPreferences>(_onUpdateDashboardPreferences);
    on<AddAttendanceCategory>(_onAddAttendanceCategory);
    on<UpdateAttendanceCategory>(_onUpdateAttendanceCategory);
    on<DeleteAttendanceCategory>(_onDeleteAttendanceCategory);
    on<AddPaymentMethod>(_onAddPaymentMethod);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
    on<DeleteAgendaLock>(_onDeleteAgendaLock);
    on<ClearSettingsMessage>(_onClearSettingsMessage);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final results = await Future.wait([
        _getCategoriesUseCase(),
        _getPaymentMethodsUseCase(),
        _getDashboardPreferencesUseCase(),
        _scheduleRepository.getAgendaLocks(),
      ]);

      final categories = results[0] as List<AttendanceCategory>;
      final paymentMethods = results[1] as List<PaymentMethod>;
      final dashboardPreferences = results[2] as DashboardPreferences;
      final agendaLocks = results[3] as List<AgendaLock>;

      final user = await _localStorage.getUser();
      final userEmail = user?.email ?? 'fisioterapeuta@physigest.com';

      emit(
        SettingsLoaded(
          userEmail: userEmail,
          categories: categories,
          paymentMethods: paymentMethods,
          dashboardPreferences: dashboardPreferences,
          agendaLocks: agendaLocks,
        ),
      );
    } catch (e) {
      emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateDashboardPreferences(
    UpdateDashboardPreferences event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        final updatedPreferences = await _updateDashboardPreferencesUseCase(event.preferences);
        emit(currentState.copyWith(
          dashboardPreferences: updatedPreferences,
          successMessage: 'Preferências atualizadas!',
        ));
      } catch (e) {
        emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onAddAttendanceCategory(
    AddAttendanceCategory event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        final user = await _localStorage.getUser();
        final userId = user?.id ?? '';
        
        final newCategory = AttendanceCategory(
          id: _uuid.v4(),
          name: event.name,
          duration: event.duration,
          userId: userId,
        );
        final createdCategory = await _createCategoryUseCase(newCategory);
        emit(
          currentState.copyWith(
            categories: [...currentState.categories, createdCategory],
            successMessage: 'Categoria adicionada!',
          ),
        );
      } catch (e) {
        emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onUpdateAttendanceCategory(
    UpdateAttendanceCategory event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _updateCategoryUseCase(event.category);
        final updatedCategories = currentState.categories.map((c) {
          return c.id == event.category.id ? event.category : c;
        }).toList();
        emit(currentState.copyWith(
          categories: updatedCategories,
          successMessage: 'Categoria atualizada!',
        ));
      } catch (e) {
        emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onDeleteAttendanceCategory(
    DeleteAttendanceCategory event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _deleteCategoryUseCase(event.id);
        final filteredCategories = currentState.categories
            .where((c) => c.id != event.id)
            .toList();
        emit(currentState.copyWith(
          categories: filteredCategories,
          successMessage: 'Categoria removida!',
        ));
      } catch (e) {
        emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onAddPaymentMethod(
    AddPaymentMethod event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        final newMethod = PaymentMethod(
          id: _uuid.v4(),
          name: event.name,
          userId: '',
        );
        final createdMethod = await _createPaymentMethodUseCase(newMethod);
        emit(
          currentState.copyWith(
            paymentMethods: [...currentState.paymentMethods, createdMethod],
            successMessage: 'Metodo de pagamento adicionado!',
          ),
        );
      } catch (e) {
        emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _updatePaymentMethodUseCase(event.method);
        final updatedMethods = currentState.paymentMethods.map((m) {
          return m.id == event.method.id ? event.method : m;
        }).toList();
        emit(currentState.copyWith(
          paymentMethods: updatedMethods,
          successMessage: 'Metodo atualizado!',
        ));
      } catch (e) {
        emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _deletePaymentMethodUseCase(event.id);
        final filteredMethods = currentState.paymentMethods
            .where((m) => m.id != event.id)
            .toList();
        emit(currentState.copyWith(
          paymentMethods: filteredMethods,
          successMessage: 'Metodo removido!',
        ));
      } catch (e) {
        emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onDeleteAgendaLock(
    DeleteAgendaLock event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      try {
        await _scheduleRepository.deleteAgendaLock(event.id);
        final updatedLocks = currentState.agendaLocks
            .where((l) => l.id != event.id)
            .toList();
        
        emit(currentState.copyWith(
          agendaLocks: updatedLocks,
          successMessage: 'Bloqueio removido com sucesso!',
        ));
      } catch (e) {
        emit(SettingsError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onClearSettingsMessage(
    ClearSettingsMessage event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(clearMessage: true));
    }
  }
}
