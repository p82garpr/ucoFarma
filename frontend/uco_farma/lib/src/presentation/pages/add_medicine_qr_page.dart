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
  final _frequencyController = TextEditingController(text: '0');
  final _doseQuantityController = TextEditingController(text: '0');
  String? _medicineName;
  
  bool _isLoading = false;
  String? _error;
  String _selectedType = 'solid';
  String? _scannedCN;
  bool _showForm = false;

  Future<void> _getMedicineName(String cn) async {
    final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
    
    try {
      final result = await medicineProvider.getMedicineCimaInfo(cn);
      if (result) {
        setState(() {
          _medicineName = medicineProvider.cimaMedicine?.nombre;
        });
      }
    } catch (e) {
      // Manejar el error si es necesario
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _scannedCN = barcode.rawValue;
          _showForm = true;
        });
        await _getMedicineName(barcode.rawValue!);
        break;
      }
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
                medicineName: _medicineName,
                onAddMedicine: _addMedicine,
                onTypeChanged: (value) => setState(() => _selectedType = value),
              ),
            )
          : _buildQRScanner(theme),
    );
  }
  
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
        double.parse(_doseQuantityController.text),
        false,
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

  Widget _buildQRScanner(ThemeData theme) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: _onDetect,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        if (_error != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: theme.colorScheme.error,
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.onError),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
