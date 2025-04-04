import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class DetalleProductoScreen extends StatefulWidget {
  final String documentId;

  const DetalleProductoScreen({super.key, required this.documentId});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
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
          .collection('oxxokids')
          .doc(widget.documentId)
          .update({
        'cantidad': int.parse(_cantidadController.text),
        'stock_minimo': _stockMinimoController.text.isNotEmpty
            ? int.parse(_stockMinimoController.text)
            : null,
      });

      // Verificar si hay stock bajo después de actualizar
      final cantidad = int.parse(_cantidadController.text);
      final stockMinimo = _stockMinimoController.text.isNotEmpty
          ? int.parse(_stockMinimoController.text)
          : null;

      if (stockMinimo != null && cantidad <= stockMinimo) {
        await _crearNotificacionStockBajo(
          productoId: widget.documentId,
          nombreProducto: _cantidadController.text, // Aquí deberías obtener el nombre real
          stockActual: cantidad,
          stockMinimo: stockMinimo,
        );
      }

      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: ${e.toString()}')),
      );
    }
  }

  Future<void> _crearNotificacionStockBajo({
  required String productoId,
  required String nombreProducto,
  required int stockActual,
  required int stockMinimo,
}) async {
  try {
    // Primero verifica si ya existe una notificación no leída para este producto
    final query = await FirebaseFirestore.instance
        .collection('notificaciones')
        .where('documentoId', isEqualTo: productoId)
        .where('leida', isEqualTo: false)
        .where('tipo', isEqualTo: 'stock_bajo')
        .get();

    // Si no existe notificación previa, crea una nueva
    if (query.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('notificaciones').add({
        'titulo': '⚠️ Stock bajo en OXXO Kids',
        'mensaje': 'El producto "$nombreProducto" tiene stock bajo ($stockActual unidades). Stock mínimo: $stockMinimo',
        'documentoId': productoId,
        'leida': false,
        'fecha': FieldValue.serverTimestamp(),
        'tipo': 'stock_bajo',
        'categoria': 'oxxokids',
        'vista': false, // Nuevo campo para control visual
      });
      print('Notificación de stock bajo creada para $nombreProducto');
    }
  } catch (e) {
    print('Error al crear notificación de stock bajo: $e');
  }
}

  Widget _buildInfoRow(String label, dynamic value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 10),
          ],
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value?.toString() ?? 'No especificado'),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isNumber,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _actualizarProducto,
            ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('oxxokids')
            .doc(widget.documentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Producto no encontrado'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          
          // Inicializar controladores con los valores actuales
          if (_cantidadController.text.isEmpty) {
            _cantidadController.text = data['cantidad'].toString();
          }
          if (_stockMinimoController.text.isEmpty && data['stock_minimo'] != null) {
            _stockMinimoController.text = data['stock_minimo'].toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isEditing) ...[
                  _buildInfoRow('Artículo', data['articulo'], icon: Remix.shopping_bag_line),
                  _buildInfoRow('Cantidad', data['cantidad'], icon: Remix.archive_stack_line),
                  _buildInfoRow('Stock mínimo', data['stock_minimo'] ?? 'No definido', icon: Remix.alarm_warning_line),
                  _buildInfoRow('Marca', data['marca'], icon: Remix.trademark_line),
                  _buildInfoRow('Modelo', data['modelo'], icon: Remix.hashtag),
                  _buildInfoRow('Ubicación', data['ubicacion'], icon: Remix.map_line),
                  // Agrega más campos según necesites
                ] else ...[
                  _buildEditableField('Cantidad', _cantidadController, true),
                  _buildEditableField('Stock mínimo', _stockMinimoController, true),
                  const SizedBox(height: 20),
                  const Text(
                    'Nota: Si actualizas la cantidad y queda por debajo del stock mínimo, se generará una notificación automáticamente.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
                
                // Mostrar alerta si el stock está bajo
                if (!_isEditing && data['stock_minimo'] != null && data['cantidad'] <= data['stock_minimo'])
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Remix.alarm_warning_fill, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ALERTA: Stock bajo (${data['cantidad']}/${data['stock_minimo']})',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}