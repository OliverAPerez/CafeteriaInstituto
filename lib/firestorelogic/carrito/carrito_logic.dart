import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/pages/resumenpedido/resumen_pedido_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CarritoLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<QueryDocumentSnapshot>> getCartItems() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]); // Devuelve un stream vacío si no hay usuario autenticado
    }

    final cartRef = _firestore.collection('Carrito').doc(user.uid).collection('Productos');

    // Utiliza el método snapshots() para obtener un Stream de los cambios en la colección del carrito
    return cartRef.snapshots().map((snapshot) => snapshot.docs.toList());
  }

  double calculateTotal(List<QueryDocumentSnapshot> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      final data = item.data();
      if (data != null && (data as Map<String, dynamic>).containsKey('precio')) {
        double itemTotal = (data)['precio'].toDouble();
        total += itemTotal;
      }
    }
    return total;
  }

  Widget buildCartItem(BuildContext context, QueryDocumentSnapshot item) {
    final itemData = item.data() as Map<String, dynamic>;
    final name = itemData['nombre'] ?? 'Nombre no disponible';
    final price = (itemData['precio'] as num?)?.toDouble();
    final imageUrl = itemData['imagen'] as String?;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: imageUrl != null ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover) : null,
        title: Text(name),
        subtitle: price != null ? Text('€${price.toStringAsFixed(2)}') : null,
        trailing: IconButton(
          icon: const Icon(Icons.remove_shopping_cart),
          onPressed: () async {
            await item.reference.delete();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto eliminado del carrito')));
          },
        ),
      ),
    );
  }

  Future<void> createOrder(BuildContext context, List<QueryDocumentSnapshot> cartItems) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && cartItems.isNotEmpty) {
      double total = calculateTotal(cartItems);
      // Verificar si el usuario tiene suficiente saldo para realizar el pedido
      bool hasEnoughBalance = await _checkBalance(total);

      if (hasEnoughBalance) {
        // Mostrar la animación de pago (aquí debes implementar tu propia lógica de animación)
        await _showPaymentAnimation(context);

        // Crear el pedido
        String orderId = await _createOrderDocument(user, cartItems);

        // Vaciar el carrito después de un retraso de 3 minutos
        await emptyCartAfterDelay();
        print('Pedido creado con ID: $orderId');
        print('Carrito vaciado');
        // Navegar a la página de resumen del pedido
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResumenPedidoPage(userId: user.uid, orderId: orderId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo insuficiente, por favor recarga.')));
      }
    }
  }

  Future<bool> _checkBalance(double total) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      double saldo = ((userDoc.data() as Map<String, dynamic>?)?['saldo'] as num?)?.toDouble() ?? 0.0;
      print('Saldo del usuario: $saldo');
      print('Total del carrito: $total');
      return saldo >= total;
    }
    return false;
  }

  Future<void> _showPaymentAnimation(BuildContext context) async {
    // Muestra un diálogo de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Text("Procesando pago..."),
            ],
          ),
        );
      },
    );

    // Cierra el diálogo de progreso
    Navigator.pop(context);
  }

  Future<String> _createOrderDocument(User user, List<QueryDocumentSnapshot> cartItems) async {
    String userId = user.uid;
    Map<String, dynamic> orderData = {
      'fecha_pedido': Timestamp.now(),
      'productos': cartItems.map((item) => item.data()).toList(), // Lista de productos en el pedido
      'precio_total': calculateTotal(cartItems),
    };

    // Crear un nuevo documento de pedido en la subcolección 'historialpedidos' del usuario
    DocumentReference orderDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).collection('historialpedidos').add(orderData);

    // Devolver el ID del pedido
    return orderDoc.id;
  }

  Future<void> emptyCartAfterDelay() async {
    const cartEmptyTime = Duration(minutes: 3);
    await Future.delayed(cartEmptyTime);
    await emptyCart();
  }

  Future<void> emptyCart() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Eliminar todos los documentos de la colección de carrito del usuario
      final cartRef = _firestore.collection('Carrito').doc(user.uid).collection('Productos');
      final cartSnapshot = await cartRef.get();
      for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }
}
