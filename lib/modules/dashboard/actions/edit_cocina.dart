import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remixicon/remixicon.dart';

class EditCocinaScreen extends StatefulWidget {
  final QueryDocumentSnapshot document;

  const EditCocinaScreen({super.key, required this.document});

  @override
  State<EditCocinaScreen> createState() => _EditCocinaScreenState();
}

class _EditCocinaScreenState extends State<EditCocinaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _articuloController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _especificacionesController;
  late TextEditingController _numeroProductoController;
  late TextEditingController _numeroSerieController;
  late TextEditingController _antiguedadController;
  late TextEditingController _valorAproxController;
  late TextEditingController _responsableController;
  late TextEditingController _reciboController;
  late TextEditingController _ubicacionController;

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>;
    _articuloController = TextEditingController(text: data['articulo']?.toString() ?? '');
    _marcaController = TextEditingController(text: data['marca']?.toString() ?? '');
    _modeloController = TextEditingController(text: data['modelo']?.toString() ?? '');
    _especificacionesController = TextEditingController(text: data['especificaciones']?.toString() ?? '');
    _numeroProductoController = TextEditingController(text: data['numero_producto']?.toString() ?? '');
    _numeroSerieController = TextEditingController(text: data['numero_serie']?.toString() ?? '');
    _antiguedadController = TextEditingController(text: data['antiguedad']?.toString() ?? '');
    _valorAproxController = TextEditingController(text: data['valor_aprox']?.toString() ?? '');
    _responsableController = TextEditingController(text: data['responsable']?.toString() ?? '');
    _reciboController = TextEditingController(text: data['recibo']?.toString() ?? '');
    _ubicacionController = TextEditingController(text: data['ubicacion']?.toString() ?? '');
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('cocina')
            .doc(widget.document.id)
            .update({
          'articulo': _articuloController.text,
          'marca': _marcaController.text,
          'modelo': _modeloController.text,
          'especificaciones': _especificacionesController.text,
          'numero_producto': _numeroProductoController.text,
          'numero_serie': _numeroSerieController.text,
          'antiguedad': _antiguedadController.text,
          'valor_aprox': double.tryParse(_valorAproxController.text) ?? 0.0,
          'responsable': _responsableController.text,
          'recibo': _reciboController.text,
          'ubicacion': _ubicacionController.text,
        });
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${e.toString()}')),
        );
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Fila 1: Artículo y Marca
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildEditField("Artículo", _articuloController, Remix.pencil_line)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildEditField("Marca", _marcaController, Remix.trademark_line)),
                      ],
                    ),
                    // Fila 2: Modelo y Especificaciones
                    Row(
                      children: [
                        Expanded(child: _buildEditField("Modelo", _modeloController, Remix.sound_module_line)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildEditField("Especificaciones", _especificacionesController, Remix.file_list_line)),
                      ],
                    ),
                    // Fila 3: N° Producto y N° Serie
                    Row(
                      children: [
                        Expanded(child: _buildEditField("N° Producto", _numeroProductoController, Remix.barcode_line)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildEditField("N° Serie", _numeroSerieController, Remix.shield_keyhole_line)),
                      ],
                    ),
                    // Fila 4: Antigüedad y Valor Aprox.
                    Row(
                      children: [
                        Expanded(child: _buildEditField("Antigüedad", _antiguedadController, Remix.history_line)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildEditField("Valor Aprox.", _valorAproxController, Remix.money_dollar_circle_line)),
                      ],
                    ),
                    // Fila 5: Responsable y Ubicación
                    Row(
                      children: [
                        Expanded(child: _buildEditField("Responsable", _responsableController, Remix.user_line)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildEditField("Recibo", _reciboController, Remix.check_line)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildEditField("Ubicación", _ubicacionController, Remix.mark_pen_line)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(
                                0xFF971B81), // Color del texto e ícono
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Cancelar"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          label: const Text("Guardar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF009FE3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _guardarCambios,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildEditField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value?.isEmpty ?? true ? 'Campo obligatorio' : null,
      ),
    );
  }

  @override
  void dispose() {
    _articuloController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _especificacionesController.dispose();
    _numeroProductoController.dispose();
    _numeroSerieController.dispose();
    _antiguedadController.dispose();
    _valorAproxController.dispose();
    _responsableController.dispose();
    _reciboController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}