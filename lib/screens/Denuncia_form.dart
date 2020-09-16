import 'dart:io';

import 'package:CWCFlutter/api/Denuncia_api.dart';
import 'package:CWCFlutter/model/Denuncia.dart';
import 'package:CWCFlutter/notifier/Denuncia_notifier.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DenunciaForm extends StatefulWidget {
  final bool isUpdating;

  DenunciaForm({@required this.isUpdating});

  @override
  _DenunciaFormState createState() => _DenunciaFormState();
}

class _DenunciaFormState extends State<DenunciaForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List _guias = [];
  Denuncia _currentDenuncia;
  String _imageUrl;
  File _imageFile;
  TextEditingController guiaController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    DenunciaNotifier denunciaNotifier = Provider.of<DenunciaNotifier>(context, listen: false);

    if (denunciaNotifier.currentDenuncia != null) {
      _currentDenuncia = denunciaNotifier.currentDenuncia;
    } else {
      _currentDenuncia = Denuncia();
    }

    _guias.addAll(_currentDenuncia.guias);
    _imageUrl = _currentDenuncia.image;
  }

  _showImage() {
    if (_imageFile == null && _imageUrl == null) {
      return Text("placeholder de imagen");
    } else if (_imageFile != null) {
      print('mostrando imagen de archivo local');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.file(
            _imageFile,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Cambiar imagen',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
            ),
            onPressed: () => _getLocalImage(),
          )
        ],
      );
    } else if (_imageUrl != null) {
      print('mostrando imagen de la url');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.network(
            _imageUrl,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 250,
          ),
          FlatButton(
            padding: EdgeInsets.all(16),
            color: Colors.black54,
            child: Text(
              'Cambiar imagen',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
            ),
            onPressed: () => _getLocalImage(),
          )
        ],
      );
    }
  }

  _getLocalImage() async {
    File imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 400);

    if (imageFile != null) {
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Nombre/descripcion'),
      initialValue: _currentDenuncia.name,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'se requiere una descripcion';
        }

        if (value.length < 3 || value.length > 40) {
          return 'Nombre debe tener mas de 3 y menos de 40 letras';
        }

        return null;
      },
      onSaved: (String value) {
        _currentDenuncia.name = value;
      },
    );
  }

  Widget _buildCategoryField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Categoria'),
      initialValue: _currentDenuncia.category,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Se requiere una categoria';
        }

        if (value.length < 3 || value.length > 20) {
          return 'La categoria debe tener mas de 3 y menos de 20';
        }

        return null;
      },
      onSaved: (String value) {
        _currentDenuncia.category = value;
      },
    );
  }

  _buildguiaField() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: guiaController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(labelText: 'Guia'),
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  _onDenunciaUploaded(Denuncia Denuncia) {
    DenunciaNotifier denunciaNotifier = Provider.of<DenunciaNotifier>(context, listen: false);
    denunciaNotifier.addDenuncia(Denuncia);
    Navigator.pop(context);
  }

  _addguia(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _guias.add(text);
      });
      guiaController.clear();
    }
  }

  _saveDenuncia() {
    print('saveDenuncia Called');
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    print('formulario guardado');

    _currentDenuncia.guias = _guias;

    uploadDenunciaAndImage(_currentDenuncia, widget.isUpdating, _imageFile, _onDenunciaUploaded);

    print("nombre: ${_currentDenuncia.name}");
    print("categoria: ${_currentDenuncia.category}");
    print("guias: ${_currentDenuncia.guias.toString()}");
    print("_imageFile ${_imageFile.toString()}");
    print("_imageUrl $_imageUrl");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Formulario de Denuncia')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(children: <Widget>[
            _showImage(),
            SizedBox(height: 16),
            Text(
              widget.isUpdating ? "Editar Denuncia" : "Crear Denuncia",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 16),
            _imageFile == null && _imageUrl == null
                ? ButtonTheme(
                    child: RaisedButton(
                      onPressed: () => _getLocalImage(),
                      child: Text(
                        'Añadir imagen',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : SizedBox(height: 0),
            _buildNameField(),
            _buildCategoryField(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildguiaField(),
                ButtonTheme(
                  child: RaisedButton(
                    child: Text('Añadir', style: TextStyle(color: Colors.white)),
                    onPressed: () => _addguia(guiaController.text),
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(8),
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: _guias
                  .map(
                    (ingredient) => Card(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          ingredient,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          _saveDenuncia();
        },
        child: Icon(Icons.save),
        foregroundColor: Colors.white,
      ),
    );
  }
}
