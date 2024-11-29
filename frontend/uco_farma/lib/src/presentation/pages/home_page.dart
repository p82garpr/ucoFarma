import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/presentation/pages/add_medicine_nfc_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/medicines_card.dart';
import '../widgets/shoplist_card.dart';
import 'add_medicine_manual_page.dart';
import 'add_medicine_qr_page.dart';
import 'medicine_info_page.dart';
import 'chat_page.dart';
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
        return const ChatPage();
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

  void _showHelpDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guía de Uso'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpSection(
                  'Inventario',
                  'Aquí puedes ver y gestionar tus medicamentos. Usa el botón + para añadir nuevos medicamentos de forma manual, por NFC o QR.',
                  Icons.inventory_2,
                  theme,
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  'Lista de Compra',
                  'Gestiona los medicamentos que necesitas comprar.',
                  Icons.shopping_cart,
                  theme,
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  'ChatBot',
                  'Consulta dudas sobre tus medicamentos con nuestro asistente virtual.',
                  Icons.chat,
                  theme,
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  'Perfil',
                  'Accede a tu información personal y configura tu cuenta.',
                  Icons.person,
                  theme,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpSection(String title, String description, IconData icon, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
              title: Text(
                'UCO Farma',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              backgroundColor: theme.colorScheme.primary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => _showHelpDialog(context, theme),
                  color: theme.colorScheme.onPrimary,
                ),
              ],
            ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/logo-removebg.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
          _getPage(),
        ],
      ),
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
                                      builder: (context) => const AddMedicineManualPage()));
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
                                      builder: (context) => const AddMedicineNFCPage()));
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
                                      builder: (context) => const AddMedicineQRPage()));
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
