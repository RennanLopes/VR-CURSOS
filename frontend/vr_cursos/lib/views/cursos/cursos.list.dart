import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vr_cursos/views/cursos/cursos.update.dart';

import '../../api/api.config.dart';
import 'cursos.add.dart';
import '../Home/home.page.dart';
import 'cursos.delete.dart';

class ListaCursos extends StatefulWidget {
  @override
  State<ListaCursos> createState() => _ListaCursosState();
}

class _ListaCursosState extends State<ListaCursos> {
  TextEditingController findNomeCursoController = TextEditingController();
  List<int> CursosCodigos = [];
  List<String> CursosNomes = [];
  List<String> CursosEmentas = [];

  @override
  void initState() {
    super.initState();
    selectCursos();

    findNomeCursoController.addListener(() {
      setState(() {
        isCursoSearchEnabled = findNomeCursoController.text.length >= 3;
      });
    });
  }

  Future<void> selectCursos() async {
    final response = await http.get(Uri.parse(ApiConfig.selectCursosUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('data')) {
        final List<dynamic> cursosDados = data['data'];

        final List<int> codigos = List<int>.from(cursosDados.map((curso) {
          return curso['codigo'];
        }));

        final List<String> descricao =
            List<String>.from(cursosDados.map((curso) {
          return utf8.decode(curso['descricao'].codeUnits);
        }));

        final List<String> ementas = List<String>.from(cursosDados.map((curso) {
          return utf8.decode(curso['ementa'].codeUnits);
        }));

        setState(() {
          CursosCodigos = codigos;
          CursosNomes = descricao;
          CursosEmentas = ementas;
        });
      }
    } else {
      throw Exception('Falha ao carregar dados da API');
    }
  }

  Future<List<Widget>> selectCursoByNome(String nomeCurso) async {
    final response =
        await http.get(Uri.parse(ApiConfig.selectCursoByNameUrl(nomeCurso)));
    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(responseBody);
      if (data.containsKey('data')) {
        final List<dynamic> cursoDados = data['data'];
        return cursoDados.map((curso) {
          int codigo = curso['codigo'];
          String descricao = curso['descricao'];
          String ementa = curso['ementa'];
          return ListTile(
            title: Text(
              descricao,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(ementa),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CursoUpdate(codigo, descricao, ementa)));
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CursoDelete(codigo, descricao, ementa)));
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          );
        }).toList();
      }
    }
    return [];
  }

  bool isCursoSearchEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        title: const Text(
          'Lista de Cursos',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CursoAdd()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
                    child: TextField(
                      controller: findNomeCursoController,
                      decoration: const InputDecoration(
                        hintText: 'Pesquisar',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: isCursoSearchEnabled
                      ? () async {
                          final cursos = await selectCursoByNome(
                              findNomeCursoController.text);
                          setState(() {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Selecione um curso'),
                                  content: Container(
                                    width: double.maxFinite,
                                    height: 200,
                                    child: ListView(
                                      children: cursos,
                                    ),
                                  ),
                                );
                              },
                            );
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ListView.builder(
                itemCount: CursosNomes.length,
                itemBuilder: (context, index) {
                  int codigoCursos = CursosCodigos[index];
                  String descricaoCurso = CursosNomes[index];
                  String ementaCurso = CursosEmentas[index];

                  return ListTile(
                    title: Text(
                      descricaoCurso,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(ementaCurso),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CursoUpdate(
                                        codigoCursos,
                                        descricaoCurso,
                                        ementaCurso)));
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CursoDelete(
                                        codigoCursos,
                                        descricaoCurso,
                                        ementaCurso)));
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
