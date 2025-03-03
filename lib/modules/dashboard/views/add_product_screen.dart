import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  _AddInventoryScreenState createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoProd = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _existenciaController = TextEditingController();
  final TextEditingController _existenciaMinimaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  Future<void> _addInventory() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('inventario').add({
          'codigo_producto': _codigoProd.text,
          'nombre': _nombreController.text,
          'categoria': _categoriaController.text,
          'existencia': int.parse(_existenciaController.text),
          'existencia_minima': int.parse(_existenciaMinimaController.text),
          'precio': double.parse(_precioController.text),
        });
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
              'Agregar al Inventario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_codigoProd, 'Código de producto'),
                  _buildTextField(_nombreController, 'Nombre del Producto'),
                  _buildTextField(_categoriaController, 'Categoría'),
                  _buildTextField(_existenciaController, 'Existencia Actual', isNumber: true),
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
                  onPressed: _addInventory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
        )
      );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo requerido';
          if (isNumber && num.tryParse(value) == null) return 'Valor inválido';
          return null;
        },
      ),
    );
  }
}
