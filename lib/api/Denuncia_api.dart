import 'dart:io';

import 'package:CWCFlutter/model/Denuncia.dart';
import 'package:CWCFlutter/model/user.dart';
import 'package:CWCFlutter/notifier/auth_notifier.dart';
import 'package:CWCFlutter/notifier/Denuncia_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

login(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error.code));

  if (authResult != null) {
    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      print("Log In: $firebaseUser");
      authNotifier.setUser(firebaseUser);
    }
  }
}

signup(User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error.code));

  if (authResult != null) {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = user.displayName;

    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      await firebaseUser.updateProfile(updateInfo);

      await firebaseUser.reload();

      print("Sign up: $firebaseUser");

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      authNotifier.setUser(currentUser);
    }
  }
}

signout(AuthNotifier authNotifier) async {
  await FirebaseAuth.instance.signOut().catchError((error) => print(error.code));

  authNotifier.setUser(null);
}

initializeCurrentUser(AuthNotifier authNotifier) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

  if (firebaseUser != null) {
    print(firebaseUser);
    authNotifier.setUser(firebaseUser);
  }
}

getDenuncias(DenunciaNotifier denunciaNotifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('Denuncias')
      .orderBy("createdAt", descending: true)
      .getDocuments();

  List<Denuncia> _DenunciaList = [];

  snapshot.documents.forEach((document) {
    Denuncia denuncia = Denuncia.fromMap(document.data);
    _DenunciaList.add(denuncia);
  });

  denunciaNotifier.denunciaList = _DenunciaList;
}

uploadDenunciaAndImage(Denuncia Denuncia, bool isUpdating, File localFile, Function DenunciaUploaded) async {
  if (localFile != null) {
    print("uploading image");

    var fileExtension = path.extension(localFile.path);
    print(fileExtension);

    var uuid = Uuid().v4();

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('Denuncias/images/$uuid$fileExtension');

    await firebaseStorageRef.putFile(localFile).onComplete.catchError((onError) {
      print(onError);
      return false;
    });

    String url = await firebaseStorageRef.getDownloadURL();
    print("download url: $url");
    _uploadDenuncia(Denuncia, isUpdating, DenunciaUploaded, imageUrl: url);
  } else {
    print('...skipping image upload');
    _uploadDenuncia(Denuncia, isUpdating, DenunciaUploaded);
  }
}

_uploadDenuncia(Denuncia denuncia, bool isUpdating, Function DenunciaUploaded, {String imageUrl}) async {
  CollectionReference DenunciaRef = Firestore.instance.collection('Denuncias');

  if (imageUrl != null) {
    denuncia.image = imageUrl;
  }

  if (isUpdating) {
    denuncia.updatedAt = Timestamp.now();

    await DenunciaRef.document(denuncia.id).updateData(denuncia.toMap());

    DenunciaUploaded(Denuncia);
    print('updated Denuncia with id: ${denuncia.id}');
  } else {
    denuncia.createdAt = Timestamp.now();

    DocumentReference documentRef = await DenunciaRef.add(denuncia.toMap());

    denuncia.id = documentRef.documentID;

    print('uploaded Denuncia successfully: ${denuncia.toString()}');

    await documentRef.setData(denuncia.toMap(), merge: true);

    DenunciaUploaded(Denuncia);
  }
}

deleteDenuncia(Denuncia Denuncia, Function DenunciaDeleted) async {
  if (Denuncia.image != null) {
    StorageReference storageReference =
        await FirebaseStorage.instance.getReferenceFromUrl(Denuncia.image);

    print(storageReference.path);

    await storageReference.delete();

    print('image deleted');
  }

  await Firestore.instance.collection('Denuncias').document(Denuncia.id).delete();
  DenunciaDeleted(Denuncia);
}
