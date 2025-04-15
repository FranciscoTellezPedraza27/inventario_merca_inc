import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remixicon/remixicon.dart';

class EditOxxoAScreen extends StatefulWidget {
  final QueryDocumentSnapshot document;

  const EditOxxoAScreen({super.key, required this.document});

  @override
  State<EditOxxoAScreen> createState() => _EditOxxoAScreenState();
}

class _EditOxxoAScreenState extends State<EditOxxoAScreen> {
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
  late TextEditingController _stockMinimoController;

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
    _stockMinimoController = TextEditingController(
    text: data['stock_minimo']?.toString() ?? '' // Maneja null correctamente
);
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('oxxoadultos')
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
          // En _guardarCambios():
'stock_minimo': _stockMinimoController.text.isNotEmpty 
    ? int.tryParse(_stockMinimoController.text) ?? 0 
    : 0, // Guardar 0 si está vacío
        });
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${e.toString()}')),
        );
      }
    }
  }

    // Añadir este nuevo método
Widget _buildCompactEditableField(
    String label, TextEditingController controller, IconData icon) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.grey, size: 24),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
            isDense: true,
            // Mostrar placeholder cuando está vacío
            hintText: controller.text.isEmpty ? "No definido" : null,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 14),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isNotEmpty && int.tryParse(value) == null) { // Permitir vacío
              return 'Debe ser un número';
            }
            return null;
          },
        ),
      ),
      if (label == 'Stock Mínimo')
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: controller.text.isEmpty 
              ? const Text(
                  'Este producto no cuenta con stock mínimo',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                )
              : const Text(
                  'Nota: Stock bajo generará notificación automática',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
    ],
  );
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
                    Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Editar artículo',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
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
                        Expanded(child: _buildEditField("Recibo", _reciboController, Remix.check_line))
                      ],
                    ),
                    Row(
  crossAxisAlignment: CrossAxisAlignment.start, // Alinear elementos en la parte superior
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start, // Alinear contenido en la parte superior
        children: [
          _buildEditField("Ubicación", _ubicacionController, Remix.mark_pen_line),
        ],
      ),
    ),
    const SizedBox(width: 20),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start, // Alinear contenido en la parte superior
        children: [
          _buildCompactEditableField("Stock Mínimo", _stockMinimoController, Remix.box_1_line),
        ],
      ),
    ),
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
    _stockMinimoController.dispose();
    super.dispose();
  }
}