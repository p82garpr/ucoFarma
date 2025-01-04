import 'package:flutter/material.dart';
import '../../domain/services/notification_service.dart';

class ScheduleNotificationDialog extends StatefulWidget {
  final String medicineName;

  const ScheduleNotificationDialog({
    super.key,
    required this.medicineName,
  });

  @override
  State<ScheduleNotificationDialog> createState() =>
      _ScheduleNotificationDialogState();
}

class _ScheduleNotificationDialogState
    extends State<ScheduleNotificationDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.init();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Programar recordatorio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_selectedDate == null
                ? 'Seleccionar fecha'
                : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            onTap: () => _selectDate(context),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(_selectedTime == null
                ? 'Seleccionar hora'
                : 'Hora: ${_selectedTime!.format(context)}'),
            onTap: () => _selectTime(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: (_selectedDate == null || _selectedTime == null)
              ? null
              : () async {
                  try {
                    final now = DateTime.now();
                    final scheduledDate = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );

                    if (scheduledDate.isBefore(now)) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('La fecha seleccionada debe ser futura'),
                        ),
                      );
                      return;
                    }

                    await _notificationService.scheduleNotification(
                      title: 'Recordatorio de medicamento',
                      body: 'Es hora de tomar ${widget.medicineName}',
                      scheduledDate: scheduledDate,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recordatorio programado con éxito'),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error al programar el recordatorio: ${e.toString()}'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                },
          child: const Text('Programar'),
        ),
      ],
    );
  }
}
