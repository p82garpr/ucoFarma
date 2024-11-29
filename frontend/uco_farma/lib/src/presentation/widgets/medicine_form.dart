import 'package:flutter/material.dart';

class MedicineForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController quantityController;
  final TextEditingController frequencyController;
  final TextEditingController doseQuantityController;
  final String selectedType;
  final bool isLoading;
  final String? error;
  final String? scannedCN;
  final String? medicineName;
  final Function() onAddMedicine;
  final Function(String) onTypeChanged;

  const MedicineForm({
    super.key,
    required this.formKey,
    required this.quantityController,
    required this.frequencyController,
    required this.doseQuantityController,
    required this.selectedType,
    required this.isLoading,
    required this.error,
    this.scannedCN,
    this.medicineName,
    required this.onAddMedicine,
    required this.onTypeChanged,
  });

  String _getUnitLabel() {
    return selectedType == 'solid' ? 'unidades' : 'ml';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (scannedCN != null) ...[
            Text(
              'Código Nacional: $scannedCN',
              style: theme.textTheme.titleMedium,
            ),
            if (medicineName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Medicamento: $medicineName',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          
          // Mensaje informativo sobre el tipo de medicamento
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selecciona si el medicamento es sólido (pastillas, cápsulas) o líquido (jarabe, gotas) según su presentación.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Sólido'),
                  value: 'solid',
                  groupValue: selectedType,
                  onChanged: (value) => onTypeChanged(value!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Líquido'),
                  value: 'liquid',
                  groupValue: selectedType,
                  onChanged: (value) => onTypeChanged(value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: quantityController,
            decoration: InputDecoration(
              labelText: 'Cantidad',
              helperText: 'Introduce la cantidad en ${_getUnitLabel()}',
              prefixIcon: Icon(selectedType == 'solid'
                  ? Icons.medication
                  : Icons.medication_liquid),
              suffixText: _getUnitLabel(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor introduce la cantidad';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Por favor introduce un número válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Campos opcionales:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: frequencyController,
            decoration: const InputDecoration(
              labelText: 'Frecuencia',
              helperText: 'Cada cuántas horas se debe tomar',
              prefixIcon: Icon(Icons.timer),
              suffixText: 'horas',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor introduce la frecuencia';
              }
              if (int.tryParse(value) == null) {
                return 'Por favor introduce un número válido de horas';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: doseQuantityController,
            decoration: InputDecoration(
              labelText: 'Cantidad por dosis',
              helperText: 'Cantidad a tomar cada vez',
              prefixIcon: const Icon(Icons.medication_outlined),
              suffixText: _getUnitLabel(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor introduce la cantidad por dosis';
              }
              if (int.tryParse(value) == null) {
                return 'Por favor introduce un número válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: isLoading ? null : onAddMedicine,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Añadir Medicamento'),
          ),
        ],
      ),
    );
  }
}
