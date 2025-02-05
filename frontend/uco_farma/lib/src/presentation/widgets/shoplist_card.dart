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

    return Dismissible(
      key: Key(medicine.cn),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: theme.colorScheme.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: const Text('¿Deseas eliminar este medicamento de la lista de compras?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
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
      child: Card(
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
      ),
    );
  }
}