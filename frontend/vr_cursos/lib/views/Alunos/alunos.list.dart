import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vr_cursos/views/Alunos/alunos.add.dart';
import 'package:vr_cursos/views/Alunos/alunos.delete.dart';
import 'package:vr_cursos/views/Home/home.page.dart';

import '../../api/api.config.dart';
import 'alunos.update.dart';

class ListaAlunos extends StatefulWidget {
  @override
  _ListaAlunosState createState() => _ListaAlunosState();
}

class _ListaAlunosState extends State<ListaAlunos> {
  TextEditingController findNomeAlunoController = TextEditingController();
  Map<String, dynamic>? alunoSelecionado;
  List<String> AlunosNomes = [];
  List<int> AlunosCodigos = [];

  @override
  void initState() {
    super.initState();
    selectAlunos();

    findNomeAlunoController.addListener(() {
      setState(() {
        isAlunoSearchEnabled = findNomeAlunoController.text.length >= 3;
      });
    });
  }

  Future<void> selectAlunos() async {
    final response = await http.get(Uri.parse(ApiConfig.selectAlunosUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('data')) {
        final List<dynamic> alunosDados = data['data'];

        final List<String> nomes = List<String>.from(alunosDados.map((aluno) {
          return utf8.decode(aluno['nome'].codeUnits);
        }));

        final List<int> codigos = List<int>.from(alunosDados.map((aluno) {
          return aluno['codigo'];
        }));

        setState(() {
          AlunosCodigos = codigos;
          AlunosNomes = nomes;
        });
      }
    } else {
      throw Exception('Falha ao carregar dados da API');
    }
  }

  Future<List<Widget>> selectAlunoByNome(String nomeAluno) async {
    final response =
        await http.get(Uri.parse(ApiConfig.selectAlunoByNameUrl(nomeAluno)));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('data')) {
        final List<dynamic> alunoDados = data['data'];
        return alunoDados.map((aluno) {
          int codigo = aluno['codigo'];
          String nome = utf8.decode(aluno['nome'].codeUnits);
          return ListTile(
            title: Text(nome),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlunoUpdate(codigo, nome)));
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlunoDelete(codigo, nome)));
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

  bool isAlunoSearchEnabled = false;

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
          'Lista de Alunos',
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
                  context, MaterialPageRoute(builder: (context) => AlunoAdd()));
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
                  child: TextField(
                    maxLength: 50,
                    controller: findNomeAlunoController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Aluno',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: isAlunoSearchEnabled
                      ? () async {
                          final alunos = await selectAlunoByNome(
                              findNomeAlunoController.text);
                          setState(() {
                            alunoSelecionado = null;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Selecione um aluno'),
                                  content: Container(
                                    width: double.maxFinite,
                                    height: 200,
                                    child: ListView(
                                      children: alunos,
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
                itemCount: AlunosNomes.length,
                itemBuilder: (context, index) {
                  int codigoAluno = AlunosCodigos[index];
                  String nomeAluno = AlunosNomes[index];

                  return ListTile(
                    title: Text(nomeAluno),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AlunoUpdate(codigoAluno, nomeAluno)));
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AlunoDelete(codigoAluno, nomeAluno)));
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
