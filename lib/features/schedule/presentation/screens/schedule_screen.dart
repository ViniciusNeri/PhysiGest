import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/core/widgets/side_menu.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:physigest/features/schedule/presentation/widgets/add_appointment_dialog.dart';
import 'package:physigest/features/schedule/presentation/widgets/appointment_action_dialog.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:physigest/core/widgets/app_error_view.dart';
import 'package:physigest/core/utils/app_alerts.dart';
import 'package:physigest/core/widgets/loading_overlay.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ScheduleBloc>()..add(LoadSchedule()),
      child: const ScheduleView(),
    );
  }
}

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  static const double hourHeight = 110.0;
  static const int startHour = 6;
  static const int endHour = 22;

  // Função centralizada para abrir o modal de agendamento
  Future<void> _openAddAppointment(
    BuildContext context,
    ScheduleState state,
    DateTime initialDate,
  ) async {
    final result = await showGeneralDialog<Appointment>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: AddAppointmentDialog(
            availablePatients: state.availablePatients,
            activeCategories: state.activeCategories,
            initialDate: initialDate,
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );

    if (result != null && context.mounted) {
      context.read<ScheduleBloc>().add(AddAppointment(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        title: const Text(
          "Agenda",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black45,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // SIDEBAR FIXA
          if (isDesktop)
            Container(
              width: 280,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: _buildSidebar(context),
            ),

          // CONTEÚDO PRINCIPAL (Grade de Horários)
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: BlocConsumer<ScheduleBloc, ScheduleState>(
                    listener: (context, state) {
                      if (state.status == ScheduleStatus.failure && state.errorMessage != null) {
                        AppAlerts.error(context, state.errorMessage!);
                      } else if (state.status == ScheduleStatus.success && state.successMessage != null) {
                        AppAlerts.success(context, state.successMessage!);
                      }
                    },
                    builder: (context, state) {
                      if (state.status == ScheduleStatus.loading && state.appointments.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      if (state.status == ScheduleStatus.failure && state.appointments.isEmpty) {
                        return AppErrorView(
                          message: state.errorMessage ?? "Erro ao carregar agenda",
                          onRetry: () => context.read<ScheduleBloc>().add(LoadSchedule()),
                        );
                      }

                      return LoadingOverlay(
                        isLoading: state.status == ScheduleStatus.loading && state.appointments.isNotEmpty,
                        message: "Sincronizando...",
                        child: _buildBodyContent(context, state),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: () =>
                _openAddAppointment(context, state, state.selectedDate),
            backgroundColor: const Color(0xFF0F172A),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              "Novo Horário",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        final bool isDesktop = MediaQuery.of(context).size.width > 800;
        late DateTime startDate;
        late DateTime endDate;
        late String rangeLabel;

        if (state.viewMode == ScheduleViewMode.day) {
          startDate = state.selectedDate;
          endDate = state.selectedDate;
          rangeLabel = DateFormat(
            "d 'de' MMMM, yyyy",
            'pt_BR',
          ).format(startDate);
        } else if (state.viewMode == ScheduleViewMode.threeDays) {
          startDate = state.selectedDate;
          endDate = state.selectedDate.add(const Duration(days: 2));
          rangeLabel =
              "Dia ${DateFormat('d').format(startDate)} - ${DateFormat('d').format(endDate)} de ${DateFormat('MMMM, yyyy', 'pt_BR').format(endDate)}";
        } else if (state.viewMode == ScheduleViewMode.week) {
          startDate = state.selectedDate.subtract(
            Duration(days: state.selectedDate.weekday % 7),
          ); // Domingo como início
          endDate = startDate.add(const Duration(days: 6));
          rangeLabel =
              "${DateFormat('d').format(startDate)} - ${DateFormat('d').format(endDate)} de ${DateFormat('MMMM, yyyy', 'pt_BR').format(endDate)}";
        } else {
          startDate = DateTime(
            state.selectedDate.year,
            state.selectedDate.month,
            1,
          );
          endDate = DateTime(
            state.selectedDate.year,
            state.selectedDate.month + 1,
            0,
          );
          rangeLabel = DateFormat('MMMM, yyyy', 'pt_BR').format(startDate);
          // Capitalize first letter of month
          rangeLabel = rangeLabel[0].toUpperCase() + rangeLabel.substring(1);
        }

        return Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              if (isDesktop)
                Text(
                  rangeLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                )
              else
                Expanded(
                  child: Text(
                    rangeLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              const SizedBox(width: 12),
              _buildNavButton(Icons.chevron_left_rounded, () {
                DateTime newDate;
                if (state.viewMode == ScheduleViewMode.day) {
                  newDate = state.selectedDate.subtract(
                    const Duration(days: 1),
                  );
                } else if (state.viewMode == ScheduleViewMode.threeDays) {
                  newDate = state.selectedDate.subtract(
                    const Duration(days: 3),
                  );
                } else if (state.viewMode == ScheduleViewMode.week) {
                  newDate = state.selectedDate.subtract(
                    const Duration(days: 7),
                  );
                } else {
                  newDate = DateTime(
                    state.selectedDate.year,
                    state.selectedDate.month - 1,
                    state.selectedDate.day,
                  );
                }
                context.read<ScheduleBloc>().add(SelectDate(newDate));
              }),
              const SizedBox(width: 8),
              _buildNavButton(Icons.chevron_right_rounded, () {
                DateTime newDate;
                if (state.viewMode == ScheduleViewMode.day) {
                  newDate = state.selectedDate.add(const Duration(days: 1));
                } else if (state.viewMode == ScheduleViewMode.threeDays) {
                  newDate = state.selectedDate.add(const Duration(days: 3));
                } else if (state.viewMode == ScheduleViewMode.week) {
                  newDate = state.selectedDate.add(const Duration(days: 7));
                } else {
                  newDate = DateTime(
                    state.selectedDate.year,
                    state.selectedDate.month + 1,
                    state.selectedDate.day,
                  );
                }
                context.read<ScheduleBloc>().add(SelectDate(newDate));
              }),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => context.read<ScheduleBloc>().add(
                  SelectDate(DateTime.now()),
                ),
                child: const Text(
                  "Hoje",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (isDesktop) ...[
                const Spacer(),
                _buildViewToggle(context, state),
              ] else ...[
                const Spacer(),
                // Simplificação pro Mobile (Ícone ou Menu)
                _buildViewToggle(context, state, isMobile: true),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, ScheduleState state) {
    if (state.viewMode == ScheduleViewMode.month) {
      return _buildMonthView(context, state);
    } else {
      return _buildWeeklyTimeline(context, state);
    }
  }

  Widget _buildWeeklyTimeline(BuildContext context, ScheduleState state) {
    List<DateTime> weekDays;

    if (state.viewMode == ScheduleViewMode.day) {
      weekDays = [state.selectedDate];
    } else if (state.viewMode == ScheduleViewMode.threeDays) {
      weekDays =
          List.generate(3, (i) => state.selectedDate.add(Duration(days: i)));
    } else {
      // Semana começa no Domingo
      final startOfWeek = state.selectedDate.subtract(
        Duration(days: state.selectedDate.weekday % 7),
      );
      weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 70),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: weekDays
                  .map((day) => Expanded(child: _buildDayHeader(day)))
                  .toList(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeColumn(),
                  ...weekDays.map(
                    (day) =>
                        Expanded(child: _buildDayColumn(context, state, day)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(BuildContext context, ScheduleState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: state.selectedDate,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerVisible: false, // The custom header handles navigation
        onDaySelected: (selectedDay, focusedDay) {
          // Muda pro modo Dia e seleciona o dia clicado
          context.read<ScheduleBloc>().add(
            ChangeViewMode(ScheduleViewMode.day),
          );
          context.read<ScheduleBloc>().add(SelectDate(selectedDay));
        },
        selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final dayApts = state.appointments
                .where((a) => DateUtils.isSameDay(a.startDate, date))
                .toList();
            if (dayApts.isEmpty) return const SizedBox();

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: dayApts.take(4).map((apt) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(apt.categoryId ?? ''),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayColumn(
    BuildContext context,
    ScheduleState state,
    DateTime day,
  ) {
    final dayApts = state.appointments
        .where((a) => DateUtils.isSameDay(a.startDate, day))
        .toList();

    return GestureDetector(
      behavior: HitTestBehavior
          .opaque, // Garante que o clique seja detectado em toda a área
      onTapUp: (details) {
        // Cálculo matemático da hora clicada
        final double clickY = details.localPosition.dy;
        final int hourClicked = (clickY / hourHeight).floor() + startHour;
        final DateTime tappedDateTime = DateTime(
          day.year,
          day.month,
          day.day,
          hourClicked,
        );

        _openAddAppointment(context, state, tappedDateTime);
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Color(0xFFF8FAFC))),
        ),
        child: Stack(
          children: [
            Column(
              children: List.generate(
                endHour - startHour,
                (index) => Container(
                  height: hourHeight,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9)),
                    ),
                  ),
                ),
              ),
            ),
            ...dayApts.map((apt) {
              // Converter para double (horas + fração de minutos)
              final double start =
                  apt.startDate.hour + (apt.startDate.minute / 60);
              final double end =
                  apt.endDate.hour + (apt.endDate.minute / 60);

              // Cálculo da duração em horas (ex: 1.5 para 1h30min)
              final double duration = end - start;

              // Posição no topo
              final double top = (start - startHour) * hourHeight;

              return Positioned(
                top: top + 4,
                left: 6,
                right: 6,
                height: (duration * hourHeight) - 8,
                child: GestureDetector(
                  onTap: () => _openEditAppointment(context, state, apt),
                  child: _buildAppointmentCard(context, state, apt),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Restante dos widgets auxiliares (_buildDayHeader, _buildAppointmentCard, etc. permanecem iguais)
  Widget _buildDayHeader(DateTime day) {
    bool isToday = DateUtils.isSameDay(day, DateTime.now());
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            DateFormat('EEE', 'pt_BR').format(day).toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isToday ? AppTheme.primaryColor : Colors.black26,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              day.day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isToday
                    ? AppTheme.primaryColor
                    : const Color(0xFF1E293B),
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    ScheduleState state,
    Appointment apt,
  ) {
    Color baseColor = _getCategoryColor(apt.categoryId ?? '');
    String categoryName = 'Atendimento';
    
    if (apt.categoryId != null && apt.categoryId!.isNotEmpty) {
      final found = state.activeCategories.where((c) => c['id'] == apt.categoryId).firstOrNull;
      if (found != null && found['name'] != null) {
        categoryName = found['name'];
      }
    }

    // Altera opacidade dependendo do status
    if (apt.status == 'no_show' || apt.status == 'cancelled') {
      baseColor = baseColor.withValues(alpha: 0.5);
    }

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Detalhe estético: uma esfera clara no canto para dar profundidade
          Positioned(
            right: -10,
            top: -10,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  apt.patientName,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                    shadows: [Shadow(color: Colors.black12, blurRadius: 2)],
                  ),
                ),
                const SizedBox(height: 2),
                // Containerzinho para o horário (estilo Badge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${DateFormat('HH:mm').format(apt.startDate)} - ${DateFormat('HH:mm').format(apt.endDate)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        apt.displayStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    // Icon Button para Avaliar / Status
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dContext) => AppointmentActionDialog(
                            appointment: apt,
                            onSave: (updatedApt) {
                              context.read<ScheduleBloc>().add(
                                UpdateAppointment(updatedApt),
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          apt.status == 'completed'
                              ? Icons.check_circle_rounded
                              : (apt.status == 'no_show' ||
                                        apt.status == 'cancelled'
                                    ? Icons.cancel_rounded
                                    : Icons.fact_check_rounded),
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (apt.status == 'completed')
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    return Container(
      width: 70,
      color: Colors.white,
      child: Column(
        children: List.generate(
          endHour - startHour,
          (index) => Container(
            height: hourHeight,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              "${index + startHour}:00",
              style: const TextStyle(
                color: Colors.black26,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar paciente...",
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: Colors.black26,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "CATEGORIAS",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: BlocBuilder<ScheduleBloc, ScheduleState>(
                builder: (context, state) {
                  if (state.activeCategories.isEmpty) {
                    return const Text("Nenhuma categoria encontrada.",
                        style: TextStyle(fontSize: 12, color: Colors.black38));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.activeCategories.map((c) {
                      return _buildFilterItem(
                          c['name']?.toString() ?? '',
                          _getCategoryColor(c['id']?.toString() ?? ''));
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final Map<String, Color> _categoryColorCache = {};
  static int _colorIndex = 0;

  Color _getCategoryColor(String id) {
    if (id.isEmpty) return AppTheme.primaryColor;
    
    if (_categoryColorCache.containsKey(id)) {
      return _categoryColorCache[id]!;
    }
    
    final colors = [
      AppTheme.primaryColor,
      Colors.teal,
      Colors.orange,
      const Color(0xFF6366F1), // Indigo
      Colors.pink,
      const Color(0xFFEAB308), // Amber mais sofisticado
      Colors.cyan,
      const Color(0xFF8B5CF6), // Violet (DeepPurple)
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFEF4444), // Red
      const Color(0xFF10B981), // Emerald/Green
    ];
    
    final color = colors[_colorIndex % colors.length];
    _categoryColorCache[id] = color;
    _colorIndex++;
    
    return color;
  }

  Widget _buildFilterItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildViewToggle(
    BuildContext context,
    ScheduleState state, {
    bool isMobile = false,
  }) {
    if (isMobile) {
      return PopupMenuButton<ScheduleViewMode>(
        icon: const Icon(Icons.more_vert),
        onSelected: (mode) =>
            context.read<ScheduleBloc>().add(ChangeViewMode(mode)),
        itemBuilder: (context) => [
          const PopupMenuItem(value: ScheduleViewMode.day, child: Text("Dia")),
          const PopupMenuItem(
            value: ScheduleViewMode.threeDays,
            child: Text("3 Dias"),
          ),
          const PopupMenuItem(
            value: ScheduleViewMode.week,
            child: Text("Semana"),
          ),
          const PopupMenuItem(
            value: ScheduleViewMode.month,
            child: Text("Mês"),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleItem(
            "Dia",
            state.viewMode == ScheduleViewMode.day,
            () => context.read<ScheduleBloc>().add(
              ChangeViewMode(ScheduleViewMode.day),
            ),
          ),
          _buildToggleItem(
            "3 Dias",
            state.viewMode == ScheduleViewMode.threeDays,
            () => context.read<ScheduleBloc>().add(
              ChangeViewMode(ScheduleViewMode.threeDays),
            ),
          ),
          _buildToggleItem(
            "Semana",
            state.viewMode == ScheduleViewMode.week,
            () => context.read<ScheduleBloc>().add(
              ChangeViewMode(ScheduleViewMode.week),
            ),
          ),
          _buildToggleItem(
            "Mês",
            state.viewMode == ScheduleViewMode.month,
            () => context.read<ScheduleBloc>().add(
              ChangeViewMode(ScheduleViewMode.month),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? const Color(0xFF0F172A) : Colors.black45,
          ),
        ),
      ),
    );
  }

  void _openEditAppointment(
    BuildContext context,
    ScheduleState state,
    Appointment apt,
  ) async {
    final result = await showGeneralDialog<dynamic>(
      context: context,
      // ... mesmas configurações de animação do showGeneralDialog ...
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: AddAppointmentDialog(
            availablePatients: state.availablePatients,
            activeCategories: state.activeCategories,
            initialDate: apt.startDate,
            appointmentToEdit: apt,
          ),
        );
      },
    );

    if (result != null && context.mounted) {
      if (result == 'delete') {
        context.read<ScheduleBloc>().add(DeleteAppointment(apt.id));
      } else if (result is Appointment) {
        context.read<ScheduleBloc>().add(UpdateAppointment(result));
      }
    }
  }
}
