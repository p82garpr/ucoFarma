import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../providers/auth_provider.dart';

class AddMedicineQRPage extends StatefulWidget {
  const AddMedicineQRPage({super.key});

  @override
  State<AddMedicineQRPage> createState() => _AddMedicineQRPageState();
}

class _AddMedicineQRPageState extends State<AddMedicineQRPage> {

  
  final _formKey = GlobalKey<FormState>();

  // Cantidad
  final _quantityController = TextEditingController();
  // Frecuencia
  final _frequencyController = TextEditingController();
  // Dosis por toma
  final _doseQuantityController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String _selectedType = 'solid';
  String? _scannedCN;
  bool _showForm = false;

  @override
  void dispose() {
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
        _scannedCN!,
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
      setState(() => _error = e.toString());
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
          'Escanear QR',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: _showForm ? _buildForm(theme) : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                setState(() {
                  _scannedCN = barcode.rawValue;
                  _showForm = true;
                });
                break;
              }
            }
          },
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Código Nacional: $_scannedCN',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Sólido'),
                    value: 'solid',
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Líquido'),
                    value: 'liquid',
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                helperText: 'Introduce la cantidad en ${_getUnitLabel()}',
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
    );
  }
}
