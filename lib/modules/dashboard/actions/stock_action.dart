import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remixicon/remixicon.dart';

class EditStockScreen extends StatefulWidget {
  final QueryDocumentSnapshot document;
  final String collectionName;
  final String fieldName;

  const EditStockScreen({super.key, required this.document, this.collectionName = 'electronicos', this.fieldName = 'cantidad'});

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
    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.document.id)
          .update({widget.fieldName: _currentValue});
      
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
                fontSize: 18, // Tamaño de fuente más pequeño
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 15),
            // Contenido ajustado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cantidad actual:",
                      style: TextStyle(fontSize: 14), // Texto más pequeño
                    ),
                    Text(
                      '$_currentValue',
                      style: const TextStyle(
                        fontSize: 20, // Tamaño reducido
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009FE3),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Remix.subtract_line, 
                            color: Colors.red, 
                            size: 25), // Ícono más pequeño
                          onPressed: _disminuirCantidad,
                        ),
                        const Text("Disminuir", 
                          style: TextStyle(fontSize: 11)), // Texto más pequeño
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Remix.add_line, 
                            color: Colors.green, 
                            size: 25), // Ícono más pequeño
                          onPressed: _aumentarCantidad,
                        ),
                        const Text("Aumentar", 
                          style: TextStyle(fontSize: 11)), // Texto más pequeño
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
                      vertical: 8
                    ),
                  ),
                  child: const Text("Cancelar", 
                    style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _guardarCambios,
                  label: const Text("Guardar", // Texto más corto
                    style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009FE3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15, // Padding reducido
                      vertical: 8
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