import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/medicine_model.dart';
import '../providers/auth_provider.dart';
import '../providers/shoplist_provider.dart';

class ShoplistCard extends StatelessWidget {
  final Medicine medicine;

  const ShoplistCard({
    super.key,
    required this.medicine,
  });

  IconData _getMedicineIcon() {
    return medicine.type.toLowerCase() == 'liquid'
        ? Icons.medication_liquid
        : Icons.medication;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _getMedicineIcon(),
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CN: ${medicine.cn}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_shopping_cart),
              color: theme.colorScheme.error,
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

                final success = await shoplistProvider.deleteFromShoplist(userId, medicine.cn, token);

                if (!context.mounted) return;

                if (success) {
                  await authProvider.refreshUserData();
                  if (!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medicamento eliminado de la lista de compras')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(shoplistProvider.error ?? 'Error al eliminar de la lista de compras')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}