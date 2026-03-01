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
import 'package:physigest/features/schedule/domain/models/appointment.dart';

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
  Future<void> _openAddAppointment(BuildContext context, ScheduleState state, DateTime initialDate) async {
    final result = await showGeneralDialog<Appointment>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: AddAppointmentDialog(
            availablePatients: state.availablePatients,
            initialDate: initialDate,
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
              .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor, size: 24),
        title: const Text(
          "Agenda",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        shape: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.black45)),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // SIDEBAR FIXA
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
                  child: BlocBuilder<ScheduleBloc, ScheduleState>(
                    builder: (context, state) {
                      if (state.status == ScheduleStatus.loading) {
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      }
                      return _buildWeeklyTimeline(context, state);
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
            onPressed: () => _openAddAppointment(context, state, state.selectedDate),
            backgroundColor: const Color(0xFF0F172A),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text("Novo Horário", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        final monday = state.selectedDate.subtract(Duration(days: state.selectedDate.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        final rangeLabel = "${DateFormat('d').format(monday)} - ${DateFormat('d').format(sunday)} de ${DateFormat('MMMM, yyyy', 'pt_BR').format(sunday)}";

        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
          child: Row(
            children: [
              Text(rangeLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.5)),
              const SizedBox(width: 24),
              _buildNavButton(Icons.chevron_left_rounded, () {
                context.read<ScheduleBloc>().add(SelectDate(state.selectedDate.subtract(const Duration(days: 7))));
              }),
              const SizedBox(width: 8),
              _buildNavButton(Icons.chevron_right_rounded, () {
                context.read<ScheduleBloc>().add(SelectDate(state.selectedDate.add(const Duration(days: 7))));
              }),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => context.read<ScheduleBloc>().add(SelectDate(DateTime.now())),
                child: const Text("Hoje", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              _buildViewToggle(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyTimeline(BuildContext context, ScheduleState state) {
    final int daysToSubtract = state.selectedDate.weekday - 1;
    final DateTime firstDayOfWeek = state.selectedDate.subtract(Duration(days: daysToSubtract));
    final List<DateTime> weekDays = List.generate(7, (i) => firstDayOfWeek.add(Duration(days: i)));

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 70),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
            child: Row(children: weekDays.map((day) => Expanded(child: _buildDayHeader(day))).toList()),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeColumn(),
                  ...weekDays.map((day) => Expanded(child: _buildDayColumn(context, state, day))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(BuildContext context, ScheduleState state, DateTime day) {
    final dayApts = state.appointments.where((a) => DateUtils.isSameDay(a.date, day)).toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Garante que o clique seja detectado em toda a área
      onTapUp: (details) {
        // Cálculo matemático da hora clicada
        final double clickY = details.localPosition.dy;
        final int hourClicked = (clickY / hourHeight).floor() + startHour;
        final DateTime tappedDateTime = DateTime(day.year, day.month, day.day, hourClicked);

        _openAddAppointment(context, state, tappedDateTime);
      },
      child: Container(
        decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFFF8FAFC)))),
        child: Stack(
          children: [
            Column(
              children: List.generate(endHour - startHour, (index) => Container(
                height: hourHeight,
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
              )),
            ),
            ...dayApts.map((apt) {
              final startTimeParts = apt.time.split(':');
              final endTimeParts = apt.endTime.split(':'); // Pega o horário de término

              // Converter para double (horas + fração de minutos)
              final double start = double.parse(startTimeParts[0]) + (double.parse(startTimeParts[1]) / 60);
              final double end = double.parse(endTimeParts[0]) + (double.parse(endTimeParts[1]) / 60);
              
              // Cálculo da duração em horas (ex: 1.5 para 1h30min)
              final double duration = end - start;

              // Posição no topo
              final double top = (start - startHour) * hourHeight;

              return Positioned(
                top: top + 4,
                left: 6,
                right: 6,
                // AQUI ESTÁ A MÁGICA: Altura baseada na duração real
                height: (duration * hourHeight) - 8, 
                child: GestureDetector(
                  onTap: () => _openEditAppointment(context, state, apt),
                  child: _buildAppointmentCard(apt),
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
          Text(DateFormat('EEE', 'pt_BR').format(day).toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isToday ? AppTheme.primaryColor : Colors.black26, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isToday ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(day.day.toString(),
                style: TextStyle(fontWeight: FontWeight.w900, color: isToday ? AppTheme.primaryColor : const Color(0xFF1E293B), fontSize: 18)),
          ),
        ],
      ),
    );
  }

   Widget _buildAppointmentCard(dynamic apt) {
    final Color baseColor = _getTypeColor(apt.type);

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
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
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  apt.patientName,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                    shadows: [Shadow(color: Colors.black12, blurRadius: 2)],
                  ),
                ),
                const SizedBox(height: 4),
                // Containerzinho para o horário (estilo Badge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_filled, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        "${apt.time} - ${apt.endTime}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  apt.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
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
        children: List.generate(endHour - startHour, (index) => Container(
          height: hourHeight,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 10),
          child: Text("${index + startHour}:00", style: const TextStyle(color: Colors.black26, fontSize: 11, fontWeight: FontWeight.bold)),
        )),
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
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.black26),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 40),
          const Text("CATEGORIAS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          _buildFilterItem("Fisioterapia", AppTheme.primaryColor),
          _buildFilterItem("Pilates", Colors.teal),
          _buildFilterItem("Avaliação", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 14)),
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
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildToggleItem("Dia", false),
          _buildToggleItem("Semana", true),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? const Color(0xFF0F172A) : Colors.black45)),
    );
  }

  void _openEditAppointment(BuildContext context, ScheduleState state, Appointment apt) async {
  final result = await showGeneralDialog<Appointment>(
    context: context,
    // ... mesmas configurações de animação do showGeneralDialog ...
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerRight,
        child: AddAppointmentDialog(
          availablePatients: state.availablePatients,
          initialDate: apt.date, 
          appointmentToEdit: apt, 
        ),
      );
    },
  );

  if (result != null) {
    // Aqui você enviaria um evento de Update em vez de Add
    context.read<ScheduleBloc>().add(UpdateAppointment(result));
  }
}

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Avaliação Inicial':
        return const Color(0xFFFB923C); 
      case 'Fisioterapia':
        return const Color(0xFF60A5FA); 
      case 'Pilates':
        return const Color(0xFF94A3B8); 
      case 'RPG':
        return const Color(0xFFF87171); 
      default:
        return const Color(0xFF4ADE80); 
    }
  }
}