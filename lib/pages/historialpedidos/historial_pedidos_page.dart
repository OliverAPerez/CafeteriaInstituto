import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffee_shop/firestorelogic/historialpedidos/historial_pedidos_logic.dart';
import 'package:intl/intl.dart';

class HistorialPedidosPage extends StatefulWidget {
  final User user;

  const HistorialPedidosPage({Key? key, required this.user}) : super(key: key);

  @override
  _HistorialPedidosPageState createState() => _HistorialPedidosPageState();
}

class _HistorialPedidosPageState extends State<HistorialPedidosPage> {
  late HistorialPedidosLogic _historialPedidosLogic;

  @override
  void initState() {
    super.initState();
    _historialPedidosLogic = HistorialPedidosLogic(user: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 230,
            child: _historialPedidosLogic,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').doc(widget.user!.uid).collection('historialpedidos').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return buildOrderItem(context, document);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderItem(BuildContext context, DocumentSnapshot order) {
    // Asegúrate de que los datos del pedido sean un Map<String, dynamic>
    if (order.data() is! Map<String, dynamic>) {
      return const Text('Error: los datos del pedido no son válidos');
    }

    final orderData = order.data() as Map<String, dynamic>;
    double total = 0;
    List<Widget> productList = [];

    // Asegúrate de que 'productos' sea una lista
    if (orderData['productos'] is! List) {
      return const Text('Error: los productos del pedido no son válidos');
    }

    for (var product in orderData['productos']) {
      // Asegúrate de que cada producto sea un Map<String, dynamic>
      if (product is! Map<String, dynamic>) {
        continue;
      }

      final productData = product as Map<String, dynamic>;
      total += productData['precio'];
      productList.add(
        ListTile(
          title: Text(productData['nombre']),
          subtitle: Text('Precio: ${productData['precio']}'),
        ),
      );
    }

    return Card(
      child: ExpansionTile(
        title: Text('Pedido ID: ${order.id}'),
        subtitle: Text('Fecha del pedido: ${DateFormat('dd-MM-yyyy').format(orderData['fecha_pedido'].toDate())}'),
        trailing: Text('Total: $total'),
        children: productList,
      ),
    );
  }
}
