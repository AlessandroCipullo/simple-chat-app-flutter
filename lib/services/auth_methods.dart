import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthMethods {
  static AuthMethods? _instance;
  AuthMethods._();

  static AuthMethods getInstance() {
    if (_instance == null) {
      return AuthMethods._();
    }
    return _instance!;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<String> signIn() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('id', isEqualTo: userCredential.user?.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;

        if (documents.isEmpty) {
          _firestore.collection('users').doc(userCredential.user!.uid).set({
            'nickname': userCredential.user!.displayName,
            'description': 'Descrizione provvisoria',
            'photoUrl': userCredential.user!.photoURL,
            'id': userCredential.user!.uid
          });
        }
      }
    } catch (error) {
      return "Error";
    }

    return "Success";
  }

  bool isUserLogged() {
    if (_auth.currentUser != null) {
      return true;
    }
    return false;
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getCurrentUserData() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  Future<bool> updateNickname(String newNick) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'nickname': newNick});
      return true;
    } on FirebaseException catch (e) {
      log(e.stackTrace.toString());
      return false;
    }
  }

  Future<bool> updateDescription(String newDesc) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'description': newDesc});
      return true;
    } on FirebaseException catch (e) {
      log(e.stackTrace.toString());
      return false;
    }
  }

  Future<bool> updateProPic(File pic) async {
    try {
      final storage = FirebaseStorage.instance.ref();
      final picRed = storage.child('${_auth.currentUser!.uid}ProPic.jpg');

      await picRed.putFile(pic);
      picRed.getDownloadURL().then((value) {
        _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({'photoUrl': value});
      });
      return true;
    } on FirebaseException catch (e) {
      log(e.stackTrace.toString());
      return false;
    }
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
  }

  String getUserId() {
    return _auth.currentUser!.uid;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? retrieveChatMessages(
      String chatId) {
    return _firestore
        .collection('messages')
        .doc(chatId)
        .collection(chatId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? retrieveUsersList() {
    return _firestore.collection('users').limit(10).snapshots();
  }

  Future<void> sendMessage(
      String msg, String yourId, String contactId, String chatId) async {
    DocumentReference documentReference = _firestore
        .collection('messages')
        .doc(chatId)
        .collection(chatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    _firestore.runTransaction((transaction) async {
      transaction.set(documentReference, {
        'idFrom': yourId,
        'idTo': contactId,
        'content': msg.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
      });
    });
  }

  String generateChatId(String id1, String id2) {
    if (id1.hashCode <= id2.hashCode) {
      return '$id1-$id2';
    } else {
      return '$id2-$id1';
    }
  }
}
