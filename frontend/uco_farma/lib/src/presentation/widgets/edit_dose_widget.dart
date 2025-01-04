import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/domain/models/medicine_model.dart';
import 'package:uco_farma/src/presentation/providers/dose_provider.dart';

import '../providers/auth_provider.dart';

class EditDoseDialog extends StatefulWidget {
  final String cn;
  final String type;
  final Dose? dose;
  final String medicineName;

  const EditDoseDialog({
    super.key,
    required this.cn,
    required this.type,
    required this.dose,
    required this.medicineName,
  });

  @override
  State<EditDoseDialog> createState() => _EditDoseDialogState();
}

class _EditDoseDialogState extends State<EditDoseDialog> {
  late TextEditingController quantityController;
  late TextEditingController frequencyController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  @override
  void initState() {
    super.initState();
    quantityController =
        TextEditingController(text: (widget.dose?.quantity ?? 0).toString());
    frequencyController =
        TextEditingController(text: (widget.dose?.frequency ?? 0).toString());
    startDateController =
        TextEditingController(text: widget.dose?.startDate ?? '');
    endDateController = TextEditingController(text: widget.dose?.endDate ?? '');
  }

  @override
  void dispose() {
    quantityController.dispose();
    frequencyController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  String _getUnits(String type) {
    return type == 'liquid' ? 'ml' : 'unidades';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Entendido'),
                    ),
                  ],
                );
              },
            ),
            icon: const Icon(Icons.warning_rounded,
                color: Color.fromARGB(255, 197, 151, 14)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onFieldSubmitted: (value) {
                if (value.isEmpty) {
                  quantityController.text = '0';
                } else {
                  setState(() {
                    quantityController.text = value;
                  });
                }
              },
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Cantidad por toma',
                helperText: 'Cantidad a tomar en cada dosis',
                suffixText: _getUnits(widget.type),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              onFieldSubmitted: (value) {
                if (value.isEmpty) {
                  frequencyController.text = '0';
                } else {
                  setState(() {
                    frequencyController.text = value;
                  });
                }
              },
              controller: frequencyController,
              decoration: const InputDecoration(
                labelText: 'Frecuencia',
                helperText: 'Cada cuántas horas tomar la dosis',
                suffixText: 'horas',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () async {
                if (int.parse(quantityController.text) == 0 &&
                    int.parse(frequencyController.text) == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Primero debes introducir una cantidad y una frecuencia'),
                    ),
                  );
                  return;
                }
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: startDateController.text.isNotEmpty
                      ? DateTime.parse(startDateController.text)
                      : DateTime.now(),
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    startDateController.text = picked.toIso8601String();
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Inicio del tratamiento',
                  prefixIcon: const Icon(Icons.calendar_today),
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
            InkWell(
              onTap: () async {
                if (int.parse(quantityController.text) == 0 &&
                    int.parse(frequencyController.text) == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Primero debes introducir una cantidad y una frecuencia'),
                    ),
                  );
                  return;
                }
                if (startDateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Primero selecciona una fecha de inicio'),
                    ),
                  );
                  return;
                }
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: endDateController.text.isNotEmpty
                      ? DateTime.parse(endDateController.text)
                      : DateTime.parse(startDateController.text),
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    endDateController.text = picked.toIso8601String();
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fin del tratamiento',
                  prefixIcon: const Icon(Icons.calendar_today),
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
                const SnackBar(content: Text('Las fechas son obligatorias')),
              );
              return;
            }

            if (DateTime.parse(endDateController.text)
                .isBefore(DateTime.parse(startDateController.text))) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'La fecha de fin no puede ser anterior a la fecha de inicio')),
              );
              return;
            }

            final doseProvider = context.read<DoseProvider>();
            final authProvider = context.read<AuthProvider>();

            final success = await doseProvider.updateDose(
              authProvider.user?.id ?? '',
              widget.cn,
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
                  content: const Text('Dosis actualizada correctamente'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      doseProvider.error ?? 'Error al actualizar la dosis'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
