import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:egaz/pages_authentification/auth_service.dart'; 
import 'package:egaz/database/database_egaz.dart'; 
import 'package:lottie/lottie.dart';

class AffectDeliver extends StatefulWidget {
  const AffectDeliver({super.key});

  @override
  _AffectDeliverState createState() => _AffectDeliverState();
}

class _AffectDeliverState extends State<AffectDeliver> {
  bool isDarkMode = false;
  int selectedIndex = 0; 
  bool showPopup = false;
  String? selectedLivreur;
  List<String> livreurs = []; 
  bool showNotification = false; 

  Future<void> _getLivreurs() async {
    String? vendeurId = await AuthService().getCurrentUserId(); 
    if (vendeurId != null) {
      List<Map<String, dynamic>> livreursData = await DatabaseHelper().getLivreursByVendeurUpdated(vendeurId);
      
      setState(() {
        livreurs = livreursData.map((livreur) => livreur['nom'] as String).toList(); 
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLivreurs(); 
  }

  void _showNotification(String livreur) {
    setState(() {
      selectedLivreur = livreur;
      showNotification = true;
    });

    
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showNotification = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Affectation de livreur',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFEAEAEA),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                key: ValueKey<bool>(isDarkMode),
                color: isDarkMode ? Colors.yellow : Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: livreurs.isEmpty 
             ? Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Lottie.asset(
        'assets/images/nobody.json', 
        width: 150,
        height: 150,
      ),
      const SizedBox(height: 10), 
      Text(
        "Vous n'avez aucun livreur, veuillez en ajouter...",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    ],
  )

              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(livreurs.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          title: Text(
                            livreurs[index],
                            style: GoogleFonts.poppins(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _showNotification(livreurs[index]);
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                                ),
                                child: Text(
                                  'Affecter',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.near_me, 'Commandes', 0),
              _buildNavItem(Icons.store, 'Ma boutique', 1),
              _buildNavItem(Icons.person, 'Profil', 2),
            ],
          ),
        ),
      ),
    
     
      floatingActionButton: showNotification
          ? AnimatedContainer(
              duration: const Duration(seconds: 1),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: Colors.yellow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    'Commande affectée à: $selectedLivreur',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Container(), 
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? (isDarkMode ? Colors.yellow : Colors.blue)
                : (isDarkMode ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isActive
                  ? (isDarkMode ? Colors.yellow : Colors.blue)
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
