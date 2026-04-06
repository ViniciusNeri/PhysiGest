import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

enum BlockMode { days, period }

class BlockScheduleDialog extends StatefulWidget {
  final DateTime initialDate;

  const BlockScheduleDialog({
    super.key,
    required this.initialDate,
  });

  @override
  State<BlockScheduleDialog> createState() => _BlockScheduleDialogState();
}

class _BlockScheduleDialogState extends State<BlockScheduleDialog> {
  BlockMode _mode = BlockMode.days;
  
  // Para Modo Dias
  final Set<DateTime> _selectedDays = {};
  DateTime _focusedDay = DateTime.now();

  // Para Modo Período
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _focusedDay = widget.initialDate;
    _selectedDays.add(DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day));
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 500 : MediaQuery.of(context).size.width * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(-5, 0)),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildModeToggle(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                physics: const BouncingScrollPhysics(),
                child: _mode == BlockMode.days ? _buildDaysMode() : _buildPeriodMode(),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bloquear Agenda",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                "Defina os períodos de indisponibilidade",
                style: TextStyle(fontSize: 14, color: Colors.black38),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
            icon: const Icon(Icons.close_rounded, color: Colors.black54, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(child: _buildToggleButton("Dias", BlockMode.days)),
            Expanded(child: _buildToggleButton("Período", BlockMode.period)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, BlockMode mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF0F172A) : Colors.black45,
          ),
        ),
      ),
    );
  }

  Widget _buildDaysMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECIONE OS DIAS PARA BLOQUEIO TOTAL",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),
        TableCalendar(
          locale: 'pt_BR',
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => _selectedDays.contains(DateTime(day.year, day.month, day.day)),
          onDaySelected: _onDaySelected,
          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            todayTextStyle: const TextStyle(color: Colors.black87),
            selectedDecoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            markerDecoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedDays.isNotEmpty) ...[
          const Text("Dias Selecionados:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_selectedDays.toList()..sort()).map((date) => Chip(
              label: Text(DateFormat('dd/MM').format(date)),
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              side: BorderSide.none,
              labelStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
              onDeleted: () => setState(() => _selectedDays.remove(date)),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPeriodMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Data do Bloqueio"),
        _buildDateButton(),
        const SizedBox(height: 24),
        _buildLabel("Horário da Indisponibilidade"),
        _buildTimeRangePicker(),
        const SizedBox(height: 16),
        const Text(
          "O período selecionado ficará indisponível para novos agendamentos de pacientes.",
          style: TextStyle(fontSize: 13, color: Colors.black38),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildDateButton() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangePicker() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTimeButton("Início", _startTime, true)),
          Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
          Expanded(child: _buildTimeButton("Término", _endTime, false)),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String label, TimeOfDay time, bool isStart) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) {
          setState(() {
            if (isStart) _startTime = picked;
            else _endTime = picked;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_formatTime(time), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Widget _buildActionButtons() {
    final bool canSubmit = _mode == BlockMode.days ? _selectedDays.isNotEmpty : true;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: !canSubmit ? null : () {
                final List<Appointment> blocks = [];
                if (_mode == BlockMode.days) {
                  for (final date in _selectedDays) {
                    blocks.add(Appointment(
                      id: "block_${date.millisecondsSinceEpoch}",
                      patientName: "INDISPONÍVEL",
                      startDate: DateTime(date.year, date.month, date.day, 8, 0),
                      endDate: DateTime(date.year, date.month, date.day, 19, 0),
                      status: 'blocked',
                    ));
                  }
                } else {
                  blocks.add(Appointment(
                    id: "block_period_${DateTime.now().millisecondsSinceEpoch}",
                    patientName: "INDISPONÍVEL",
                    startDate: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime.hour, _startTime.minute),
                    endDate: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _endTime.hour, _endTime.minute),
                    status: 'blocked',
                  ));
                }
                Navigator.pop(context, blocks);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Confirmar Bloqueio", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
