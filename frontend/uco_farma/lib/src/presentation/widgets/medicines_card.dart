import 'package:flutter/material.dart';
import 'package:uco_farma/src/domain/models/medicine_model.dart';
import 'package:uco_farma/src/presentation/pages/medicine_info_page.dart';

class MedicinesCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;

  const MedicinesCard({
    super.key,
    required this.medicine,
    this.onTap,
  });

  IconData _getMedicineIcon() {
    return medicine.type.toLowerCase() == 'liquid'
        ? Icons.medication_liquid
        : Icons.medication;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicineInfoPage(cn: medicine.cn),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono a la izquierda
              Icon(
                _getMedicineIcon(),
                size: 40,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(width: 16), // Espaciado

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medicine.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _PulsingText(
                          text:
                              'Cantidad: ${medicine.quantity} ${medicine.type == 'liquid' ? 'ml' : 'unidades'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: medicine.quantity <= 5
                                ? theme.colorScheme.error
                                : null,
                            fontWeight:
                                medicine.quantity <= 5 ? FontWeight.bold : null,
                          ),
                          shouldPulse: medicine.quantity <= 5,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CN: ${medicine.cn}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha o indicador a la derecha (opcional)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool shouldPulse;

  const _PulsingText({
    required this.text,
    this.style,
    this.shouldPulse = false,
  });

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldPulse) {
      return Text(widget.text, style: widget.style);
    }

    return ScaleTransition(
      scale: _animation,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}
