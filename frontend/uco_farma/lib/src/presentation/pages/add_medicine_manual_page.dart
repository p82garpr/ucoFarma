import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/presentation/providers/medicine_provider.dart';
import 'package:uco_farma/src/presentation/widgets/medicine_form.dart';
import '../providers/auth_provider.dart';

class AddMedicineManualPage extends StatefulWidget {
  const AddMedicineManualPage({super.key});

  @override
  State<AddMedicineManualPage> createState() => _AddMedicineManualPageState();
}

class _AddMedicineManualPageState extends State<AddMedicineManualPage> {
  final _formKey = GlobalKey<FormState>();
  final _cnController = TextEditingController();
  final _quantityController = TextEditingController();
  final _frequencyController = TextEditingController(text: '0');
  final _doseQuantityController = TextEditingController(text: '0');
  final _doseStartDateTimeController = TextEditingController();
  final _doseEndDateTimeController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String _selectedType = 'solid';

  @override
  void dispose() {
    _cnController.dispose();
    _quantityController.dispose();
    _frequencyController.dispose();
    _doseQuantityController.dispose();
    _doseStartDateTimeController.dispose();
    _doseEndDateTimeController.dispose();
    super.dispose();
  }

  Future<void> _addMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final medicineProvider =
          Provider.of<MedicineProvider>(context, listen: false);

      final userId = authProvider.user?.id;
      final token = authProvider.token;

      if (userId == null || token == null) {
        throw Exception('Usuario no autenticado');
      }

      final success = await medicineProvider.addMedicine(
        userId,
        _cnController.text,
        token,
        int.parse(_quantityController.text),
        _selectedType,
        int.parse(_frequencyController.text),
        double.parse(_doseQuantityController.text),
        false,
        _doseStartDateTimeController.text.trim(),
        _doseEndDateTimeController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        await authProvider.refreshUserData();

        if (!mounted) return;

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Medicamento añadido con éxito')),
        );
        navigator.pop();
      } else {
        throw Exception(
            medicineProvider.error ?? 'Error al añadir el medicamento');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCNInfoDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.medication, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Código Nacional'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué es el Código Nacional?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'El Código Nacional es un número único de 6 dígitos que identifica cada medicamento en España.',
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Dónde encontrarlo?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Puedes encontrarlo en:\n'
                  '• El cartonaje del medicamento\n'
                  '• El código de barras (últimos 6 dígitos)\n'
                  '• El prospecto del medicamento\n'
                  '• La factura de la farmacia',
                ),
                const SizedBox(height: 16),
                // Imagen de ejemplo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/cn.png',
                      fit: BoxFit.contain,
                      height: 200, // Ajusta esta altura según necesites
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ejemplo de ubicación del CN en el envase',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'También puedes usar el escáner QR o NFC para añadir medicamentos automáticamente.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Añadir Medicamento',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de Código Nacional con botón de información
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cnController,
                    decoration: const InputDecoration(
                      labelText: 'Código Nacional',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showCNInfoDialog(context, theme),
                ),
              ],
            ),
            const SizedBox(height: 8),

            MedicineForm(
              formKey: _formKey,
              quantityController: _quantityController,
              frequencyController: _frequencyController,
              doseQuantityController: _doseQuantityController,
              startDateController: _doseStartDateTimeController,
              endDateController: _doseEndDateTimeController,
              selectedType: _selectedType,
              isLoading: _isLoading,
              error: _error,
              onAddMedicine: _addMedicine,
              onTypeChanged: (value) => setState(() => _selectedType = value),
            ),
          ],
        ),
      ),
    );
  }
}
