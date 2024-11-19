import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/presentation/providers/medicine_provider.dart';
import 'package:uco_farma/src/presentation/widgets/medicine_form.dart';
import '../providers/auth_provider.dart';

class AddMedicineQRPage extends StatefulWidget {
  const AddMedicineQRPage({super.key});

  @override
  State<AddMedicineQRPage> createState() => _AddMedicineQRPageState();
}

class _AddMedicineQRPageState extends State<AddMedicineQRPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _doseQuantityController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String _selectedType = 'solid';
  String? _scannedCN;
  bool _showForm = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _frequencyController.dispose();
    _doseQuantityController.dispose();
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
        throw Exception(
            medicineProvider.error ?? 'Error al añadir el medicamento');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  //TODO: añadir control de error de q solo acepte codigos de 6 digitos
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
      body: _showForm
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: MedicineForm(
                formKey: _formKey,
                quantityController: _quantityController,
                frequencyController: _frequencyController,
                doseQuantityController: _doseQuantityController,
                selectedType: _selectedType,
                isLoading: _isLoading,
                error: _error,
                scannedCN: _scannedCN,
                onAddMedicine: _addMedicine,
                onTypeChanged: (value) => setState(() => _selectedType = value),
              ),
            )
          : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              final String scannedValue = barcodes.first.rawValue!;
              setState(() {
                _scannedCN = scannedValue;
                _showForm = true;
                _error = null;
              });
            }
          },
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Coloca el código QR dentro del marco',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
