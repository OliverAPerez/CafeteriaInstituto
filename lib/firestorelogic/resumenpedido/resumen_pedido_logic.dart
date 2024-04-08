import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ResumenPedidoLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getOrderDetails(String userId, String orderId) async {
    try {
      DocumentSnapshot orderSnapshot = await _firestore.collection('Users').doc(userId).collection('historialpedidos').doc(orderId).get();
      if (orderSnapshot.exists) {
        print('Detalles del pedido recuperados con éxito: ${orderSnapshot.data()}');
        return orderSnapshot.data() as Map<String, dynamic>;
      } else {
        print('No se encontró el pedido con ID: $orderId');
        return null;
      }
    } catch (e) {
      print('Error al obtener los detalles del pedido: $e');
      return null;
    }
  }

  Widget buildOrderSummary(BuildContext context, Map<String, dynamic> orderData) {
    print('Construyendo resumen del pedido con datos: $orderData');

    final orderId = orderData['orderId'] ?? '';
    final date = orderData['fecha_pedido'] is Timestamp ? (orderData['fecha_pedido'] as Timestamp).toDate() : null;
    final formattedDate = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'Fecha no disponible';
    final total = orderData['precio_total'] ?? 0.0;
    final products = orderData['productos'] as List<dynamic>?;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Text('Pedido #$orderId'),
        Text('Fecha: $formattedDate'),
        Text('Total: €$total'),
        if (products != null)
          for (var product in products)
            ListTile(
              title: Text(product['nombre'] ?? 'Nombre no disponible'),
              subtitle: Text('€${product['precio'] ?? 0.0}'),
            ),
      ],
    );
  }
}
