import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';

class CreateAgendaLockDialog extends StatefulWidget {
  final DateTime initialDate;
  final Function(AgendaLock) onSave;

  const CreateAgendaLockDialog({
    super.key,
    required this.initialDate,
    required this.onSave,
  });

  @override
  State<CreateAgendaLockDialog> createState() => _CreateAgendaLockDialogState();
}

class _CreateAgendaLockDialogState extends State<CreateAgendaLockDialog> {
  final Set<DateTime> _selectedDays = {};
  DateTime _focusedDay = DateTime.now();
  String _type = 'partial'; // 'partial' | 'total'
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  final _descriptionController = TextEditingController();

  final Color primary = const Color(0xFF6366F1);
  final Color danger = const Color(0xFFEF4444);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDays.add(DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      final day = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.block_rounded, color: danger),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Bloquear Agenda",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.black26),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "TIPO DE BLOQUEIO",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TypeBtn(
                      label: "Parcial",
                      isSelected: _type == 'partial',
                      onTap: () => setState(() => _type = 'partial'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeBtn(
                      label: "Total",
                      isSelected: _type == 'total',
                      onTap: () => setState(() => _type = 'total'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "SELECIONE OS DIAS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: TableCalendar(
                  locale: 'pt_BR',
                  firstDay: DateTime.now().subtract(const Duration(days: 30)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    leftChevronIcon: Icon(Icons.chevron_left_rounded, color: primary),
                    rightChevronIcon: Icon(Icons.chevron_right_rounded, color: primary),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
                    weekendTextStyle: const TextStyle(fontWeight: FontWeight.w500, color: Colors.redAccent),
                    todayDecoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    todayTextStyle: TextStyle(color: primary, fontWeight: FontWeight.bold),
                    selectedDecoration: BoxDecoration(color: danger, shape: BoxShape.circle),
                    selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  selectedDayPredicate: (day) => _selectedDays.contains(DateTime(day.year, day.month, day.day)),
                  onDaySelected: _onDaySelected,
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedDays.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_selectedDays.toList()..sort()).map((date) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('dd/MM').format(date),
                          style: TextStyle(color: danger, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() => _selectedDays.remove(date)),
                          child: Icon(Icons.close_rounded, size: 14, color: danger),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
              if (_type == 'partial') ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "INÍCIO",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectTime(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 18, color: Colors.black45),
                                  const SizedBox(width: 8),
                                  Text(_formatTimeOfDay(_startTime)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TÉRMINO",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectTime(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 18, color: Colors.black45),
                                  const SizedBox(width: 8),
                                  Text(_formatTimeOfDay(_endTime)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                "DESCRIÇÃO",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Ex: Feriado, Reunião...",
                  filled: true,
                  fillColor: bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDays.isEmpty ? null : () {
                    final lock = AgendaLock(
                      id: '',
                      userId: '',
                      type: _type,
                      dates: _selectedDays.toList(),
                      startTime: _type == 'partial' ? _formatTimeOfDay(_startTime) : null,
                      endTime: _type == 'partial' ? _formatTimeOfDay(_endTime) : null,
                      description: _descriptionController.text,
                    );
                    widget.onSave(lock);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    disabledBackgroundColor: Colors.black12,
                  ),
                  child: const Text(
                    "Confirmar Bloqueio",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6366F1);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : Colors.black.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
