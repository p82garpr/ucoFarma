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
                      onPressed: () {
                        
                       
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
                      // TODO: Implementar edición de dosis
                      doseProvider.takeDose(
                          authProvider.user?.id ?? '', 
                          cn, 
                          (dose?.quantity ?? 0).toInt(), 
                          authProvider.token ?? ''
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
