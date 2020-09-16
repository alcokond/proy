import 'dart:collection';

import 'package:CWCFlutter/model/Denuncia.dart';
import 'package:flutter/cupertino.dart';

class DenunciaNotifier with ChangeNotifier {
  List<Denuncia> _denunciaList = [];
  Denuncia _currentDenuncia;

  UnmodifiableListView<Denuncia> get denunciaList => UnmodifiableListView(_denunciaList);

  Denuncia get currentDenuncia => _currentDenuncia;

  set denunciaList(List<Denuncia> denunciaList) {
    _denunciaList = denunciaList;
    notifyListeners();
  }

  set currentDenuncia(Denuncia Denuncia) {
    _currentDenuncia = Denuncia;
    notifyListeners();
  }

  addDenuncia(Denuncia Denuncia) {
    _denunciaList.insert(0, Denuncia);
    notifyListeners();
  }

  deleteDenuncia(Denuncia Denuncia) {
    _denunciaList.removeWhere((_Denuncia) => _Denuncia.id == Denuncia.id);
    notifyListeners();
  }
}
