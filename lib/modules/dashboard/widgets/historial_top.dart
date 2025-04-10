import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class HistorialTopBar extends StatelessWidget {
  final List<String> categorias;
  final Function(String?) onCategoriaSelected;
  final Function(String) onSearch;
  final VoidCallback onGeneratePDF;
  final String? selectedCategoria; // Nuevo parámetro para el valor seleccionado

  const HistorialTopBar({
    super.key,
    required this.categorias,
    required this.onCategoriaSelected,
    required this.onSearch,
    required this.onGeneratePDF,
    this.selectedCategoria, // Añadido para manejar la categoría seleccionada
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Dropdown de Categorías
          Flexible(
            child: SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: selectedCategoria, // Usa el valor proporcionado
                onChanged: onCategoriaSelected,
                decoration: InputDecoration(  
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
                hint: const Text(
                  'Todas las categorías',
                  overflow: TextOverflow.ellipsis,
                ),
                items: categorias
                    .map((categoria) => DropdownMenuItem(
                          value: categoria,
                          child: Text(
                            categoria,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Barra de Búsqueda
          Expanded(
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Buscar en historial...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón Generar PDF
          ElevatedButton.icon(
            icon: const Icon(Remix.file_pdf_line, size: 20),
            label: const Text('Generar PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF971B81),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onGeneratePDF,
          ),
        ],
      ),
    );
  }
}