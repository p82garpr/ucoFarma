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
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad: ${medicine.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                _getMedicineIcon(),
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
