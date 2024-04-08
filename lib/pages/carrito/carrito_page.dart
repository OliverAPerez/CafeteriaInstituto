import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:coffee_shop/components/navbar/custom_navbar.dart';
import 'package:coffee_shop/firestorelogic/carrito/carrito_logic.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  final CarritoLogic _carritoLogic = CarritoLogic(); // Instancia de CarritoLogic

  @override
  void initState() {
    super.initState();
    _carritoLogic.emptyCartAfterDelay(); // Inicia el temporizador para vaciar el carrito
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Carrito de Compras'),
              floating: true,
              pinned: true,
              snap: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  'assets/images/bg-light.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: _carritoLogic.getCartItems(), // Obtén el Stream de la colección del carrito
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('El carrito está vacío'));
            }

            final cartItems = snapshot.data!;
            double total = _carritoLogic.calculateTotal(cartItems);

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'El carrito se vaciará después de 5 minutos si no se realiza el pedido',
                    style: TextStyle(color: Colors.red, fontSize: 16, textBaseline: TextBaseline.alphabetic),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) => _carritoLogic.buildCartItem(context, cartItems[index]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Total: €${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // Mostrar CircularProgressIndicator mientras se procesa el pago
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                // Mostrar un círculo de progreso en el centro de la pantalla
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          try {
                            // Procesar el pago
                            await _carritoLogic.createOrder(context, cartItems);

                            // Cerrar el diálogo después de un breve retraso para asegurarse de que se cierre el diálogo

                            Navigator.of(context).pop(); // Cierra el diálogo
                          } catch (error) {
                            // Manejar errores aquí, como mostrar un mensaje de error al usuario
                            print('Error al procesar el pago: $error');
                          }
                        },
                        child: const Text('Pagar', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }
}
