import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>;
    _currentValue = int.tryParse(data['cantidad']?.toString() ?? '') ?? 0;
  }

  void _aumentarCantidad() => setState(() => _currentValue++);
  void _disminuirCantidad() {
    if (_currentValue > 0) setState(() => _currentValue--);
  }

  Future<void> _guardarCambios() async {
    final cantidadAnterior = int.tryParse(
            (widget.document.data() as Map<String, dynamic>)['cantidad']
                    ?.toString() ??
                '') ??
        0;

    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.document.id)
          .update({widget.fieldName: _currentValue});

      // Registrar en historial solo si hubo cambio real
      if (_currentValue != cantidadAnterior) {
        await _registrarCambioHistorial(cantidadAnterior);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _registrarCambioHistorial(int cantidadAnterior) async {
    final user = FirebaseAuth.instance.currentUser;
    final data = widget.document.data() as Map<String, dynamic>;

    // En EditStockScreen, modificar el registro a:
    await FirebaseFirestore.instance.collection('historial').add({
      'timestamp': FieldValue.serverTimestamp(), // Campo unificado
      'usuario': user?.email ?? 'Sistema',
      'categoria': widget.collectionName,
      'campo': 'Cantidad', // Nuevo campo requerido
      'tipo_movimiento': 'Modificación de stock', // Valor unificado
      'valor_anterior': cantidadAnterior.toString(),
      'valor_nuevo': _currentValue.toString(),
      'producto_id': widget.document.id,
      'imagen_url': data['imagen_url'] ?? 'N/A', // Mantener estructura
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(15), // Reducir margen exterior
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            maxWidth: 400, // Ancho máximo del diálogo
            maxHeight: 300 // Altura máxima
            ),
        child: Padding(
          padding: const EdgeInsets.all(15), // Reducir padding interno
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Gestión de Cantidad",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18, // Tamaño de fuente más pequeño
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              // Contenido ajustado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Columna izquierda con la cantidad
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Texto a la izquierda
                    children: [
                      const Text(
                        "Cantidad actual:",
                        style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                      ),
                      SizedBox(
                        width: 125, // Ancho fijo para el contenedor del número
                        child: Center(
                          // Centra solo el número
                          child: Text(
                            '$_currentValue',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Botones a la derecha
                  Row(
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Remix.subtract_line,
                                color: Colors.red, size: 25),
                            onPressed: _disminuirCantidad,
                          ),
                          const Text("Disminuir",
                              style: TextStyle(
                                  fontSize: 11, fontFamily: 'Poppins')),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Remix.add_line,
                                color: Colors.green, size: 25),
                            onPressed: _aumentarCantidad,
                          ),
                          const Text("Aumentar",
                              style: TextStyle(
                                  fontSize: 11, fontFamily: 'Poppins')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Botones más compactos
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF971B81),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, // Padding reducido
                          vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancelar",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        )),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _guardarCambios,
                    label: const Text("Guardar", // Texto más corto
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009FE3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, // Padding reducido
                          vertical: 8),
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
    );
  }
}
