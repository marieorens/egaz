import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:egaz/database/database_egaz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  String? _vendeurId;
  Timer? _notificationTimer; 

  @override
  void initState() {
    super.initState();
    _fetchVendeurId();
  }

  
  Future<void> _fetchVendeurId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _vendeurId = user.uid;
      });
      _fetchNotifications();
      _startAutoRefresh(); 
    }
  }

  
  void _startAutoRefresh() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchNotifications();
    });
  }

 
  Future<void> _fetchNotifications() async {
    if (_vendeurId == null) return;
    List<Map<String, dynamic>> notifications =
        await DatabaseHelper().getNotificationsByVendeur(_vendeurId!);
    setState(() {
      _notifications = notifications;
    });
  }

 
  Future<void> _markAsRead(int id) async {
    await DatabaseHelper().markNotificationAsRead(id);
    _fetchNotifications();
  }

  
  Future<void> _deleteNotification(int id) async {
    await DatabaseHelper().deleteNotification(id);
    _fetchNotifications();
  }

  
  void _showCommandeDetails(int commandeId) async {
    Map<String, dynamic> commandeDetails =
        await DatabaseHelper().getCommandeDetails(commandeId);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Détails de la commande",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Client: ${commandeDetails['client']['nom']}",
                  style: GoogleFonts.poppins()),
              Text("Adresse: ${commandeDetails['commande']['adresse_livraison']}",
                  style: GoogleFonts.poppins()),
              Text("Total: ${commandeDetails['commande']['total']} FCFA",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text("Produits:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ...commandeDetails['produits'].map<Widget>((produit) {
                return Text(
                  "${produit['designation']} x${produit['quantite']} - ${produit['prix']} FCFA",
                  style: GoogleFonts.poppins(),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text("Fermer", style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  
  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Text(
                "Aucune notification",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: notification['etat'] == 'non lue' ? Colors.grey[200] : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      notification['etat'] == 'non lue'
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: Colors.blue,
                    ),
                    title: Text(notification['titre'], style: GoogleFonts.poppins()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message'],
                            style: GoogleFonts.poppins(fontSize: 14)),
                        Text(notification['date_commande'],
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'lire') _markAsRead(notification['id']);
                        if (value == 'supprimer') _deleteNotification(notification['id']);
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(value: 'lire', child: Text('Marquer comme lue')),
                        const PopupMenuItem(value: 'supprimer', child: Text('Supprimer')),
                      ],
                    ),
                    onTap: () {
                      _showCommandeDetails(notification['id_commande']);
                      _markAsRead(notification['id']);
                    },
                  ),
                );
              },
            ),
    );
  }
}
