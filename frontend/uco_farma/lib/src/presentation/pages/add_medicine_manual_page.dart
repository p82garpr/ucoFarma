import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/presentation/providers/medicine_provider.dart';
import '../providers/auth_provider.dart';

class AddMedicineManualPage extends StatefulWidget {
  const AddMedicineManualPage({super.key});

  @override
  State<AddMedicineManualPage> createState() => _AddMedicineManualPageState();
}

class _AddMedicineManualPageState extends State<AddMedicineManualPage> {
  final _formKey = GlobalKey<FormState>();
  // Código Nacional
  final _cnController = TextEditingController();
  // Cantidad
  final _quantityController = TextEditingController();
  // Frecuencia
  final _frequencyController = TextEditingController();
  // Dosis por toma
  final _doseQuantityController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String _selectedType = 'solid'; // Por defecto sólido
  //String _unit = 'unidades'; // Por defecto unidades

  @override
  void dispose() {
    _cnController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String _getUnitLabel() {
    return _selectedType == 'solid' ? 'unidades' : 'ml';
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
      final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);

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
        int.parse(_doseQuantityController.text),
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
        throw Exception(medicineProvider.error ?? 'Error al añadir el medicamento');
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
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 16),
              
              // Selector de tipo de medicamento
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Sólido'),
                      value: 'solid',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                          //_unit = 'unidades';
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Líquido'),
                      value: 'liquid',
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                          //_unit = 'ml';
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Campo de cantidad
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Nº de dosis',
                  helperText: 'Introduce el numero de dosis en ${_getUnitLabel()}',
                  prefixIcon: Icon(_selectedType == 'solid' ? 
                    Icons.medication : Icons.medication_liquid),
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

              // Campo de frecuencia
                TextFormField(
                controller: _frequencyController,
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
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Por favor introduce un número válido de horas';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              
              // Campo de cantidad por dosis
              TextFormField(
                controller: _doseQuantityController,
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
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Por favor introduce un número válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _addMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Añadir Medicamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
