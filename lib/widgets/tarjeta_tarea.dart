import 'package:flutter/material.dart';

class TarjetaTarea extends StatelessWidget {
  final String titulo;
  final String meta;
  final String prioridad;
  final bool completada;
  final VoidCallback onToggle;
  final VoidCallback onEliminar;
  final VoidCallback onAbrir;

  const TarjetaTarea({
    super.key,
    required this.titulo,
    required this.meta,
    required this.prioridad,
    required this.completada,
    required this.onToggle,
    required this.onEliminar,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAbrir,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: completada
                  ? 'Marcar como pendiente'
                  : 'Marcar como completada',
              onPressed: onToggle,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                completada ? Icons.check_box : Icons.check_box_outline_blank,
                size: 22,
                color: const Color(0xFF453A7A),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: completada
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    meta,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F0F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                prioridad,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF453A7A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Eliminar tarea',
              onPressed: onEliminar,
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
