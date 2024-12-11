import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/presentation/providers/auth_provider.dart';
import 'package:uco_farma/src/presentation/providers/dose_provider.dart';

class DosesWidget extends StatelessWidget {
  final String cn;
  const DosesWidget({super.key, required this.cn});

  String _getUnits(String type) {
    return type == 'liquid' ? 'ml' : 'unidades';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final doseProvider = context.read<DoseProvider>();

    final medicine = authProvider.user?.medicines?.firstWhere(
      (med) => med.cn == cn,
      orElse: () => throw Exception('Medicamento no encontrado'),
    );

    if (medicine == null) {
      return const Center(child: Text('Medicamento no encontrado'));
    }

    final dose = medicine.doses?.firstOrNull;

    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),

              // Card principal con la información de dosis
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cantidad por dosis
                      Row(
                        children: [
                          const Icon(Icons.medication_outlined, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cantidad por dosis',
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  dose?.quantity == 0 || dose == null
                                      ? 'No especificada'
                                      : '${dose.quantity} ${_getUnits(medicine.type)}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Frecuencia
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Frecuencia',
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  dose?.frequency == 0 || dose == null
                                      ? 'No especificada'
                                      : 'Cada ${dose.frequency} horas',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Mostrar diálogo de confirmación
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmar toma'),
                              content: Text(
                                  'Vas a tomar ${(dose?.quantity == 0 ? 1 : dose?.quantity ?? 1)} ${_getUnits(medicine.type)} de ${medicine.name}. ¿Estás seguro?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            );
                          },
                        );

                        // Si el usuario confirma, proceder con la toma
                        if (confirm == true) {
                          final success = await doseProvider.takeDose(
                              authProvider.user?.id ?? '',
                              cn,
                              (dose?.quantity == 0 ? 1 : dose?.quantity ?? 1)
                                  .toInt(),
                              authProvider.token ?? '');

                          if (success) {
                            authProvider.refreshUserData();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Dosis tomada correctamente'),
                                backgroundColor: theme.colorScheme.secondary,
                              ),
                            );
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(doseProvider.error ??
                                    'Error al tomar la dosis'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Tomar Dosis'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      final quantityController = TextEditingController(
                          text: (dose?.quantity ?? 0).toString());
                      final frequencyController = TextEditingController(
                          text: (dose?.frequency ?? 0).toString());
                      final startDateController =
                          TextEditingController(text: dose?.startDate ?? '');
                      final endDateController =
                          TextEditingController(text: dose?.endDate ?? '');

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Editar dosis'),
                              IconButton(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Aviso importante'),
                                      content: const Text(
                                        'La modificación de las dosis debe realizarse bajo prescripción médica. UCOFarma no se hace responsable del uso inadecuado de los medicamentos ni de las consecuencias derivadas de la automedicación.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Entendido'),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                icon: Icon(Icons.warning_rounded,
                                    color: theme.colorScheme.error),
                              ),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: quantityController,
                                  decoration: InputDecoration(
                                    labelText: 'Cantidad por toma',
                                    helperText:
                                        'Cantidad a tomar en cada dosis',
                                    suffixText: _getUnits(medicine.type),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: frequencyController,
                                  decoration: const InputDecoration(
                                    labelText: 'Frecuencia',
                                    helperText:
                                        'Cada cuántas horas tomar la dosis',
                                    suffixText: 'horas',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 24),
                                // Fecha de inicio
                                InkWell(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: dose?.startDate != ""
                                          ? DateTime.parse(dose!.startDate)
                                          : DateTime.now(),
                                      firstDate: DateTime(1970),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      startDateController.text =
                                          picked.toIso8601String();
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Inicio del tratamiento',
                                      prefixIcon:
                                          const Icon(Icons.calendar_today),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            startDateController.text.isNotEmpty
                                                ? '${DateTime.parse(startDateController.text).day}/'
                                                    '${DateTime.parse(startDateController.text).month}/'
                                                    '${DateTime.parse(startDateController.text).year}'
                                                : 'Seleccionar inicio',
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down,
                                            color: theme.colorScheme.primary),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Fecha de fin
                                InkWell(
                                  onTap: () async {
                                    if (startDateController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Primero selecciona una fecha de inicio'),
                                        ),
                                      );
                                      return;
                                    }
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: dose?.endDate != ""
                                          ? DateTime.parse(dose!.endDate)
                                          : DateTime.parse(
                                              startDateController.text),
                                      firstDate: DateTime.parse(
                                          startDateController.text),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null) {
                                      endDateController.text =
                                          picked.toIso8601String();
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Fin del tratamiento',
                                      prefixIcon:
                                          const Icon(Icons.calendar_today),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            endDateController.text.isNotEmpty
                                                ? '${DateTime.parse(endDateController.text).day}/'
                                                    '${DateTime.parse(endDateController.text).month}/'
                                                    '${DateTime.parse(endDateController.text).year}'
                                                : 'Seleccionar fin',
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down,
                                            color: theme.colorScheme.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                if (startDateController.text.isEmpty ||
                                    endDateController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Las fechas son obligatorias'),
                                    ),
                                  );
                                  return;
                                }

                                final success = await doseProvider.updateDose(
                                  authProvider.user?.id ?? '',
                                  cn,
                                  int.tryParse(frequencyController.text) ?? 0,
                                  int.tryParse(quantityController.text) ?? 0,
                                  startDateController.text,
                                  endDateController.text,
                                  authProvider.token ?? '',
                                );

                                if (!context.mounted) return;
                                Navigator.pop(context);

                                if (success) {
                                  authProvider.refreshUserData();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Dosis actualizada correctamente'),
                                      backgroundColor:
                                          theme.colorScheme.secondary,
                                    ),
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(doseProvider.error ??
                                          'Error al actualizar la dosis'),
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Guardar'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
