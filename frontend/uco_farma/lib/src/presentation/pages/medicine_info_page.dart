import 'package:flutter/material.dart';
import '../widgets/general_info_widget.dart';

class MedicineInfoPage extends StatelessWidget {
  final String cn;
  
  const MedicineInfoPage({
    super.key,
    required this.cn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Información del medicamento',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.onPrimary)),
          backgroundColor: theme.colorScheme.primary,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          ),
          bottom: TabBar(
            tabAlignment: TabAlignment.center,
            tabs: const [
              Tab(
                icon: Icon(Icons.info_outlined, size: 17),
                text: 'General',
              ),
              Tab(
                  icon: Icon(Icons.science_outlined, size: 17),
                  text: 'Composición'),
              Tab(icon: Icon(Icons.timer_outlined, size: 17), text: 'Dosis'),
              Tab(
                  icon: Icon(Icons.description_outlined, size: 17),
                  text: 'Documentos'),
            ],
            unselectedLabelColor: theme.colorScheme.onSecondary,
            labelColor: theme.colorScheme.onPrimary,
          ),
        ),
        body: TabBarView(
          children: [
            GeneralInfoWidget(cn: cn),
            const Center(child: Text('Composición')),
            const Center(child: Text('Dosis')),
            const Center(child: Text('Documentos')),
          ],
        ),
      ),
    );
  }
}
