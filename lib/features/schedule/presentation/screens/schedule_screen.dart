import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/core/widgets/side_menu.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Agenda',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const SideMenu(),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state.status == ScheduleStatus.loading || state.status == ScheduleStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ScheduleStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'Erro.'));
          }

          return SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCalendarCard(context, state),
                        ],
                      ),
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width > 800)
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.white,
                      child: _buildAppointmentsList(context, state),
                    ),
                  )
              ],
            ),
          );
        },
      ),
      bottomSheet: MediaQuery.of(context).size.width <= 800
          ? DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.1,
              maxChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                return BlocBuilder<ScheduleBloc, ScheduleState>(
                  builder: (context, state) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                      ),
                      child: _buildAppointmentsList(context, state, scrollController: scrollController),
                    );
                  },
                );
              },
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context, ScheduleState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: state.selectedDate,
        selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          context.read<ScheduleBloc>().add(SelectDate(selectedDay));
        },
        eventLoader: (day) {
          return state.appointments.where((apt) => isSameDay(apt.date, day)).toList();
        },
        locale: 'pt_BR',
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          weekendStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
          markerDecoration: const BoxDecoration(
            color: Color(0xFFE11D48), // Red indicator for appointments
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(fontSize: 16),
          weekendTextStyle: const TextStyle(fontSize: 16, color: Colors.black54),
        ),

      ),
    );
  }

  Widget _buildAppointmentsList(BuildContext context, ScheduleState state,
      {ScrollController? scrollController}) {
    final appointments = state.selectedDayAppointments;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agenda: ${DateFormat('dd/MM/yyyy').format(state.selectedDate)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  '${appointments.length}',
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: appointments.isEmpty
              ? const Center(
                  child: Text(
                  'Dia livre!',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ))
              : ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: appointments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final apt = appointments[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            apt.time,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16),
                          ),
                          const SizedBox(width: 16),
                          Container(width: 2, height: 40, color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  apt.patientName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  apt.type,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    final bloc = context.read<ScheduleBloc>();
    final state = bloc.state;

    String? selectedPatient;
    String? selectedType = 'Sessão Comum';
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Novo Agendamento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Data: ${DateFormat('dd/MM/yyyy').format(state.selectedDate)}'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Paciente'),
                      items: state.availablePatients.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) => setState(() => selectedPatient = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tipo de Atendimento'),
                      value: selectedType,
                      items: ['Avaliação Inicial', 'Sessão Comum', 'Retorno'].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) => setState(() => selectedType = val),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Horário'),
                      trailing: Text(selectedTime.format(context), style: const TextStyle(fontSize: 16)),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedPatient != null) {
                      final timeStr =
                          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                      bloc.add(
                        AddAppointment(
                          Appointment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            patientName: selectedPatient!,
                            type: selectedType!,
                            date: state.selectedDate,
                            time: timeStr,
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
