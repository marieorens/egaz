import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:egaz/pages_client/customer_profile.dart';
import 'package:egaz/pages_client/customer_shopping_cart.dart';
import 'package:egaz/pages_client/customer_history.dart';
import 'package:egaz/pages_client/store_detail_page.dart';
import 'dart:typed_data';
import 'package:egaz/database/database_egaz.dart';
import 'package:lottie/lottie.dart'; 

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class Store {
  final String id; 
  final String name;
  final String location;
  final String openingHours;
  final String closingHours;
  final String distance;
  final Uint8List? photo;

  Store({
    required this.id,
    required this.name,
    required this.location,
    required this.openingHours,
    required this.closingHours,
    required this.distance,
    this.photo,
  });
}

class _CustomerScreenState extends State<CustomerScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const CustomerHomeScreen(),
    const CartPage(),
    const PurchaseHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[selectedIndex],
      bottomNavigationBar: SlidingClippedNavBar(
        backgroundColor: Colors.white,
        onButtonPressed: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        iconSize: 35,
        activeColor: const Color.fromARGB(255, 43, 0, 255),
        selectedIndex: selectedIndex,
        barItems: [
          BarItem(
            icon: Icons.home,
            title: 'Accueil',
          ),
          BarItem(
            icon: Icons.shopping_cart,
            title: 'Panier',
          ),
          BarItem(
            icon: Icons.history,
            title: 'Mes achats',
          ),
        ],
      ),
    );
  }
}

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<Store> stores = [];
  List<Store> filteredStores = []; 
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVendeurs();
  }

  Future<void> _loadVendeurs() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> vendeurs = await dbHelper.getAllVendeurs();

    
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      stores = vendeurs.map((vendeur) {
        return Store(
          id: vendeur['id'] ?? 'ID inconnu',
          name: vendeur['nom_boutique'] ?? 'Nom inconnu',
          location: vendeur['localisation_boutique'] ?? 'Localisation inconnue',
          openingHours: vendeur['heure_ouverture'] ?? '09:00',
          closingHours: vendeur['heure_fermeture'] ?? '20:00',
          distance: '2.1km',
          photo: vendeur['photo'] != null ? Uint8List.fromList(vendeur['photo']) : null,
        );
      }).toList();
      filteredStores = stores; 
    });
  }

  void _filterStores(String query) {
    setState(() {
      filteredStores = stores
          .where((store) =>
              store.name.toLowerCase().contains(query.toLowerCase()) ||
              store.location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/images/nobody.json', 
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun vendeur',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> carouselItems = [
      {
        'image': 'assets/images/gaze.jpg',
        'title': 'Pour votre confort...',
      },
      {
        'image': 'assets/images/comfort.jpg',
        'title': 'Depuis chez vous...',
      },
      {
        'image': 'assets/images/delivery.jpg',
        'title': 'Livraison rapide...',
      },
    ];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Text(
                  'e-gaz',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
            ),
            items: carouselItems.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Text(
                            item['title']!,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 3.0,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.pink.shade200],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.green,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une boutique',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 10.0),
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: _filterStores, 
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () {
                        _filterStores(_searchController.text); 
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadVendeurs,
              child: filteredStores.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = filteredStores[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: store.photo != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        store.photo!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.store),
                            ),
                            title: Text(
                              store.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  store.location,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Heures d\'ouverture: ${store.openingHours} - ${store.closingHours}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  store.distance,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoreDetailPage(store: store),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}