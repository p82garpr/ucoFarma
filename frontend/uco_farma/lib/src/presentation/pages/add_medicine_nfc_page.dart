import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../providers/auth_provider.dart';

class AddMedicineNFCPage extends StatefulWidget {
  const AddMedicineNFCPage({super.key});

  @override
  State<AddMedicineNFCPage> createState() => _AddMedicineNFCPageState();
}

class _AddMedicineNFCPageState extends State<AddMedicineNFCPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _doseQuantityController = TextEditingController();
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

  void _startNfcScan() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          // Aquí procesamos los datos del tag NFC
          // Este es un ejemplo, ajusta según el formato de tus tags NFC
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

          await NfcManager.instance.stopSession();
        } catch (e) {
          setState(() => _error = e.toString());
        }
      },
    );
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
      body: _showForm ? _buildForm(theme) : _buildNfcScanner(theme),
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
                prefixIcon: Icon(_selectedType == 'solid'
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
