import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:typed_data';
import 'dart:io'; // Añadir al inicio de add_electronic_screen.dart

class AddCocinaScreen extends StatefulWidget {
  const AddCocinaScreen({super.key});

  @override
  _AddCocinaScreenState createState() => _AddCocinaScreenState();
}

class _AddCocinaScreenState extends State<AddCocinaScreen> {
  dynamic _selectedImage;
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

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final Uint8List? bytes = await ImagePickerWeb.getImageAsBytes();
        if (bytes != null) {
          setState(() {
            _selectedImage = bytes;
          });
        }
      } else {
        if (!kIsWeb){
          final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _selectedImage = XFile(image.path);
          });
        }
        }
      }
    } catch (e) {
      print('Error seleccionando imagen: $e');
    }
  }

  Future<String?> _uploadImage(String docId) async {
    if (_selectedImage == null) return null;

    try {
      final ref = FirebaseStorage.instance.ref(
        'cocina/$docId/${DateTime.now().millisecondsSinceEpoch}'
      );

      if (kIsWeb) {
        await ref.putData(_selectedImage as Uint8List);
      } else {
        await ref.putFile(_selectedImage as File);
      }

      return await ref.getDownloadURL();
    } catch (e) {
      print('Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> _addCocina() async {
    if (!_formKey.currentState!.validate()) return;

      try {
        final docRef = FirebaseFirestore.instance.collection('cocina').doc();
        final imageUrl = await _uploadImage(docRef.id);

        await docRef.set({
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
          'imagen_url': imageUrl ?? 'N/A',
          'timestamp': FieldValue.serverTimestamp(), // Agregar marca de tiempo
        });
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
            _buildImagePreview(),
            const SizedBox(height: 10),
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
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _addCocina,
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
  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
            image: _selectedImage != null
                ? DecorationImage(
                    image: kIsWeb
                        ? MemoryImage(_selectedImage as Uint8List)
                        : FileImage(File((_selectedImage as XFile).path)) as ImageProvider,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _selectedImage == null
              ? const Icon(Icons.image, size: 40, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          icon: const Icon(Icons.camera_alt, size: 20),
          label: const Text('Seleccionar imagen'),
          onPressed: _pickImage,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            side: const BorderSide(color: Colors.black54),
          ),
        ),
      ],
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
