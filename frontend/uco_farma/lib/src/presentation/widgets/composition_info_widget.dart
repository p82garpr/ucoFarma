import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';

class CompositionInfoWidget extends StatefulWidget {
  final String cn;
  
  const CompositionInfoWidget({super.key, required this.cn});

  @override
  State<CompositionInfoWidget> createState() => _CompositionInfoWidgetState();
}

class _CompositionInfoWidgetState extends State<CompositionInfoWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MedicineProvider>().getMedicineCimaInfo(widget.cn);
      }
    });
  }

  Widget _buildCompositionList(String title, List<dynamic> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                String content = title == 'Principios Activos'
                    ? 'Los principios activos son las sustancias responsables del efecto terapéutico del medicamento.'
                    : 'Los excipientes son sustancias que se incluyen junto con el principio activo para facilitar su administración o conservación.';
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(title),
                    content: Text(content),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'No hay información disponible',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    item.nombre,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: item.cantidad.isNotEmpty
                    ? Text('${item.cantidad} ${item.unidad}')
                    : null,
                ),
              );
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicineProvider = context.watch<MedicineProvider>();

    if (medicineProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final medicine = medicineProvider.cimaMedicine;
    if (medicine == null) {
      return Center(
        child: Text(
          medicineProvider.error ?? 'No hay información disponible',
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompositionList(
                'Principios Activos',
                medicine.principiosActivos,
                theme,
              ),
              _buildCompositionList(
                'Excipientes',
                medicine.excipientes,
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}