import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:egaz/pages_vendeur/order_details.dart';
import 'package:egaz/pages_vendeur/shop_screen.dart'; 
import 'package:egaz/pages_vendeur/profile_screen.dart'; 
import 'package:egaz/database/database_egaz.dart';
import 'package:egaz/pages_authentification/auth_service.dart';
import 'package:egaz/pages_vendeur/seller_notifications.dart';


class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  bool isDarkMode = false;
  int selectedIndex = 0;
  String? userId;
  
  final List<Widget> screens = [
    const SellerScreenHome(), 
    const ShopScreen(),
    const ProfilePage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          selectedIndex == 0
              ? 'Commandes en cours'
              : (selectedIndex == 1 ? 'Ma Boutique' : 'Mon Profil'),
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
               Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
            },
            icon: Icon(
              Icons.notifications,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: screens[
          selectedIndex], 
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
              _buildNavItem(Icons.store, 'Ma Boutique', 1),
              _buildNavItem(Icons.person, 'Profil', 2),
            ],
          ),
        ),
      ),
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




class SellerScreenHome extends StatefulWidget {
  const SellerScreenHome({super.key});

  @override
  _SellerScreenHomeState createState() => _SellerScreenHomeState();
}

class _SellerScreenHomeState extends State<SellerScreenHome> {
  late Future<List<Map<String, dynamic>>> _commandes;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) return;

    setState(() {
      _commandes = _dbHelper.getCommandesByVendeur(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCommandes,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _commandes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final commandes = snapshot.data ?? [];

            if (commandes.isEmpty) {
              return Center(
                child: Text(
                  'Aucune commande trouvée',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: commandes.length,
              itemBuilder: (context, index) => _buildCommandeCard(commandes[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommandeCard(Map<String, dynamic> commande) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          'Commande #${commande['id']}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ${commande['total']} FCFA'),
            Text('Adresse: ${commande['adresse_livraison']}'),
            Text('Date: ${_formatDate(commande['date_commande'])}'),
          ],
        ),
        trailing: IconButton(
           icon: const Icon(Icons.visibility),
           onPressed: () => _showDetails(commande),
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> commande) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OrderDetailPage(
        order: Order(
          id: commande['id'] as int,
          designation: "Commande #${commande['id']}",
          clientName: commande['nom_client'] ?? 'Client non spécifié',
          address: commande['adresse_livraison'] ?? 'Adresse non spécifiée',
          total: (commande['total'] as num).toDouble(),
          date: DateTime.parse(commande['date_commande']),
        ),
      ),
    ),
  );
}

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}h${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
}