import 'package:flutter/material.dart';

class MedicineForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController quantityController;
  final TextEditingController frequencyController;
  final TextEditingController doseQuantityController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
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
    required this.startDateController,
    required this.endDateController,
    required this.selectedType,
    required this.isLoading,
    required this.error,
    this.scannedCN,
    this.medicineName,
    required this.onAddMedicine,
    required this.onTypeChanged,
  });

  @override
  State<MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends State<MedicineForm> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showDoseScheduling = false;

  String _getUnitLabel() {
    return widget.selectedType == 'solid' ? 'unidades' : 'ml';
  }

  Future<void> _selectStartDate() async {
    if (!mounted) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (!mounted || picked == null) return;

    /*final TimeOfDay? time = await showTimePicker( //esto lo que hace es
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (!mounted || time == null) return;
    */

    setState(() {
      _startDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        //time.hour,
        //time.minute,
      );
      widget.startDateController.text = _startDate!.toIso8601String();
    });
  }

  Future<void> _selectEndDate() async {
    if (!mounted) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (!mounted || picked == null) return;

    /*final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted || time == null) return;
    */

    setState(() {
      _endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        //time.hour,
        //time.minute,
      );
      widget.endDateController.text = _endDate!.toIso8601String();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (widget.scannedCN != null) ...[
            Text(
              'Código Nacional: ${widget.scannedCN}',
              style: theme.textTheme.titleMedium,
            ),

          //const SizedBox(height: 8 ),
            if (widget.medicineName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Medicamento: ${widget.medicineName}',
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
                  groupValue: widget.selectedType,
                  onChanged: (value) => widget.onTypeChanged(value!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Líquido'),
                  value: 'liquid',
                  groupValue: widget.selectedType,
                  onChanged: (value) => widget.onTypeChanged(value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.quantityController,
            decoration: InputDecoration(
              labelText: 'Cantidad',
              helperText: 'Introduce la cantidad en ${_getUnitLabel()}',
              prefixIcon: Icon(widget.selectedType == 'solid'
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
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(
                      () => _showDoseScheduling = !_showDoseScheduling),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Programación de la dosis (opcional)',
                            style: theme.textTheme.titleMedium!,
                          ),
                        ),
                        Icon(
                          _showDoseScheduling
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showDoseScheduling)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 16),

                        // Cantidad por dosis
                        TextFormField(
                          controller: widget.doseQuantityController,
                          decoration: InputDecoration(
                            labelText: 'Cantidad por toma',
                            helperText: 'Cantidad a tomar en cada dosis',
                            prefixIcon: const Icon(Icons.medication_outlined),
                            suffixText: _getUnitLabel(),
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 16),

                        // Frecuencia
                        TextFormField(
                          controller: widget.frequencyController,
                          decoration: const InputDecoration(
                            labelText: 'Frecuencia',
                            helperText: 'Cada cuántas horas se debe tomar',
                            prefixIcon: Icon(Icons.timer_outlined),
                            suffixText: 'horas',
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 8),

                        Text(
                          'Período del tratamiento',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Fecha y hora de inicio
                        InkWell(
                          onTap: _selectStartDate,
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
                                    _startDate == null
                                        ? 'Seleccionar inicio'
                                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
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

                        // Fecha y hora de fin
                        InkWell(
                          onTap: _selectEndDate,
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
                                    _endDate == null
                                        ? 'Seleccionar fin'
                                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
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
              ],
            ),
          ),
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                widget.error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onAddMedicine,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Añadir Medicamento'),
            ),
          ),
        ],
      ),
    );
  }
}
