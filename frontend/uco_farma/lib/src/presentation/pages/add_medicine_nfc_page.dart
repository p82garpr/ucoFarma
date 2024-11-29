import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/presentation/providers/medicine_provider.dart';
import 'package:uco_farma/src/presentation/widgets/medicine_form.dart';
import '../providers/auth_provider.dart';

class AddMedicineNFCPage extends StatefulWidget {
  const AddMedicineNFCPage({super.key});

  @override
  State<AddMedicineNFCPage> createState() => _AddMedicineNFCPageState();
}

class _AddMedicineNFCPageState extends State<AddMedicineNFCPage> {
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
  bool _isNfcAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _frequencyController.dispose();
    _doseQuantityController.dispose();
    super.dispose();
  }

  Future<void> _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _isNfcAvailable = isAvailable;
    });
    if (isAvailable) {
      _startNfcScan();
    }
  }

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

  void _startNfcScan() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          var ndef = Ndef.from(tag);
          if (ndef == null) {
            throw 'Tag no es compatible con NDEF';
          }

          var cachedMessage = ndef.cachedMessage;
          if (cachedMessage == null) {
            throw 'No se encontraron datos en el tag';
          }

          var record = cachedMessage.records.first;
          var payload = String.fromCharCodes(record.payload).substring(3);

          setState(() {
            _scannedCN = payload;
            _showForm = true;
          });

          await _getMedicineName(payload);
          await NfcManager.instance.stopSession();
        } catch (e) {
          setState(() => _error = e.toString());
        }
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Escanear NFC',
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
          : _buildNfcScanner(theme),
    );
  }

  Widget _buildNfcScanner(ThemeData theme) {
    if (!_isNfcAvailable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nfc_outlined,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'NFC no disponible en este dispositivo',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nfc,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Acerca el dispositivo al tag NFC',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
