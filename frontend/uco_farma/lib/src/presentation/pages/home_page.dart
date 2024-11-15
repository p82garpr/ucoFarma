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
        child: Text(
          'Bienvenido ${authProvider.user?.fullname ?? authProvider.user?.email}',
          style: theme.textTheme.titleLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
        onPressed: () {
          // Acción del botón
        }
      ),
      drawer: Drawer(
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
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 3,
        selectedIndex: 0,
        onDestinationSelected: (int index) {
          // Manejar la navegación
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home, color: theme.colorScheme.onSurface),
            selectedIcon: Icon(Icons.home, color: theme.colorScheme.primary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
            selectedIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart, color: theme.colorScheme.onSurface),
            selectedIcon: Icon(Icons.shopping_cart, color: theme.colorScheme.primary),
            label: 'Carrito',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: theme.colorScheme.onSurface),
            selectedIcon: Icon(Icons.person, color: theme.colorScheme.primary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}