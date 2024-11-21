import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            color: theme.colorScheme.onPrimary,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            color: theme.colorScheme.onPrimary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de edición próximamente'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            color: theme.colorScheme.onPrimary,
            onPressed: () => _showChangePasswordDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.fullname[0].toUpperCase(),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullname,
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              theme,
              'Información Personal',
              [
                _buildInfoRow(theme, 'Correo', user.email),
                if (user.birthdate != null)
                  _buildInfoRow(theme, 'Fecha de Nacimiento', user.birthdate!),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              theme,
              'Estadísticas',
              [
                _buildInfoRow(
                  theme,
                  'Medicamentos Registrados',
                  '${user.medicines?.length ?? 0}',
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.onPrimary.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          elevation: 3,
          selectedIndex: 3,
          onDestinationSelected: (int index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
            }
          },
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.inventory_2, color: theme.colorScheme.onPrimary),
              selectedIcon:
                  Icon(Icons.inventory_2, color: theme.colorScheme.onPrimary),
              label: 'Inventario',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart, color: theme.colorScheme.onPrimary),
              selectedIcon:
                  Icon(Icons.shopping_cart, color: theme.colorScheme.onPrimary),
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
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la nueva contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isLoading = true);
                            
                            try {
                              final success = await authProvider.changePassword(
                                newPasswordController.text,
                              );

                              if (!context.mounted) return;

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Contraseña actualizada exitosamente'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authProvider.error ?? 
                                      'Error al actualizar la contraseña'
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}