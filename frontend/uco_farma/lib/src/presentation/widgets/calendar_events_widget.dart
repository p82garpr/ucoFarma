import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dose_provider.dart';

class CalendarEvents extends StatefulWidget {
  const CalendarEvents({super.key});

  @override
  State<CalendarEvents> createState() => _CalendarEventsState();
}

class _CalendarEventsState extends State<CalendarEvents> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<dynamic>> _events;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events = {};
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final authProvider = context.read<AuthProvider>();
    final doseProvider = context.read<DoseProvider>();
    final medicines = authProvider.user?.medicines ?? [];
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _events.clear();
    for (var medicine in medicines) {
      if (medicine.doses?.isNotEmpty ?? false) {
        for (var dose in medicine.doses!) {
          if (dose.startDate.isNotEmpty && dose.endDate.isNotEmpty) {
            DateTime startDate = DateTime.parse(dose.startDate);
            DateTime endDate = DateTime.parse(dose.endDate);

            // Si la fecha actual es posterior a la fecha de fin
            if (now.isAfter(endDate)) {
              try {
                final success = await doseProvider.updateDose(
                  authProvider.user?.id ?? '',
                  medicine.cn,
                  0,
                  0,
                  dose.startDate,
                  dose.endDate,
                  authProvider.token ?? '',
                );

                if (success && mounted) {
                  await authProvider.refreshUserData();
                }
                continue;
              } catch (e) {
                debugPrint('Error al actualizar la dosis: $e');
              }
            }

            // Solo agregar eventos si la fecha de fin es igual o posterior a la fecha actual
            if (!endDate.isBefore(now)) {
              for (DateTime date = startDate;
                  date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
                  date = date.add(const Duration(days: 1))) {
                final eventDate = DateTime(date.year, date.month, date.day);
                if (!_events.containsKey(eventDate)) {
                  _events[eventDate] = [];
                }
                _events[eventDate]!.add({
                  'medicineName': medicine.name,
                  'doseQuantity': dose.quantity,
                  'frequency': dose.frequency,
                  'type': medicine.type,
                });
              }
            }
          }
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // No mostrar eventos para días anteriores al actual
    if (day.isBefore(now)) {
      return [];
    }

    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(1970, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: theme.colorScheme.primary),
              markerMargin: const EdgeInsets.only(top: 7),
              todayDecoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary, width: 2),
                //color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: theme.colorScheme.onPrimary),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedDay != null) ...[
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Dosis programadas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (_getEventsForDay(_selectedDay!).isEmpty)
                      Center(
                        child: Text(
                          'No hay dosis programadas para este día',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _getEventsForDay(_selectedDay!).length,
                        itemBuilder: (context, index) {
                          final event = _getEventsForDay(_selectedDay!)[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  event['type'] == 'liquid'
                                      ? Icons.medication_liquid
                                      : Icons.medication,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event['medicineName'],
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      Text(
                                        'Cantidad: ${event['doseQuantity']} - Cada ${event['frequency']} horas',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
