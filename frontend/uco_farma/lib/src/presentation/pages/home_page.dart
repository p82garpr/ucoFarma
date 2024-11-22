import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/presentation/pages/add_medicine_nfc_page.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../widgets/medicines_card.dart';
import '../widgets/shoplist_card.dart';
import 'add_medicine_manual_page.dart';
import 'add_medicine_qr_page.dart';
import 'medicine_info_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildInventoryPage();
      case 1:
        return _buildShoplistPage();
      case 2:
        return const Center(child: Text('ChatBot'));
      case 3:
        return const ProfilePage();
      default:
        return _buildInventoryPage();
    }
  }

  Widget _buildInventoryPage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.user?.medicines == null ||
                authProvider.user!.medicines!.isEmpty
            ? const Center(
                child: Text(
                  'No hay medicamentos registrados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: authProvider.user!.medicines!.length,
                itemBuilder: (context, index) {
                  final medicine = authProvider.user!.medicines![index];
                  return MedicinesCard(
                    medicine: medicine,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MedicineInfoPage(cn: medicine.cn)));
                    },
                  );
                },
              );
      },
    );
  }

  Widget _buildShoplistPage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final shoplistMedicines = authProvider.user?.medicines
            ?.where((medicine) => medicine.wished == true)
            .toList();

        return shoplistMedicines == null || shoplistMedicines.isEmpty
            ? const Center(
                child: Text(
                  'No hay medicamentos en la lista de compras',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: shoplistMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = shoplistMedicines[index];
                  return ShoplistCard(
                    medicine: medicine,
                  );
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 2,
              title: Text(
                'Uco Farma',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    authProvider.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
      body: _getPage(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              elevation: 4,
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Añadir Medicamento'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Manualmente'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddMedicineManualPage()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.nfc),
                            title: const Text('Escanear NFC'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddMedicineNFCPage()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.qr_code),
                            title: const Text('Escanear QR'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddMedicineQRPage()));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.colorScheme.primary,
        indicatorColor: theme.colorScheme.onPrimary.withOpacity(0.2),
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 3,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.inventory_2, color: theme.colorScheme.onPrimary),
            selectedIcon: Icon(Icons.inventory_2, color: theme.colorScheme.onPrimary),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart, color: theme.colorScheme.onPrimary),
            selectedIcon: Icon(Icons.shopping_cart, color: theme.colorScheme.onPrimary),
            label: 'Lista Compra',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat, color: theme.colorScheme.onPrimary),
            selectedIcon: Icon(Icons.chat, color: theme.colorScheme.onPrimary),
            label: 'ChatBot',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: theme.colorScheme.onPrimary),
            selectedIcon: Icon(Icons.person, color: theme.colorScheme.onPrimary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
