import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    print('Estado del usuario: ${authProvider.user}');
    print('Nombre completo: ${authProvider.user?.fullname}');
    print('Email: ${authProvider.user?.email}');
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
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
              authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        //TODO:añadir widget de tarjetas de medicamentos
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Fullname: ${authProvider.user?.fullname}',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              'Email: ${authProvider.user?.email}',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                        // TODO: Navegar a la página de añadir manual
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => AddMedicineManualPage()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.nfc),
                      title: const Text('Escanear NFC'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implementar lectura NFC
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.qr_code),
                      title: const Text('Escanear QR'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implementar lectura QR
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer( //TODO: pensar que se puede poner en el menu superior
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.onPrimary,
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Menú de ${authProvider.user?.fullname ?? "Usuario"}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: theme.colorScheme.primary),
              title: Text('Perfil', style: theme.textTheme.bodyLarge),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
              title: Text('Mis Pedidos', style: theme.textTheme.bodyLarge),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings, color: theme.colorScheme.primary),
              title: Text('Configuración', style: theme.textTheme.bodyLarge),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info, color: theme.colorScheme.primary),
              title: Text('Acerca de', style: theme.textTheme.bodyLarge),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ),//TODO: pensar que botones habra abajo
        child: NavigationBar(
          backgroundColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.onPrimary.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          elevation: 3,
          selectedIndex: 0,
          onDestinationSelected: (int index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              /*case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ShoppingListPage()),
                );
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatBotPage()),
                );
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );*/
            }
          },
          destinations: <NavigationDestination>[
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
      )
    );
  }
}