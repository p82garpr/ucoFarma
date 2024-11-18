import 'package:flutter/material.dart';
import 'package:uco_farma/src/domain/models/medicine_model.dart';

class MedicinesCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;

  const MedicinesCard({
    super.key,
    required this.medicine,
    this.onTap,
  });

  IconData _getMedicineIcon() {
    return medicine.type.toLowerCase() == 'liquid'
        ? Icons.medication_liquid
        : Icons.medication;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono a la izquierda
              Icon(
                _getMedicineIcon(),
                size: 40,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(width: 16), // Espaciado

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad: ${medicine.quantity} dosis',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CN: ${medicine.cn}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha o indicador a la derecha (opcional)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
