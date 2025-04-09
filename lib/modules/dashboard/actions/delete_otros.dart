import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteOtrosScreen extends StatelessWidget {
  final QueryDocumentSnapshot document;

  const DeleteOtrosScreen({super.key, required this.document});

  Future<void> _eliminarRegistro(BuildContext context) async {
  try {
    // 1. Guardar datos del registro antes de eliminar (para historial)
    final datosEliminados = document.data() as Map<String, dynamic>;
    
    // 2. Eliminar el documento
    await FirebaseFirestore.instance
        .collection('otros')
        .doc(document.id)
        .delete();

    // 3. Registrar en historial
    await FirebaseFirestore.instance.collection('historial').add({
      'timestamp': FieldValue.serverTimestamp(),
      'usuario': FirebaseAuth.instance.currentUser?.email ?? 'Sistema', // Reemplaza con tu sistema de autenticación
      'categoria': 'Otros',
      'campo': 'Eliminación completa',
      'tipo_movimiento': 'Eliminación',
      'valor_anterior': '${datosEliminados['articulo']} (ID: ${document.id})',
      'valor_nuevo': 'REGISTRO ELIMINADO',
    });

    // 4. Cerrar y notificar
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro eliminado y registrado en historial'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
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
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  '¿Eliminar registro permanentemente?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  'Esta acción no se puede deshacer',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    ElevatedButton.icon(
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009FE3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        )
                      ),
                      onPressed: () => _eliminarRegistro(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}