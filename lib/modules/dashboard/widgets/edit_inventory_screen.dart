import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditInventoryScreen extends StatefulWidget {
  final Map<String, dynamic> existingData;
  final String documentId;

  const EditInventoryScreen({
    super.key,
    required this.existingData,
    required this.documentId,
  });

  @override
  _EditInventoryScreenState createState() => _EditInventoryScreenState();
}

class _EditInventoryScreenState extends State<EditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoProd = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _existenciaController = TextEditingController();
  final TextEditingController _existenciaMinimaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codigoProd.text = widget.existingData['codigo_producto']?.toString() ?? '';
    _nombreController.text = widget.existingData['nombre']?.toString() ?? '';
    _categoriaController.text = widget.existingData['categoria']?.toString() ?? '';
    _existenciaController.text = widget.existingData['existencia']?.toString() ?? '';
    _existenciaMinimaController.text = widget.existingData['existencia_minima']?.toString() ?? '';
    _precioController.text = widget.existingData['precio']?.toString() ?? '';
  }

  Future<void> _updateInventory() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('inventario')
            .doc(widget.documentId)
            .update({
          'codigo_producto': _codigoProd.text,
          'nombre': _nombreController.text,
          'categoria': _categoriaController.text,
          'existencia': int.parse(_existenciaController.text),
          'existencia_minima': int.parse(_existenciaMinimaController.text),
          'precio': double.parse(_precioController.text),
        });
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: enabled ? Colors.grey[200] : Colors.grey[300],
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: enabled ? (value) {
          if (value == null || value.isEmpty) return 'Campo requerido';
          if (isNumber && num.tryParse(value) == null) return 'Valor inválido';
          return null;
        } : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Editar Producto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_codigoProd, 'Código del producto'),
                  _buildTextField(_nombreController, 'Nombre del Producto'),
                  _buildTextField(_categoriaController, 'Categoría'),
                  _buildTextField(_existenciaController, 'Existencia Actual', isNumber: true, enabled: false),
                  _buildTextField(_existenciaMinimaController, 'Existencia Mínima', isNumber: true),
                  _buildTextField(_precioController, 'Precio Unitario', isNumber: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _updateInventory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}