import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shoplist_provider.dart';

class GeneralInfoWidget extends StatefulWidget {
  final String cn;
  
  const GeneralInfoWidget({super.key, required this.cn});

  @override
  State<GeneralInfoWidget> createState() => _GeneralInfoWidgetState();
}

class _GeneralInfoWidgetState extends State<GeneralInfoWidget> {
  void _showInfoDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoIcon({
    required IconData icon,
    required bool isActive,
    required String label,
    required String title,
    required String description,
    bool reverseColors = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        Color iconColor;
        if (reverseColors) {
          iconColor = isActive ? Colors.red : Colors.green;
        } else {
          iconColor = isActive ? Colors.green : Colors.grey;
        }

        return InkWell(
          onTap: () => _showInfoDialog(context, title, description),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MedicineProvider>().getMedicineCimaInfo(widget.cn);
      }
    });
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

    IconData getMedicineIcon() {
      return medicine.formaFarmaceutica.nombre.toLowerCase().contains('líquido') ||
             medicine.formaFarmaceutica.nombre.toLowerCase().contains('solución') ||
             medicine.formaFarmaceutica.nombre.toLowerCase().contains('jarabe')
          ? Icons.medication_liquid
          : Icons.medication;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medicine.nombre,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'CN: ',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: widget.cn,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Nº Registro: ',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: medicine.nregistro,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Laboratorio: ',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: medicine.labtitular,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: medicine.fotos.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        medicine.fotos.first.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(
                              getMedicineIcon(),
                              size: 100,
                              color: theme.colorScheme.primary,
                            ),
                      ),
                    )
                  : Icon(
                      getMedicineIcon(),
                      size: 100,
                      color: theme.colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoIcon(
                  icon: Icons.directions_car,
                  isActive: medicine.conduc,
                  label: 'Conducción',
                  title: 'Conducción',
                  description: 'Este icono indica si el medicamento puede afectar a la capacidad de conducir. Si está en verde, significa que es seguro conducir mientras se toma este medicamento. Si está en rojo, se recomienda no conducir.',
                  reverseColors: true,
                ),
                _buildInfoIcon(
                  icon: Icons.warning_rounded,
                  isActive: medicine.triangulo,
                  label: 'Sensible',
                  title: 'Medicamento de Especial Control',
                  description: 'Este icono indica si el medicamento requiere un seguimiento adicional. Si está en rojo, el medicamento está sujeto a un monitoreo especial por parte de las autoridades sanitarias.',
                  reverseColors: true,
                ),
                _buildInfoIcon(
                  icon: Icons.medical_services_outlined,
                  isActive: medicine.huerfano,
                  label: 'Huérfano',
                  title: 'Medicamento Huérfano',
                  description: 'Este icono indica si el medicamento está designado como huérfano. Los medicamentos huérfanos son aquellos destinados al diagnóstico, prevención o tratamiento de enfermedades raras.',
                ),
                _buildInfoIcon(
                  icon: Icons.receipt_long,
                  isActive: medicine.receta,
                  label: 'Receta',
                  title: 'Receta Médica',
                  description: 'Este icono indica si el medicamento requiere receta médica para su dispensación. Si está en verde, necesitarás una receta médica para obtener este medicamento.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
                
                final userId = authProvider.user?.id;
                final token = authProvider.token;

                if (userId == null || token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Usuario no autenticado')),
                  );
                  return;
                }

                // Mostrar diálogo de confirmación
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: const Text('¿Estás seguro de que deseas eliminar este medicamento?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );

                if (confirm != true || !context.mounted) return;

                final success = await medicineProvider.deleteMedicine(userId, widget.cn, token);

                if (!context.mounted) return;

                if (success) {
                  await authProvider.refreshUserData();
                  if (!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medicamento eliminado con éxito')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(medicineProvider.error ?? 'Error al eliminar el medicamento')),
                  );
                }
              },
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar Medicamento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final shoplistProvider = Provider.of<ShoplistProvider>(context, listen: false);
                
                final userId = authProvider.user?.id;
                final token = authProvider.token;

                if (userId == null || token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Usuario no autenticado')),
                  );
                  return;
                }

                final success = await shoplistProvider.addToShoplist(userId, widget.cn, token);

                if (!context.mounted) return;

                if (success) {
                  await authProvider.refreshUserData();
                  if (!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medicamento añadido a Shoplist')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(shoplistProvider.error ?? 'Error al añadir a Shoplist')),
                  );
                }
              },
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Añadir a Shoplist'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
