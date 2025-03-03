import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoProd = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _existenciaController = TextEditingController();
  final TextEditingController _existenciaMinimaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  Future<void> _addOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('pedidos').add({
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
          SnackBar(content: Text('Error $e')),
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
              'Agregar pedido',
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
                  onPressed: _addOrder,
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