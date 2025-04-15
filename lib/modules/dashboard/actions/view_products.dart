import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remixicon/remixicon.dart';

class ViewProductsScreen extends StatelessWidget {
  final QueryDocumentSnapshot document;

  const ViewProductsScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final data = document.data() as Map<String, dynamic>;
    final String? imageUrl = (data['imagen_url'] as String? ?? '').trim();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Stack (
        clipBehavior: Clip.none,
        children: [
        Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 800),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Imagen (SIEMPRE visible)
            Expanded(
              flex: 4,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'N/A')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      )
                    : Center(
                        child: Text(
                          'Imagen no disponible',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 20),
            // Sección de Detalles
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Vista detallada del producto',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    _buildDetailRow("Cantidad", data['cantidad'], "Artículo", data['articulo']),
                    _buildDetailRow("Marca", data['marca'], "Modelo", data['modelo']),
                    _buildDetailRow("Especificaciones", data['especificaciones'], "N° Producto", data['numero_prodcuto']),
                    _buildDetailRow("N° Serie", data['numero_serie'], "Antigüedad", data['antiguedad']),
                    _buildDetailRow("Valor Aprox.", data['valor_aprox'] != null 
                        ? "\$${(double.tryParse(data['valor_aprox'].toString())?.toStringAsFixed(2) ?? '0.00')}"
                        : "N/A", "Responsable", data['responsable']),
                    _buildDetailRow("Recibo / Instructivo", data['recibo'], "Ubicación", data['ubicacion']),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: -1,
        right: 5,
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            child: const Icon(
              Remix.close_line,
              color: Color(0xFF971B81),
              size: 35,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      )
      ]
      )
    );
  }

  Widget _buildDetailRow(String title1, dynamic value1, String title2, dynamic value2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDetailItem(title1, value1)),
          const SizedBox(width: 20),
          Expanded(child: _buildDetailItem(title2, value2)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value?.toString() ?? 'N/A',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}