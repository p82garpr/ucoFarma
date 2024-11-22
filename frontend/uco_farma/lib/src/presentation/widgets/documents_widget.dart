import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/medicine_provider.dart';
import 'package:intl/intl.dart';

class DocumentsWidget extends StatefulWidget {
  final String cn;
  const DocumentsWidget({super.key, required this.cn});

  @override
  State<DocumentsWidget> createState() => _DocumentsWidgetState();
}

class _DocumentsWidgetState extends State<DocumentsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MedicineProvider>().getMedicineCimaInfo(widget.cn);
      }
    });
  }

  Future<void> _shareDocument(String url, String title) async {
    try {
      await Share.share(
        url,
        subject: 'Documento: $title',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo compartir el documento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDocumentType(String tipo) {
    switch (tipo) {
      case '1':
        return 'Ficha técnica';
      case '2':
        return 'Prospecto';
      case '3':
        return 'Informe';
      default:
        return 'Plan de gestión de riesgos';
    }
  }

  String _formatDate(int unixTimestamp) {
    // Multiplicamos por 1000 porque DateTime espera milisegundos y UNIX timestamp está en segundos
    final dateUtc =
        DateTime.fromMillisecondsSinceEpoch(unixTimestamp, isUtc: true);
    final dateGmt2 = dateUtc.add(const Duration(hours: 2));
    return DateFormat('dd/MM/yyyy').format(dateGmt2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicineProvider = context.watch<MedicineProvider>();

    if (medicineProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final medicine = medicineProvider.cimaMedicine;
    if (medicine == null || medicine.docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              medicine == null
                  ? (medicineProvider.error ?? 'No hay información disponible')
                  : 'No hay documentos disponibles',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: medicine.docs.length,
      itemBuilder: (context, index) {
        final doc = medicine.docs[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: () => _shareDocument(doc.url, doc.tipo.toString()),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDocumentType(doc.tipo.toString()),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: ${_formatDate(doc.fecha)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.share,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
