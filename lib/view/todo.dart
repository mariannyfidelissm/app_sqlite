// ignore_for_file: library_private_types_in_public_api
import 'dart:io';
import 'dart:async';
import '../style_app.dart';
import 'dart:convert';
import '../model/tarefa.dart';
import '../data/db_repository.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';

class TODOPage extends StatefulWidget {
  const TODOPage({super.key});

  @override
  _TODOPageState createState() => _TODOPageState();
}

class _TODOPageState extends State<TODOPage> {
  final TextEditingController _controllerTarefa = TextEditingController();
  List _toDoList = [];
  final List<Tarefa> _tarefasList = <Tarefa>[];
  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedPos;

  //Chamado sempre que inicia a tela consultando os dados necessários
  @override
  void initState() {
    super.initState();

    setState(() {
      _readData().then((data) {
        _toDoList = json.decode(data ?? '');
      });
    });
    debugPrint("Consultando o banco de dados ... ");
    DBProvider.db.database.then((db) {
      DBProvider.db.getAllTasks().then((value) {
        _tarefasList.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [
              SizedBox(
                height: 60,
                child: Lottie.asset(
                  //'https://assets8.lottiefiles.com/packages/lf20_HX0isy.json',
                  "assets/animation.json",
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),
              ),
              const Text('TODO List'),
            ],
          ),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controllerTarefa,
                      decoration: const InputDecoration(
                          labelText: "Adicionar tarefa",
                          hintText: "Descrição",
                          labelStyle: TextStyle(
                              color: Colors.deepPurple, fontSize: 16.0)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: deepPurple,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      onPressed: _addToDoUsingPath,
                      child: const Text(
                        "Adicionar",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh, child: buildFuture(), //buildListView(), //
              ),
            )
          ],
        ),
      ),
    );
  }

  FutureBuilder buildFuture() {
    return FutureBuilder<List<Tarefa>>(
      future: DBProvider.db.getAllTasks(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          //debugPrint("Snapshot future builder --> ${snapshot.data}");
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10.0, left: 16.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return buildItemFuture(context, index, snapshot);
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  Widget buildItemFuture(context, index, snapshot) {
    var pk = snapshot.data!.elementAt(index).id;
    int done = snapshot.data!.elementAt(index).ok;
    var titl = snapshot.data!.elementAt(index).title;

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: const Align(
            alignment:
                Alignment(-0.9, 0.0) /* varia de -1 a 1 nos eixos x e y*/,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        secondaryBackground: Container(
          color: Colors.green,
          child: const Icon(
            Icons.undo,
            color: Colors.white,
          ),
        ),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(_toDoList[index]);
            _lastRemovedPos = index;
            if (direction == DismissDirection.startToEnd) {
              DBProvider.db.deleteTask(pk);
              _toDoList.removeAt(index);
            }

            _saveData();

            final snack = SnackBar(
              content: Text("Tarefa ${_lastRemoved["title"]} removida !"),
              // action: SnackBarAction(
              //   label: "Desfazer",
              //   onPressed: () {
              //     setState(() {
              //       _toDoList.insert(_lastRemovedPos, _lastRemoved);
              //       _saveData();
              //       //TODO: Inserir novamente no banco de dados
              //     });
              //   },
              // ),
              duration: const Duration(seconds: 3),
            );
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(snack);
          });
        },
        //direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          title: Text(titl),
          value: done == 1 ? true : false,
          secondary:
              CircleAvatar(child: Icon(done == 1 ? Icons.check : Icons.error)),
          onChanged: (isMarcado) {
            setState(() {
              done = (isMarcado == true) ? 1 : 0;
              var id = pk;
              var title = titl;
              var ok = done; // == true ? 1 : 0;
              DBProvider.db.updateTarefa(id, title, ok);
            });
          },
        ));
  }

  ListView buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10.0, left: 16.0),
      itemCount: _toDoList.length,
      itemBuilder: buildItem,
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      // como chave o tempo em milisegundos
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0) /* varia de -1 a 1 nos eixos x e y*/,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.green,
        child: const Icon(
          Icons.undo,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.startToEnd,

      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (isMarcado) {
          setState(() {
            _toDoList[index]["ok"] = isMarcado;
            _saveData();
            var id = _toDoList[index]["id"];
            var title = _toDoList[index]["title"];
            var ok = _toDoList[index]["ok"] == true ? 1 : 0;
            debugPrint("$id - $title - $ok");
            //TODO: Atualizar no banco de dados de tarefas
            DBProvider.db.updateTarefa(id, title, ok);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          DBProvider.db.deleteTask(_toDoList[index]["id"]);
          _toDoList.removeAt(index);

          _saveData();

          //TODO: Remover do banco de dados a tarefa

          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida !"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                  //TODO: Inserir novamente no banco de dados
                });
              },
            ),
            duration: const Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  //Adicionando uma nova tarefa utilizando o path_provider
  void _addToDoUsingPath() {
    setState(() {
      Map<String, dynamic> newToDo = {};
      String tarefa = _controllerTarefa.text;
      newToDo["title"] = tarefa;
      newToDo["ok"] = false;
      _controllerTarefa.text = "";
      _toDoList.add(newToDo);
      _addToDoSqlite(newToDo).then((value) {
        value != null ? newToDo["id"] = value : -1;
      });

      _saveData();
    });
  }

  Future<int?> _addToDoSqlite(Map<String, dynamic> newToDo) async {
    var dataBase = await DBProvider.db.database;
    int? id = await dataBase?.insert('tarefas', newToDo);

    return id;
  }

  //Ordenando as tarefas
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1)); // espera 1 segundo
    setState(() {
      _tarefasList.sort((a, b) {
        bool element1 = (a.ok == 1) ? true : false;
        bool element2 = (b.ok == 1) ? true : false;
        if (element1 && !element2) {
          return 1;
        } else if (!element1 && element2) {
          return -1;
        } else {
          return 0;
        }
      });
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        } else {
          return 0;
        }
      });
      _saveData();
    });
  }

  //Pegando o diretório padrão do telefone
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'data.json');
    return File(path);
  }

  //Salvando os dados no arquivo JSON
  Future<File> _saveData() async {
    final file = await _getFile();
    String data = json.encode(_toDoList);
    return file.writeAsString(data);
  }

  //Lendo dados do arquivo JSON
  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      Future<String> data = file.readAsString();
      return data;
    } catch (e) {
      return null;
    }
  }
}
