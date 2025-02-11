import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:egaz/database/database_egaz.dart';

class AuthService {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email); 
      return null; 
    } catch (e) {
      return e.toString(); 
    }
  }


   Future<void> logoutUser() async {
  try {
    await _auth.signOut(); 
  } catch (e) {
    print("$e");
  }
}


  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try { 
     
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role, 
      });

      return null; 
    } catch (e) {
      return e.toString(); 
    }
  }

  
 Future<String?> login({
  required String email,
  required String password,
}) async {
  try {
   
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

   
    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

   
    if (userDoc.exists) {
     
      return userDoc['role']; 
    } else {
    
      return 'Utilisateur non trouvé';
    }
  } catch (e) {
    return e.toString(); 
  }
}

  signOut() async {
    _auth.signOut();
  }

  Future<String?> getCurrentUserId() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid;  
}

   

  
  Future<bool> reauthenticateUser(String email, String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
        await user.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      print("$e");
      return false;
    }
  }

  Future<bool> deleteUserAccount(String email, String password) async {
  try {
    User? user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    
    bool reauthenticated = await reauthenticateUser(email, password);
    if (!reauthenticated) {
      return false;
    }

   
    await DatabaseHelper().deleteVendeurProfile(user.uid);

    
    await user.delete();
  
    return true;
  } catch (e) {
    print(" Erreur lors de la suppression du compte : $e");
    return false;
  }
}


}

