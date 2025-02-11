import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egaz/pages_authentification/auth_service.dart';
import 'package:egaz/providers/cart_provider.dart';

class DatabaseHelper {
  static Database? _database;  

 
  Future<Database> getDatabase() async {
    if (_database != null) {
      print('Base de données déjà initialisée');
      return _database!;
    }

    print('Initialisation de la base de données...');
    _database = await _initDatabase();
    return _database!;
  }

  
  Future<Database> _initDatabase() async {
   

    // Obtenir le répertoire des documents de l'application
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'egaz.db');
    

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        

        await db.execute(''' 
          CREATE TABLE CLIENT (
               id TEXT PRIMARY KEY,
               nom TEXT NOT NULL,
               photo BLOB
             );
        ''');
        

        await db.execute(''' 
          CREATE TABLE VENDEUR (
           id TEXT PRIMARY KEY,
           nom_boutique TEXT,
           localisation_boutique TEXT,
           photo BLOB,
           heure_ouverture TIME NOT NULL DEFAULT '09:00',
           heure_fermeture TEXT TIME NOT NULL DEFAULT '20:00'
          );
        ''');
        

        await db.execute(''' 
          CREATE TABLE PRODUITS (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            designation TEXT NOT NULL,
            prix REAL NOT NULL,
            photo BLOB NOT NULL,
            marque TEXT NOT NULL,
            categorie TEXT NOT NULL,
            id_vendeur TEXT,
            FOREIGN KEY (id_vendeur) REFERENCES VENDEUR(id) ON DELETE CASCADE
           );''');
        

        await db.execute(''' 
                   CREATE TABLE COMMANDE (
                       id INTEGER PRIMARY KEY AUTOINCREMENT, 
                       nom_client TEXT NOT NULL,
                       date_commande DATETIME DEFAULT CURRENT_TIMESTAMP,
                       total DECIMAL(10,2) NOT NULL, 
                       adresse_livraison TEXT,
                       id_vendeur TEXT NOT NULL,
                       id_client,
                       FOREIGN KEY (id_vendeur) REFERENCES VENDEUR(id)
                   );                   
                   ''');
  

        await db.execute('''
            CREATE TABLE AVIS (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_client TEXT NOT NULL,
              nom_client TEXT NOT NULL,
              note_client REAL NOT NULL
            );
          ''');


        await db.execute(''' 
          CREATE TABLE NOTIFICATIONS (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titre TEXT NOT NULL,
            message TEXT NOT NULL,
            date_commande DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            etat TEXT NOT NULL DEFAULT 'non lue',
            destinataire_id TEXT,
            id_commande INTEGER,
            FOREIGN KEY (destinataire_id) REFERENCES CLIENT(id) ON DELETE CASCADE,
            FOREIGN KEY (id_commande) REFERENCES COMMANDE(id) ON DELETE SET NULL
                    );
                      ''');
        

