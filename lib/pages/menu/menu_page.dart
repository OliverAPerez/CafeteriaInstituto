
import 'package:carousel_slider/carousel_options.dart';
import 'package:coffee_shop/components/menupage/carrusel_slider_menu_page.dart';
import 'package:coffee_shop/components/menupage/menu_button.dart';
import 'package:coffee_shop/components/navbar/custom_navbar.dart';
import 'package:coffee_shop/firestorelogic/menu/firestore_logic.dart';
import 'package:flutter/material.dart';
// Asegúrate de reemplazar esto con la ruta correcta

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String selectedCategory = 'Cafe';
  final List<String> categories = ['Cafe', 'Bebidas', 'Bocadillos', 'Snacks', 'Bolleria'];
  final List<String> imgList = [
    'assets/images/img1.png',
    'assets/images/img2.png',
    'assets/images/img3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Menú Cafetería'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(
            color: Color.fromARGB(0, 33, 139, 81),
            height: 20,
            thickness: 2,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 20),
          CarouselSliderMenuPage(
            imgList: imgList,
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              aspectRatio: 16 / 9,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              pageSnapping: true,
              reverse: false,
              scrollPhysics: const BouncingScrollPhysics(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: MenuButton(
                    text: category,
                    onTap: () {
                      setState(() {
                        selectedCategory = category; // Actualiza la categoría seleccionada cuando se toca el botón
                      });
                    },
                    isSelected: selectedCategory == category, // El botón está seleccionado si su categoría es la categoría seleccionada
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FirestoreMenu(category: selectedCategory), // Añade esta línea para mostrar los productos de la categoría seleccionada
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0), // Aquí se ha reemplazado el Container con CustomNavBar
    );
  }
}
