import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

class AddAppointmentDialog extends StatefulWidget {
  final List<String> availablePatients;
  final DateTime initialDate;   
  final Appointment? appointmentToEdit;

  const AddAppointmentDialog({
    super.key,
    required this.availablePatients,
    required this.initialDate,
    this.appointmentToEdit,
  });

  @override
  State<AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<AddAppointmentDialog> {
  String? selectedPatient;
  String selectedType = 'Fisioterapia';
  late DateTime selectedDate;
  
  // Estados para o intervalo de tempo
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  final List<String> types = ['Fisioterapia', 'Pilates', 'Avaliação Inicial', 'RPG'];

  @override
  void initState() {
    super.initState();
    
    if (widget.appointmentToEdit != null) {
      // Modo Edição
      final apt = widget.appointmentToEdit!;
      selectedPatient = apt.patientName;
      selectedType = apt.type;
      selectedDate = apt.date;
    
      // Converte String "HH:mm" de volta para TimeOfDay
      final startParts = apt.time.split(':');
      startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
    
      final endParts = apt.endTime.split(':');
      endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
    } else {
      // Modo Novo Agendamento
      selectedDate = widget.initialDate;
      startTime = TimeOfDay(hour: widget.initialDate.hour, minute: 0);
      endTime = TimeOfDay(hour: (widget.initialDate.hour + 1) % 24, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(-5, 0))],
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Paciente"),
                    _buildPatientDropdown(),
                    const SizedBox(height: 24),
                    _buildLabel("Tipo de Atendimento"),
                    _buildTypeSelector(),
                    const SizedBox(height: 24),
                    _buildLabel("Data"),
                    _buildDateTile(),
                    const SizedBox(height: 24),
                    _buildLabel("Intervalo de Horário"),
                    _buildTimeRangePicker(),
                    const SizedBox(height: 40),
                  ],
                ),
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
              Text("Novo Agendamento",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.8)),
              Text("Configure os detalhes da sessão", style: TextStyle(fontSize: 14, color: Colors.black38)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.2)),
    );
  }

  Widget _buildPatientDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPatient,
          hint: const Text("Selecione o paciente", style: TextStyle(color: Colors.black26, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black45),
          items: widget.availablePatients.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (val) => setState(() => selectedPatient = val),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        bool isSelected = selectedType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (_) => setState(() => selectedType = type),
          selectedColor: const Color(0xFF0F172A),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0))),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildDateTile() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context, 
          initialDate: selectedDate, 
          firstDate: DateTime.now().subtract(const Duration(days: 365)), 
          lastDate: DateTime.now().add(const Duration(days: 365))
        );
        if (date != null) setState(() => selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
          Expanded(child: _buildTimeButton("Início", startTime, true)),
          Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
          Expanded(child: _buildTimeButton("Término", endTime, false)),
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
            if (isStart) {
              startTime = picked;
              endTime = TimeOfDay(hour: (picked.hour + 1) % 24, minute: picked.minute);
            } else {
              endTime = picked;
            }
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

  Widget _buildActionButtons() {
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
              onPressed: selectedPatient == null ? null : () {
                final newApt = Appointment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  patientName: selectedPatient!,
                  type: selectedType,
                  date: selectedDate,
                  time: _formatTime(startTime),
                  endTime: _formatTime(endTime),
                );
                Navigator.pop(context, newApt);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Salvar Agendamento", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}