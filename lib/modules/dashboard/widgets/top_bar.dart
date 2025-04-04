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
      builder: (context) => AlertDialog(
        title: const Text('Notificaciones'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: _getNotificacionesNoLeidas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No hay notificaciones nuevas'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(data['titulo'] ?? 'Sin título'),
                      subtitle: Text(data['mensaje'] ?? 'Sin mensaje'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => _marcarComoLeida(doc.id),
                      ),
                      onTap: () => _abrirDetalleProducto(
                        data['documentoId'] ?? '', 
                        context,
                        doc.id
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
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
    String notificacionId
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleProductoScreen(documentId: productoId),
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
          Text(title, style: const TextStyle(fontSize: 22)),
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
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        badgeColor: Colors.red, // Reemplaza badgeStyle por badgeColor
        padding: const EdgeInsets.all(5),
        position: badges.BadgePosition.topEnd(top: -5, end: -5),
        child: const Icon(Remix.notification_3_line),
      ),
      onPressed: () => _showNotificationDialog(context),
    );
  },
),
              const SizedBox(width: 10),
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/user_avatar.png'),
              ),
            ],
          )
        ],
      ),
    );
  }
}