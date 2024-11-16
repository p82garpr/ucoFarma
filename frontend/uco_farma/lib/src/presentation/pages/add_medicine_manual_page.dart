import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMedicineManualPage extends StatefulWidget {
  const AddMedicineManualPage({super.key});

  @override
  State<AddMedicineManualPage> createState() => _AddMedicineManualPageState();
}

class _AddMedicineManualPageState extends State<AddMedicineManualPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  bool _isLoading = false;

  //TODO: ESTE METODO ES TEMPORAL, HAY QUE HACERLO LLAMANDO AL PROVIDER DE MEDICINES QUE CREAREMOS EN EL PROYECTO
  Future<void> _addMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('TU_URL_API/medicines'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'cn': _codigoController.text}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento añadido con éxito')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Error al añadir el medicamento');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Medicamento Manual'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código Nacional',
                  hintText: 'Introduce el código nacional del medicamento',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce el código nacional';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _addMedicine,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Añadir Medicamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}