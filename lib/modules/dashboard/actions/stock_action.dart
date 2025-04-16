import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el usuario actual
import 'package:intl/intl.dart'; // Para formatear fechas

class EditStockScreen extends StatefulWidget {
  final QueryDocumentSnapshot document;
  final String collectionName;
  final String fieldName;

  const EditStockScreen(
      {super.key,
      required this.document,
      this.collectionName = 'electronicos',
      this.fieldName = 'cantidad'});

  @override
  State<EditStockScreen> createState() => _EditStockScreenState();
}

class _EditStockScreenState extends State<EditStockScreen> {
  late TextEditingController _cantidadController;
  final _formKey = GlobalKey<FormState>();

    final Map<String, String> _nombresCategorias = {
  'oxxokids': 'OXXO Kids',
  'oxxoadultos': 'OXXO Adultos',
  'electronicos': 'Electrónicos',
  'papeleria': 'Papelería',
  'sublimacion': 'Sublimación',
  'produccion': 'Producción',
  'mobiliario': 'Mobiliario',
  'coina': 'Cocina',
  'limpieza': 'Limpieza',
  'herramientas': 'Herramientas',
  'otros': 'Otros'
};


  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>;
    _cantidadController = TextEditingController(
      text: (data['cantidad']?.toString() ?? '0'),
    );
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

  final nuevaCantidad = int.tryParse(_cantidadController.text) ?? 0;
  final data = widget.document.data() as Map<String, dynamic>;
  
  // Corregido: manejo seguro de tipos
  final cantidadAnterior = int.tryParse(data[widget.fieldName]?.toString() ?? '') ?? 0;

    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.document.id)
          .update({widget.fieldName: nuevaCantidad});

      if (nuevaCantidad != cantidadAnterior) {
        await _registrarCambioHistorial(cantidadAnterior, nuevaCantidad);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cambios guardados!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _registrarCambioHistorial(int cantidadAnterior, int nuevaCantidad) async {
    final user = FirebaseAuth.instance.currentUser;
    final data = widget.document.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('historial').add({
      'timestamp': FieldValue.serverTimestamp(),
      'usuario': user?.email ?? 'Sistema',
      'categoria': _nombresCategorias[widget.collectionName] ?? 
                  widget.collectionName[0].toUpperCase() + 
                  widget.collectionName.substring(1),
      'campo': 'Cantidad',
      'tipo_movimiento': 'Modificación de stock',
      'valor_anterior': cantidadAnterior.toString(),
      'valor_nuevo': nuevaCantidad.toString(),
      'producto_id': widget.document.id,
      'imagen_url': data['imagen_url'] ?? 'N/A',
    });
  }

@override
Widget build(BuildContext context) {
  return Dialog(
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.all(15),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 250),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Editar Cantidad",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cantidadController,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Nueva cantidad',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                  suffixIcon: IconButton(
                    icon: const Icon(Remix.restart_line, size: 20),
                    onPressed: () {
                      final original = (widget.document.data() as Map<String, dynamic>)['cantidad']?.toString() ?? '0';
                      _cantidadController.text = original;
                      _cantidadController.selection = 
                        TextSelection.collapsed(offset: original.length);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese una cantidad';
                  final parsed = int.tryParse(value);
                  if (parsed == null) return 'Solo números enteros';
                  if (parsed < 0) return 'No puede ser negativo';
                  return null;
                },
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF971B81),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _guardarCambios,
                    label: const Text("Guardar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009FE3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
