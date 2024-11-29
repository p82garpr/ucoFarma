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
          children: [
            TextFormField(
              controller: _cnController,
              decoration: const InputDecoration(
                labelText: 'Código Nacional (CN)',
                helperText: 'Introduce el código nacional del medicamento',
                prefixIcon: Icon(Icons.medication),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor introduce el código nacional';
                }
                if (value.length < 6) {
                  return 'El código nacional debe tener al menos 6 dígitos';
                }
                return null;
              },
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
