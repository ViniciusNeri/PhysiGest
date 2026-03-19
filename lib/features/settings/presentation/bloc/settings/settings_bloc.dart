import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_event.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final _uuid = const Uuid();

  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateDashboardPreferences>(_onUpdateDashboardPreferences);
    on<AddAttendanceCategory>(_onAddAttendanceCategory);
    on<UpdateAttendanceCategory>(_onUpdateAttendanceCategory);
    on<DeleteAttendanceCategory>(_onDeleteAttendanceCategory);
    on<AddPaymentMethod>(_onAddPaymentMethod);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      // Mock data load
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const SettingsLoaded(
        userEmail: 'fisioterapeuta@physigest.com',
        categories: [
          AttendanceCategory(id: '1', name: 'Avaliação', isActive: true),
          AttendanceCategory(id: '2', name: 'Pilates', isActive: true),
          AttendanceCategory(id: '3', name: 'Fisioterapia Traumato-Ortopédica', isActive: true),
        ],
        paymentMethods: [
          PaymentMethod(id: '1', name: 'Pix', isActive: true),
          PaymentMethod(id: '2', name: 'Cartão de Crédito', isActive: true),
          PaymentMethod(id: '3', name: 'Dinheiro', isActive: true),
        ],
        dashboardPreferences: DashboardPreferences(),
      ));
    } catch (e) {
      emit(SettingsError('Erro ao carregar configurações: $e'));
    }
  }

  void _onUpdateDashboardPreferences(
    UpdateDashboardPreferences event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(dashboardPreferences: event.preferences));
    }
  }

  void _onAddAttendanceCategory(
    AddAttendanceCategory event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newCategory = AttendanceCategory(
        id: _uuid.v4(),
        name: event.name,
      );
      emit(currentState.copyWith(
        categories: [...currentState.categories, newCategory],
      ));
    }
  }

  void _onUpdateAttendanceCategory(
    UpdateAttendanceCategory event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedCategories = currentState.categories.map((c) {
        return c.id == event.category.id ? event.category : c;
      }).toList();
      emit(currentState.copyWith(categories: updatedCategories));
    }
  }

  void _onDeleteAttendanceCategory(
    DeleteAttendanceCategory event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final filteredCategories = currentState.categories
          .where((c) => c.id != event.id)
          .toList();
      emit(currentState.copyWith(categories: filteredCategories));
    }
  }

  void _onAddPaymentMethod(
    AddPaymentMethod event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newMethod = PaymentMethod(
        id: _uuid.v4(),
        name: event.name,
      );
      emit(currentState.copyWith(
        paymentMethods: [...currentState.paymentMethods, newMethod],
      ));
    }
  }

  void _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedMethods = currentState.paymentMethods.map((m) {
        return m.id == event.method.id ? event.method : m;
      }).toList();
      emit(currentState.copyWith(paymentMethods: updatedMethods));
    }
  }

  void _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<SettingsState> emit,
  ) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final filteredMethods = currentState.paymentMethods
          .where((m) => m.id != event.id)
          .toList();
      emit(currentState.copyWith(paymentMethods: filteredMethods));
    }
  }
}
