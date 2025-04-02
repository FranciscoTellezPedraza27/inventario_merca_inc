import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:remixicon/remixicon.dart'; // Añadir al inicio de add_electronic_screen.dart

class AddOxxoAdultosScreen extends StatefulWidget {
  const AddOxxoAdultosScreen({super.key});

  @override
  _AddOxxoAdultosScreenState createState() => _AddOxxoAdultosScreenState();
}

class _AddOxxoAdultosScreenState extends State<AddOxxoAdultosScreen> {
  dynamic _selectedImage; // Uint8List para web, File para móvil
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
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
  final TextEditingController _reicboController = TextEditingController();
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
        'oxxoadultos/$docId/${DateTime.now().millisecondsSinceEpoch}'
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

  Future<void> _addElectronic() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('oxxoadultos').doc();
      final imageUrl = await _uploadImage(docRef.id);

      final nuevaPeleria = {
        'cantidad': int.parse(_cantidad.text),
        'articulo': _articuloController.text,
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'especificaciones': _especificacionesController.text,
        'numero_producto': _numeroProductoController.text,
        'numero_serie': _numeroSerieController.text,
        'antiguedad': _antiguedadController.text,
        'valor_aprox': double.parse(_valorAproxController.text),
        'responsable': _responsableController.text,
        'recibo': _reicboController.text,
        'ubicacion': _ubicacionController.text,
        'imagen_url': imageUrl ?? 'N/A',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await docRef.set({
        ...nuevaPeleria,
        'imagen_url' : imageUrl ?? 'N/A',
        'timestamp' : FieldValue.serverTimestamp(),
      });

      await _registrarEnHistorial(
        accion: 'Creación',
        productoId: docRef.id,
        datos: nuevaPeleria,
        imageUrl: imageUrl,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto agreado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _registrarEnHistorial({
  required String accion,
  required String productoId,
  required Map<String, dynamic> datos,
  String? imageUrl,
}) async {
  await FirebaseFirestore.instance.collection('historial').add({
    'timestamp': FieldValue.serverTimestamp(),
    'usuario': FirebaseAuth.instance.currentUser?.email ?? 'Sistema', // Reemplaza con tu sistema de autenticación
    'categoria': 'OXXO Adultos',
    'campo': 'Nuevo producto',
    'tipo_movimiento': accion,
    'valor_anterior': 'NO EXISTÍA',
    'valor_nuevo': '''
      Artículo: ${datos['articulo']}
      Marca: ${datos['marca']}
      Modelo: ${datos['modelo']}
      ID: $productoId
      Imagen: ${imageUrl != null ? 'SI' : 'NO'}
    ''',
    'producto_id': productoId, // Para referencia futura
  });
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
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField(_cantidad, 'Cantidad', isNumber: true, icon: Remix.archive_stack_line)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_articuloController, 'Artículo', icon: Remix.shopping_bag_line)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_marcaController, 'Marca', icon: Remix.trademark_line)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_modeloController, 'Modelo', icon: Remix.hashtag)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_especificacionesController, 'Especificaciones', icon: Remix.file_list_line)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_numeroProductoController, 'N° Producto', icon: Remix.qr_code_line)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_numeroSerieController, 'N° Serie', icon: Remix.barcode_line)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_antiguedadController, 'Antigüedad', icon: Remix.hourglass_line)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_valorAproxController, 'Valor Aprox.', isNumber: true, icon: Remix.money_dollar_circle_line)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_responsableController, 'Responsable', icon: Remix.id_card_line)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_reicboController, 'Reicibo / Instructivo', icon: Remix.file_text_line)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_ubicacionController, 'Ubicación', icon: Remix.map_line)),
                  ],
                ),
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
                onPressed: _addElectronic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          prefixIcon: icon != null ? Icon(icon) : null
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo requerido';
          if (isNumber && double.tryParse(value) == null) return 'Número inválido';
          return null;
        },
      ),
    );
  }
}