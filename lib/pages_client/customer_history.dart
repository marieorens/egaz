import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:egaz/database/database_egaz.dart';
import 'package:egaz/pages_authentification/auth_service.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  late Future<List<Map<String, dynamic>>> _commandes;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) return;

    setState(() {
      _commandes = _dbHelper.getCommandesByClient(userId);
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
          'à ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _showDetails(BuildContext context, int commandeId) async {
    final details = await _dbHelper.getCommandeDetails(commandeId);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Détails de la commande #$commandeId",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: ${_formatDate(details['commande']['date_commande'])}",
                  style: GoogleFonts.poppins(),
                ),
                Text(
                  "Adresse: ${details['commande']['adresse_livraison']}",
                  style: GoogleFonts.poppins(),
                ),
                Text(
                  "Total: ${details['commande']['total']} FCFA",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Divider(),
                Text(
                  "Produits commandés:",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                ...details['produits'].map<Widget>((produit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "- ${produit['designation']}",
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      Text(
                        "x${produit['quantite']}",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${produit['prix']} FCFA",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/images/nobody.json',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        Text(
          "Oups, votre historique est vide...",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Vos prochaines commandes apparaîtront ici",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Historique d'achats",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCommandes,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _commandes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur de chargement\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              );
            }

            final commandes = snapshot.data ?? [];
            final filteredCommandes = commandes.where((commande) {
              final searchLower = _searchQuery.toLowerCase();
              return commande['id'].toString().contains(searchLower) ||
                  commande['adresse_livraison'].toLowerCase().contains(searchLower);
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      filled: true,
                      hintText: "Rechercher une commande...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: filteredCommandes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: filteredCommandes.length,
                            itemBuilder: (context, index) {
                              final commande = filteredCommandes[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.shopping_bag,
                                        color: Colors.blue),
                                  ),
                                  title: Text(
                                    "Commande #${commande['id']}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(commande['date_commande']),
                                        style: GoogleFonts.poppins(fontSize: 13),
                                      ),
                                      Text(
                                        commande['adresse_livraison'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    "${commande['total']} FCFA",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  onTap: () => _showDetails(context, commande['id']),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}