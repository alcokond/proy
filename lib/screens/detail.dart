import 'package:CWCFlutter/api/Denuncia_api.dart';
import 'package:CWCFlutter/model/Denuncia.dart';
import 'package:CWCFlutter/notifier/Denuncia_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Denuncia_form.dart';

class DenunciaDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DenunciaNotifier denunciaNotifier = Provider.of<DenunciaNotifier>(context);

    _onDenunciaDeleted(Denuncia denuncia) {
      Navigator.pop(context);
      denunciaNotifier.deleteDenuncia(denuncia);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(denunciaNotifier.currentDenuncia.name),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                Image.network(
                  denunciaNotifier.currentDenuncia.image != null
                      ? denunciaNotifier.currentDenuncia.image
                      : 'https://www.testingxperts.com/wp-content/uploads/2019/02/placeholder-img.jpg',
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: 24),
                Text(
                  denunciaNotifier.currentDenuncia.name,
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
                Text(
                  'Categoria/tipo: ${denunciaNotifier.currentDenuncia.category}',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 20),
                Text(
                  "Guias/direcciones",
                  style: TextStyle(fontSize: 18, decoration: TextDecoration.underline),
                ),
                SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.all(8),
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  children: denunciaNotifier.currentDenuncia.guias
                      .map(
                        (ingredient) => Card(
                          color: Colors.black54,
                          child: Center(
                            child: Text(
                              ingredient,
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'button1',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return DenunciaForm(
                    isUpdating: true,
                  );
                }),
              );
            },
            child: Icon(Icons.edit),
            foregroundColor: Colors.white,
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            heroTag: 'button2',
            onPressed: () => deleteDenuncia(denunciaNotifier.currentDenuncia, _onDenunciaDeleted),
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
