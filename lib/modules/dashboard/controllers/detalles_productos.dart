import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remixicon/remixicon.dart';

class DetalleProductoModal extends StatefulWidget {
  final String documentId;
  final String categoria;

  const DetalleProductoModal({
    super.key,
    required this.documentId,
    required this.categoria,
  });

  @override
  State<DetalleProductoModal> createState() => _DetalleProductoModalState();
}

class _DetalleProductoModalState extends State<DetalleProductoModal> {
  Map<String, dynamic>? _productData;
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _stockMinimoController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  Future<void> _actualizarProducto() async {
    try {
      await FirebaseFirestore.instance
          .collection(widget.categoria)
          .doc(widget.documentId)
          .update({
        'cantidad': int.parse(_cantidadController.text),
        'stock_minimo': _stockMinimoController.text.isNotEmpty
            ? int.parse(_stockMinimoController.text)
            : null,
      });
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Producto actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildCompactInfoRow(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactEditableField(
      String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalle del Producto',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, size: 20, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection(widget.categoria)
                  .doc(widget.documentId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Producto no encontrado'),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                _productData = data;

                if (_cantidadController.text.isEmpty) {
                  _cantidadController.text = data['cantidad'].toString();
                }
                if (_stockMinimoController.text.isEmpty &&
                    data['stock_minimo'] != null) {
                  _stockMinimoController.text = data['stock_minimo'].toString();
                }

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isEditing) ...[
                        _buildCompactInfoRow('Artículo', data['articulo'],
                            Remix.shopping_bag_line),
                        _buildCompactInfoRow('Cantidad', data['cantidad'],
                            Remix.archive_stack_line),
                        _buildCompactInfoRow(
                            'Stock mínimo',
                            data['stock_minimo'] ?? 'No definido',
                            Remix.alarm_warning_line),
                        _buildCompactInfoRow(
                            'Marca', data['marca'], Remix.trademark_line),
                        _buildCompactInfoRow(
                            'Modelo', data['modelo'], Remix.hashtag),
                        _buildCompactInfoRow(
                            'Ubicación', data['ubicacion'], Remix.map_line),
                        if (data['stock_minimo'] != null &&
                            data['cantidad'] <= data['stock_minimo'])
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Remix.alarm_warning_fill,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Stock bajo: ${data['cantidad']}/${data['stock_minimo']}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ] else ...[
                        _buildCompactEditableField(
                            'Cantidad', _cantidadController),
                        const SizedBox(height: 12),
                        _buildCompactEditableField(
                            'Stock mínimo', _stockMinimoController),
                        const SizedBox(height: 12),
                        const Text(
                          'Nota: Stock bajo generará notificación automática',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                      Padding(
  padding: const EdgeInsets.only(top: 16),
  child: _isEditing
      ? Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF971B81),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancelar', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _actualizarProducto,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009FE3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Guardar', style: TextStyle(fontSize: 13)),
            ),
          ],
        )
      : Align(
          alignment: Alignment.centerRight,
          child: Container( // Aquí faltaba el parámetro 'child'
            decoration: BoxDecoration(
              color: const Color(0xFFF6A000),
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Remix.edit_box_line,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Editar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => setState(() => _isEditing = true),
            ),
          ),
        ),
),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
