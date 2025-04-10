import 'package:flutter/material.dart';
import 'package:inventario_merca_inc/modules/dashboard/controllers/detalles_productos.dart';
import 'package:remixicon/remixicon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges;

class TopBar extends StatelessWidget {
  final String title;

  const TopBar({super.key, required this.title});

  Stream<QuerySnapshot> _getNotificacionesNoLeidas() {
    return FirebaseFirestore.instance
        .collection('notificaciones')
        .where('leida', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500, // Ancho máximo del diálogo
            maxHeight: 500, // Altura máxima del diálogo
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Lista de notificaciones
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getNotificacionesNoLeidas(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No hay nuevas notificaciones'),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              data['titulo'] ?? 'Sin título',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Muestra el mensaje principal
                                Text(
                                  data['mensaje'] ?? 'Sin mensaje',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    color: Colors.grey[700],
                                  ),
                                ),

                                // Muestra detalle_extra si existe
                                if (data['detalle_extra'] != null &&
                                    data['detalle_extra'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      data['detalle_extra'],
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),

                                // Categoría (se mantiene igual)
                                const SizedBox(height: 4),
                                Text(
                                  'Categoría: ${data['categoria']?.toUpperCase() ?? 'GENERAL'}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              onPressed: () => _marcarComoLeida(doc.id),
                            ),
                            onTap: () => _abrirDetalleProducto(
                                data['documentoId'] ?? '',
                                context,
                                doc.id,
                                data['categoria'] ?? 'oxxokids'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Pie de diálogo
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF971B81), // Color del texto e ícono
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _marcarComoLeida(String docId) {
    FirebaseFirestore.instance
        .collection('notificaciones')
        .doc(docId)
        .update({'leida': true});
  }

  Future<void> _abrirDetalleProducto(
    String productoId,
    BuildContext context,
    String notificacionId,
    String categoria,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54, // Fondo semitransparente
      builder: (context) => DetalleProductoModal(
        documentId: productoId,
        categoria: categoria,
      ),
    );
    _marcarComoLeida(notificacionId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'Poppins',
              )),
          Row(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notificaciones')
                    .where('leida', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;

                  return IconButton(
                    icon: badges.Badge(
                      showBadge: count > 0,
                      badgeContent: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      badgeColor:
                          Colors.red, // Reemplaza badgeStyle por badgeColor
                      padding: const EdgeInsets.all(5),
                      position: badges.BadgePosition.topEnd(top: -5, end: -5),
                      child: const Icon(Remix.notification_3_line),
                    ),
                    onPressed: () => _showNotificationDialog(context),
                  );
                },
              ),
              const SizedBox(width: 10),
              /*const CircleAvatar(
                backgroundImage: AssetImage('assets/images/user_avatar.png'),
              ),*/
            ],
          )
        ],
      ),
    );
  }
}
