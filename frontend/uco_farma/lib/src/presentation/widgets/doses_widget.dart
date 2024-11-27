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
                        final success = await doseProvider.takeDose(
                          authProvider.user?.id ?? '', 
                          cn, 
                          (dose?.quantity ?? 0).toInt(), 
                          authProvider.token ?? ''
                        );
                        
                        if (success) {
                          authProvider.refreshUserData();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Dosis tomada correctamente'),
                              backgroundColor: theme.colorScheme.secondary,
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(doseProvider.error ?? 'Error al tomar la dosis'),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
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
                        text: (dose?.quantity ?? 0).toString()
                      );
                      final frequencyController = TextEditingController(
                        text: (dose?.frequency ?? 0).toString()
                      );

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Editar dosis'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: quantityController,
                                decoration: InputDecoration(
                                  labelText: 'Cantidad (${_getUnits(medicine.type)})',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: frequencyController,
                                decoration: const InputDecoration(
                                  labelText: 'Frecuencia (horas)',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                final success = await doseProvider.updateDose(
                                  authProvider.user?.id ?? '',
                                  cn,
                                  int.tryParse(frequencyController.text) ?? 0,
                                  int.tryParse(quantityController.text) ?? 0,
                                  authProvider.token ?? ''
                                );

                                if (!context.mounted) return;
                                Navigator.pop(context);

                                if (success) {
                                  authProvider.refreshUserData();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Dosis actualizada correctamente'),
                                      backgroundColor: theme.colorScheme.secondary,
                                    ),
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(doseProvider.error ?? 'Error al actualizar la dosis'),
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
