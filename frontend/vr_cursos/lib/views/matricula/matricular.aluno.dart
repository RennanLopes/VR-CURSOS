import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/api.config.dart';
import '../Home/home.page.dart';

class MatricularAluno extends StatefulWidget {

  @override
  State<MatricularAluno> createState() => _MatricularAlunoState();
}

class _MatricularAlunoState extends State<MatricularAluno> {
  TextEditingController findNomeAlunoController = TextEditingController();
  TextEditingController findNomeCursoController = TextEditingController();
  Map<String, dynamic>? alunoSelecionado;
  Map<String, dynamic>? cursoSelecionado;


  Future<List<Map<String, dynamic>>> selectAlunoByNome(String nomeAluno) async {
    final response = await http.get(Uri.parse(ApiConfig.selectAlunoByNameUrl(nomeAluno)));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('data')) {
        final List<dynamic> alunoDados = data['data'];
        return alunoDados.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> selectCursoByNome(String nomeCurso) async {
    final response = await http.get(Uri.parse(ApiConfig.selectCursoByNameUrl(nomeCurso)));
    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(responseBody);
      if (data.containsKey('data')) {
        final List<dynamic> cursoDados = data['data'];
        return cursoDados.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  Future<void> MatricularAluno() async {
    final int codigoAluno = alunoSelecionado!['codigo'] as int;
    final int codigoCurso = cursoSelecionado!['codigo'] as int;

    final response = await http.post(
      Uri.parse(ApiConfig.matricularAlunoUrl),
      body: {
        "codigo_aluno": codigoAluno.toString(),
        "codigo_curso": codigoCurso.toString()
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String message = responseData["message"];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else if (response.statusCode == 422){
      final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      final String message = responseData["message"];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Erro ao matricular aluno. Tente novamente."),
      ));
    }
  }

  bool isCursoSearchEnabled = false;
  bool isAlunoSearchEnabled = false;

  @override
  void initState() {
    super.initState();
    findNomeCursoController.addListener(() {
      setState(() {
        isCursoSearchEnabled = findNomeCursoController.text.length >= 3;
      });
    });

    findNomeAlunoController.addListener(() {
      setState(() {
        isAlunoSearchEnabled = findNomeAlunoController.text.length >= 3;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: const Text(
          'Matricular Aluno',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLength: 50,
                    controller: findNomeCursoController,
                    decoration: InputDecoration(
                      labelText: 'Curso',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: isCursoSearchEnabled
                      ? () async {
                    final cursos = await selectCursoByNome(findNomeCursoController.text);
                    setState(() {
                      cursoSelecionado = null;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Selecione um curso'),
                            content: Container(
                              width: double.maxFinite,
                              height: 200,
                              child: ListView.builder(
                                itemCount: cursos.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(cursos[index]['descricao']),
                                    subtitle: Text('Código: ${cursos[index]['codigo']}'),
                                    onTap: () {
                                      setState(() {
                                        cursoSelecionado = cursos[index];
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
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
            SizedBox(height: 20),

            Row(
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
                    final alunos = await selectAlunoByNome(findNomeAlunoController.text);
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
                              child: ListView.builder(
                                itemCount: alunos.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(alunos[index]['nome']),
                                    subtitle: Text('Código: ${alunos[index]['codigo']}'),
                                    onTap: () {
                                      setState(() {
                                        alunoSelecionado = alunos[index];
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
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
            SizedBox(height: 20),
            cursoSelecionado != null
                ?
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Curso Selecionado: ',
                    style: TextStyle(),
                  ),
                  TextSpan(
                    text: '${cursoSelecionado!['descricao']} ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Código: ',
                    style: TextStyle(),
                  ),
                  TextSpan(
                    text: '${cursoSelecionado!['codigo']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            )

                : SizedBox(),

            SizedBox(height: 20),
            alunoSelecionado != null
                ? Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Aluno Selecionado: ',
                    style: TextStyle(),
                  ),
                  TextSpan(
                    text: '${alunoSelecionado!['nome']} ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Código: ',
                    style: TextStyle(),
                  ),
                  TextSpan(
                    text: '${alunoSelecionado!['codigo']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            )

                : SizedBox(),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  if (alunoSelecionado != null && cursoSelecionado != null) {
                    MatricularAluno();
                    // Faça aqui a lógica para matricular o aluno no curso selecionado
                    // Por exemplo: print("Aluno ${alunoSelecionado['nome']} matriculado no curso ${cursoSelecionado['descricao']}");
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Erro'),
                          content: Text('Por favor, selecione um aluno e um curso antes de matricular.'),
                          actions: [
                            TextButton(
                              onPressed: () {

                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Matricular'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
