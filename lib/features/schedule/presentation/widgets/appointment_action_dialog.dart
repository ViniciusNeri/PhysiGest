import 'package:flutter/material.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

class AppointmentActionDialog extends StatefulWidget {
  final Appointment appointment;
  final Function(Appointment) onSave;

  const AppointmentActionDialog({
    super.key,
    required this.appointment,
    required this.onSave,
  });

  @override
  State<AppointmentActionDialog> createState() =>
      _AppointmentActionDialogState();
}

class _AppointmentActionDialogState extends State<AppointmentActionDialog> {
  late String _selectedStatus;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.appointment.status;
    _noteController = TextEditingController(
      text: widget.appointment.notes ?? '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final updatedApt = widget.appointment.copyWith(
      status: _selectedStatus,
      notes: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    widget.onSave(updatedApt);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _selectedStatus == 'realizado';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status do Atendimento",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${widget.appointment.patientName} • ${_formatTime(widget.appointment.startDate)}",
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatusSelector(),
            if (isDone) ...[
              const SizedBox(height: 24),
              const Text(
                "Evolução Clínica / Anotações",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      "Descreva a evolução do paciente, procedimentos realizados e observações...",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Salvar Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusOption(
              'agendado',
              'Agendado',
              Icons.pending_rounded,
            ),
          ),
          Expanded(
            child: _buildStatusOption(
              'realizado',
              'Realizado',
              Icons.check_circle_rounded,
            ),
          ),
          Expanded(
            child: _buildStatusOption('falta', 'Falta', Icons.cancel_rounded),
          ),
          Expanded(
            child: _buildStatusOption(
              'cancelado',
              'Cancelado',
              Icons.event_busy_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String value, String label, IconData icon) {
    final isSelected = _selectedStatus == value;
    final color = _getStatusColor(value);

    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isSelected ? color : Colors.black38),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F172A) : Colors.black45,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'realizado':
        return const Color(0xFF10B981); // Success
      case 'falta':
        return const Color(0xFFEF4444); // Error/Red
      case 'cancelado':
        return const Color(0xFFF59E0B); // Warning/Orange
      default:
        return const Color(0xFF64748B); // Normal/Grey
    }
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
