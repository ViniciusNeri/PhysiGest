import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/core/utils/app_alerts.dart';
import 'package:physigest/core/widgets/loading_overlay.dart';
import 'package:physigest/features/patient_booking/presentation/bloc/patient_booking_bloc.dart';
import 'package:physigest/features/patient_booking/presentation/bloc/patient_booking_event.dart';
import 'package:physigest/features/patient_booking/presentation/bloc/patient_booking_state.dart';

class PatientBookingScreen extends StatelessWidget {
  final String userId;
  const PatientBookingScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientBookingBloc>()..add(LoadBookingData(userId)),
      child: const _PatientBookingView(),
    );
  }
}

class _PatientBookingView extends StatefulWidget {
  const _PatientBookingView();

  @override
  State<_PatientBookingView> createState() => _PatientBookingViewState();
}

class _PatientBookingViewState extends State<_PatientBookingView> {
  final List<String> _pin = [];

  void _showPinDialog(BuildContext context, DateTime slot) {
    final bookingBloc = context.read<PatientBookingBloc>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "PIN",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        return BlocProvider.value(
          value: bookingBloc,
          child: StatefulBuilder(
            builder: (context, setModalState) {
            return Center(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_person_rounded, size: 48, color: AppTheme.primaryColor),
                      const SizedBox(height: 16),
                      const Text(
                        "Identificação",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Selecione o atendimento e digite seu PIN",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      // Dropdown de Categorias Premium
                      BlocBuilder<PatientBookingBloc, PatientBookingState>(
                        builder: (context, state) {
                          return _buildPremiumDropdown<String>(
                            label: "Qual o atendimento?",
                            value: state.selectedCategoryId ?? "",
                            icon: Icons.medical_services_outlined,
                            items: [
                              const DropdownMenuItem(value: "", child: Text("Clique para escolher...", style: TextStyle(color: Colors.black26, fontSize: 13))),
                              ...state.categories.map((cat) => DropdownMenuItem(
                                value: cat['id'].toString(),
                                child: Text(cat['name']),
                              )),
                            ],
                            onChanged: (val) {
                              if (val != null && val.isNotEmpty) {
                                context.read<PatientBookingBloc>().add(SelectBookingCategory(val));
                                setModalState(() {});
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 15,
                            height: 15,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _pin.length > index ? AppTheme.primaryColor : Colors.black12,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          if (index == 9) return const SizedBox();
                          if (index == 10) return _buildPinKey(context, "0", setModalState);
                          if (index == 11) return _buildPinKey(context, "DEL", setModalState, isDelete: true);
                          return _buildPinKey(context, (index + 1).toString(), setModalState);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Widget _buildPinKey(BuildContext context, String val, StateSetter setModalState, {bool isDelete = false}) {
    return InkWell(
      onTap: () {
        setModalState(() {
          if (isDelete) {
            if (_pin.isNotEmpty) _pin.removeLast();
          } else if (_pin.length < 4) {
            _pin.add(val);
          }
        });
        
        if (_pin.length == 4) {
          final pinStr = _pin.join();
          Navigator.pop(context);
          context.read<PatientBookingBloc>().add(ConfirmBooking(pin: pinStr));
          _pin.clear();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: isDelete 
          ? const Icon(Icons.backspace_rounded, size: 20, color: Color(0xFF94A3B8))
          : Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildPremiumDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(
                icon ?? Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Fundo mais escuro para destacar o card no desktop
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 800;

          return BlocConsumer<PatientBookingBloc, PatientBookingState>(
            listener: (context, state) {
              if (state.status == PatientBookingStatus.failure) {
                AppAlerts.error(context, state.errorMessage!);
              } else if (state.status == PatientBookingStatus.success) {
                AppAlerts.success(context, state.successMessage!);
              }
            },
            builder: (context, state) {
              return LoadingOverlay(
                isLoading: state.status == PatientBookingStatus.loading,
                message: "Processando reserva...",
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF8FAFC),
                        AppTheme.primaryColor.withValues(alpha: 0.08),
                        const Color(0xFFF1F5F9),
                      ],
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Container(
                        margin: isDesktop ? const EdgeInsets.symmetric(vertical: 40) : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: isDesktop ? BorderRadius.circular(32) : BorderRadius.zero,
                          boxShadow: isDesktop 
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 60, offset: const Offset(0, 30))] 
                            : null,
                        ),
                        child: ClipRRect(
                          borderRadius: isDesktop ? BorderRadius.circular(32) : BorderRadius.zero,
                          child: SafeArea(
                            child: CustomScrollView(
                              slivers: [
                                _buildStickyHeader(context, state, isDesktop),
                                SliverPadding(
                                  padding: const EdgeInsets.all(24),
                                  sliver: _buildSlotsGrid(context, state, constraints.maxWidth),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context, PatientBookingState state, bool isDesktop) {
    final months = [
      "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
      "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
    ];
    final currentYear = DateTime.now().year;
    final years = [currentYear, currentYear + 1];

    // Calcula os dias do mês selecionado (focusedDate)
    final firstDayOfMonth = DateTime(state.focusedDate.year, state.focusedDate.month, 1);
    final lastDayOfMonth = DateTime(state.focusedDate.year, state.focusedDate.month + 1, 0);
    
    // Se o mês for o atual, começamos de hoje. Se for futuro, começamos do dia 1.
    final bool isCurrentMonth = state.focusedDate.year == DateTime.now().year && 
                               state.focusedDate.month == DateTime.now().month;
    
    final startDate = isCurrentMonth ? DateTime.now() : firstDayOfMonth;
    final totalDays = lastDayOfMonth.day - startDate.day + 1;

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, isDesktop ? 48 : 32, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isDesktop 
            ? const BorderRadius.vertical(bottom: Radius.circular(32)) 
            : const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Agendamento de Consulta",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5),
            ),
            const Text(
              "Escolha o melhor dia e horário para seu atendimento",
              style: TextStyle(color: Colors.black45, fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Seletores de Mês e Ano Premium
            Row(
              children: [
                Expanded(
                  child: _buildPremiumDropdown<int>(
                    label: "Mês",
                    value: state.focusedDate.month,
                    items: List.generate(12, (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(months[index]),
                    )),
                    onChanged: (val) {
                      if (val != null) {
                        context.read<PatientBookingBloc>().add(ChangeBookingMonth(month: val, year: state.focusedDate.year));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPremiumDropdown<int>(
                    label: "Ano",
                    value: state.focusedDate.year,
                    items: years.map((y) => DropdownMenuItem(
                      value: y,
                      child: Text(y.toString()),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        context.read<PatientBookingBloc>().add(ChangeBookingMonth(month: state.focusedDate.month, year: val));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 100,
              child: ScrollConfiguration(
                behavior: _CustomScrollBehavior(),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: totalDays,
                  itemBuilder: (context, index) {
                    final date = startDate.add(Duration(days: index));
                    final isSelected = DateUtils.isSameDay(date, state.selectedDate);
                    
                    return GestureDetector(
                      onTap: () => context.read<PatientBookingBloc>().add(SelectBookingDate(date)),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))] : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE', 'pt_BR').format(date).toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white70 : Colors.black26,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsGrid(BuildContext context, PatientBookingState state, double maxWidth) {
    if (state.availableSlots.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Icon(Icons.event_busy_rounded, size: 64, color: Colors.black12),
                SizedBox(height: 16),
                Text("Nenhum horário disponível para este dia.", style: TextStyle(color: Colors.black45)),
              ],
            ),
          ),
        ),
      );
    }

    final int crossAxisCount = maxWidth > 800 ? 5 : 3;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2.0,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final slot = state.availableSlots[index];
          final isSelected = state.selectedSlot == slot;

          return InkWell(
            onTap: () {
              context.read<PatientBookingBloc>().add(SelectBookingSlot(slot));
              _showPinDialog(context, slot);
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Center(
                child: Text(
                  DateFormat('HH:mm').format(slot),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
        childCount: state.availableSlots.length,
      ),
    );
  }
}

class _CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
