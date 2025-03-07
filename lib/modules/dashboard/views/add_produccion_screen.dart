import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProduccionScreen extends StatefulWidget {
  const AddProduccionScreen({super.key});

  @override
  _AddProduccionScreenState createState() => _AddProduccionScreenState();
}

class _AddProduccionScreenState extends State<AddProduccionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidad = TextEditingController();
  final TextEditingController _articuloController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _especificacionesController = TextEditingController();
  final TextEditingController _numeroProductoController = TextEditingController();
  final TextEditingController _numeroSerieController = TextEditingController();
  final TextEditingController _antiguedadController = TextEditingController();
  final TextEditingController _valorAproxController = TextEditingController();
  final TextEditingController _responsableController = TextEditingController();
  final TextEditingController _reciboInstrucController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  Future<void> _addElectronic() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('produccion').doc().set({
          'cantidad': _cantidad.text,
          'articulo': _articuloController.text,
          'marca': _marcaController.text,
          'modelo': _modeloController.text,
          'especificaciones': _especificacionesController.text,
          'numero_producto': _numeroProductoController.text,
          'numero_serie': _numeroSerieController.text,
          'antiguedad': _antiguedadController.text,
          'valor_aprox': double.parse(_valorAproxController.text),
          'responsable': _responsableController.text,
          'recibo': _reciboInstrucController.text,
          'ubicacion': _ubicacionController.text,
          'timestamp': FieldValue.serverTimestamp(), // Agregar marca de tiempo
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
                  _buildTextField(_cantidad, 'Cantidad'),
                  _buildTextField(_articuloController, 'Nombre del artículo'),
                  _buildTextField(_marcaController, 'Marca del artículo'),
                  _buildTextField(_modeloController, 'Modelo del artículo'),
                  _buildTextField(_especificacionesController, 'Especificaciones'),
                  _buildTextField(_numeroProductoController, 'Número del producto'),
                  _buildTextField(_numeroSerieController, 'Número de serie'),
                  _buildTextField(_antiguedadController, 'Antigüedad'),
                  _buildTextField(_valorAproxController, 'Valor Aproximado', isNumber: true),
                  _buildTextField(_responsableController, 'Responsable'),
                  _buildTextField(_reciboInstrucController, 'Recibo/Instructivo'),
                  _buildTextField(_ubicacionController, 'Ubicación'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 244, 242, 242)),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _addElectronic,
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