        await db.execute(''' 
          CREATE TABLE LIVREUR (
            id TEXT PRIMARY KEY,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            telephone TEXT NOT NULL,
            engin TEXT NOT NULL,
            id_vendeur TEXT,
            FOREIGN KEY (id_vendeur) REFERENCES VENDEUR(id) ON DELETE CASCADE
          );
        ''');
        await db.execute(''' 
              CREATE TABLE COMMANDE_PRODUIT (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_commande INTEGER NOT NULL,
              id_produit INTEGER NOT NULL,
              quantite INTEGER NOT NULL,
              prix DECIMAL(10,2) NOT NULL,
              FOREIGN KEY (id_commande) REFERENCES COMMANDE(id) ON DELETE CASCADE,
              FOREIGN KEY (id_produit) REFERENCES PRODUITS(id) ON DELETE CASCADE
                );
                 ''');

        
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Mise à jour de la base de données de la version $oldVersion à la version $newVersion');
      },
    );
  }




 Future<void> addLivreur({
    required String id,
    required String nom,
    required String prenom,
    required String telephone,
    required String engin,
    required String idVendeur,
  }) async {
    final Database db = await getDatabase();
    
    await db.insert(
      'LIVREUR',
      {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'engin': engin,
        'id_vendeur': idVendeur,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  
  Future<List<Map<String, dynamic>>> getLivreursByVendeur(String idVendeur) async {
  final Database db = await getDatabase();
  return await db.query(
    'LIVREUR',
    where: 'id_vendeur = ?',
    whereArgs: [idVendeur],
  );
}

Future<List<Map<String, dynamic>>> getAvisByUser(String userId) async {
  final Database db = await getDatabase();
  return await db.query(
    'AVIS',
    where: 'id_client = ?',
    whereArgs: [userId],
    orderBy: 'id DESC',
  );
}

Future<void> deleteLivreur(String id) async {
  final Database db = await getDatabase();
  await db.delete('LIVREUR', where: 'id = ?', whereArgs: [id]);
}


 
  Future<void> insererProduit({
    required String designation,
    required int prix,
    required Uint8List photo,  
    required String marque,
    required String categorie,
    required String idVendeur,
  }) async {
    final db = await getDatabase();  

    Map<String, dynamic> produit = {
      'designation': designation,
      'prix': prix,
      'photo': photo,  
      'marque': marque,
      'categorie': categorie,
      'id_vendeur': idVendeur,
    };

    await db.insert('PRODUITS', produit);
  }

  Future<List<Map<String, dynamic>>> getLivreursByVendeurUpdated(String vendeurId) async {
  final Database db = await getDatabase();
  return await db.query(
    'LIVREUR',
    where: 'id_vendeur = ?',
    whereArgs: [vendeurId],
  );
}

 Future<List<int>> _imageToBlob(File imageFile) async {
    return await imageFile.readAsBytes();
  } 


Future<void> updateVendeurProfile(
  String idVendeur,
  String nomBoutique,
  File? image,
  String heureOuverture, 
  String heureFermeture, 
) async {
  final Database db = await DatabaseHelper().getDatabase();

  Map<String, dynamic> updateData = {
    'nom_boutique': nomBoutique,
    'heure_ouverture': heureOuverture, 
    'heure_fermeture': heureFermeture, 
  };

  if (image != null) {
    updateData['photo'] = await _imageToBlob(image);
  }

  int result = await db.update(
    'VENDEUR',
    updateData,
    where: 'id = ?',
    whereArgs: [idVendeur],
  );

  if (result == 0) {
    updateData['id'] = idVendeur;
    await db.insert('VENDEUR', updateData);
  }
}

Future<void> debugVendeurs() async {
  final Database db = await getDatabase();
  final vendeurs = await db.query('VENDEUR');

  for (var vendeur in vendeurs) {
    print("Vendeur : ${vendeur['nom_boutique']}, Localisation: ${vendeur['localisation_boutique']}");
  }
}


Future<Map<String, dynamic>?> getVendeurProfil(String idVendeur) async {
  final Database db = await getDatabase();
  final List<Map<String, dynamic>> result = await db.query(
    'VENDEUR',
    where: 'id = ?',
    whereArgs: [idVendeur],
  );

  if (result.isNotEmpty) {
    return result.first; 
  }
  return null; 
}

Future<void> deleteVendeurProfile(String idVendeur) async {
  final Database db = await getDatabase();

  int result = await db.delete(
    'VENDEUR',
    where: 'id = ?',
    whereArgs: [idVendeur],
  );

  if (result > 0) {
    print("Profil supprimé avec succès !");
  } else {
    print("Erreur : impossible de supprimer le profil.");
  }
}

Future<List<Map<String, dynamic>>> getAllVendeurs() async {
  final Database db = await getDatabase();
  final result = await db.query('VENDEUR'); 

  return result;
}

Future<void> updateVendeurLocation(String id, String location) async {
    final Database db = await getDatabase();
    await db.update(
      'VENDEUR',
      {'localisation_boutique': location}, 
      where: 'id = ?', 
      whereArgs: [id],
    );
  }

Future<List<Map<String, dynamic>>> getProduitsByVendeur(String idVendeur) async {
  final Database db = await getDatabase();
  return await db.query(
    'PRODUITS',
    where: 'id_vendeur = ?',
    whereArgs: [idVendeur],
  );
}


Future<int> createCommande({
  required String idClient,
  required double total,
  required String adresse,
  required String idVendeur,
}) async {
  final db = await getDatabase();
  
  final commandeId = await db.insert('COMMANDE', {
    'id_client': idClient,
    'total': total,
    'adresse_livraison': adresse,
    'id_vendeur': idVendeur,
    'date_commande': DateTime.now().toIso8601String(),
  });

  return commandeId;
}

Future<void> addCommandeProduit({
  required int commandeId,
  required int produitId,
  required int quantite,
  required double prix,
}) async {
  final db = await getDatabase();
  
  await db.insert('COMMANDE_PRODUIT', {
    'id_commande': commandeId,
    'id_produit': produitId,
    'quantite': quantite,
    'prix': prix,
  });
}

Future<List<Map<String, dynamic>>> getCommandesByVendeur(String vendeurId) async {
  final db = await getDatabase();
  return await db.query(
    'COMMANDE',
    where: 'id_vendeur = ?',
    whereArgs: [vendeurId],
    orderBy: 'date_commande DESC',
  );
}

Future<Map<String, dynamic>> getCommandeDetails(int commandeId) async {
  final db = await getDatabase();
  
  final commande = (await db.query(
    'COMMANDE',
    where: 'id = ?',
    whereArgs: [commandeId],
  )).first;

  final client = await db.query(
    'CLIENT',
    where: 'id = ?',
    whereArgs: [commande['id_client']],
  );

  final produits = await db.rawQuery('''
    SELECT p.designation, cp.quantite, cp.prix 
    FROM COMMANDE_PRODUIT cp
    JOIN PRODUITS p ON cp.id_produit = p.id
    WHERE cp.id_commande = ?
  ''', [commandeId]);

  return {
    'commande': commande,
    'client': client.first,
    'produits': produits,
  };
}

Future<void> createNotification({
  required String titre,
  required String message,
  required String destinataireId,
  required int commandeId,
}) async {
  final db = await getDatabase();
  
  await db.insert('NOTIFICATIONS', {
    'titre': titre,
    'message': message,
    'destinataire_id': destinataireId,
    'id_commande': commandeId,
    'date_commande': DateTime.now().toIso8601String(),
  });
}

Future<String?> getClientName(String userId) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    
    if (userDoc.exists) {
      return userDoc['name'];
    } else {
      return null;
    }
  } catch (e) {
    print("$e");
    return null;
  }
}

Future<String> getVendeurIdByProduit(int produitId) async {
  final db = await getDatabase();
  final produit = await db.query(
    'PRODUITS',
    where: 'id = ?',
    whereArgs: [produitId],
  );
  return produit.first['id_vendeur'] as String;
}


Future<void> enregistrerCommande({
  required List<CartItem> produits,
  required double total,
  required String adresseLivraison,
}) async {
  final db = await getDatabase();
  final authService = AuthService();

  try {
    
    String? userId = await authService.getCurrentUserId();
    if (userId == null) {
      throw Exception("Utilisateur non connecté.");
    }

   
    String? nomClient = await getClientName(userId);
    if (nomClient == null) {
      throw Exception("Impossible de récupérer le nom du client.");
    }

 
    if (produits.isEmpty) {
      throw Exception("Le panier est vide.");
    }

    String idVendeur = await getVendeurIdByProduit(int.parse(produits.first.id));
    int commandeId = await db.insert('COMMANDE', {
      'nom_client': nomClient,
      'total': total,
      'adresse_livraison': adresseLivraison,
      'id_vendeur': idVendeur,
      'date_commande': DateTime.now().toIso8601String(),
      'id_client': userId
    });
    for (var produit in produits) {
      await db.insert('COMMANDE_PRODUIT', {
        'id_commande': commandeId,
        'id_produit': int.parse(produit.id),
        'quantite': produit.quantity,
        'prix': produit.price.toDouble(),
      });
    }

   
    await createNotification(
      titre: "Nouvelle commande",
      message: "Une nouvelle commande a été passée par $nomClient.",
      destinataireId: idVendeur,
      commandeId: commandeId,
    );
  } catch (e) {
    print("ERREUR lors de l'enregistrement de la commande : $e");
  }
}




Future<List<Map<String, dynamic>>> getNotificationsByVendeur(String vendeurId) async {
  final db = await getDatabase();
  return await db.query(
    'NOTIFICATIONS',
    where: 'destinataire_id = ?',
    whereArgs: [vendeurId],
    orderBy: 'date_commande DESC',
  );
}


Future<void> markNotificationAsRead(int id) async {
  final db = await getDatabase();
  await db.update(
    'NOTIFICATIONS',
    {'etat': 'lue'},
    where: 'id = ?',
    whereArgs: [id],
  );
}


Future<void> deleteNotification(int id) async {
  final db = await getDatabase();
  await db.delete(
    'NOTIFICATIONS',
    where: 'id = ?',
    whereArgs: [id],
  );
}

 Future<void> insertAvis({
    required String userId,
    required String userName,
    required double rating,
  }) async {
    final Database db = await getDatabase();
    
    await db.insert(
      'AVIS',
      {
        'id_client': userId,
        'nom_client': userName,
        'note_client': rating,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

Future<void> updateClientProfile(String idClient, String nom, File? image) async {
  final Database db = await getDatabase();

  Map<String, dynamic> updateData = {'nom': nom};

  if (image != null) {
    updateData['photo'] = await image.readAsBytes();
  }

  await db.update(
    'CLIENT',
    updateData,
    where: 'id = ?',
    whereArgs: [idClient],
  );
}


Future<List<Map<String, dynamic>>> getCommandesByClient(String clientId) async {
  final db = await getDatabase();
  return await db.query(
    'COMMANDE',
    where: 'id_client = ?',
    whereArgs: [clientId],
    orderBy: 'date_commande DESC',
  );
}

}


