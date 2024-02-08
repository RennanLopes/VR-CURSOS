import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vr_cursos/api/api.config.dart';

import '../Home/home.page.dart';

class ListaCursosAlunos extends StatefulWidget {
  @override
  _ListaCursosAlunosState createState() => _ListaCursosAlunosState();
}

class _ListaCursosAlunosState extends State<ListaCursosAlunos> {
  Map<String, List<String>> cursosComAlunos = {};

  @override
  void initState() {
    super.initState();
    fetchCursosAlunos();
  }

  Future<void> fetchCursosAlunos() async {
    final response =
        await http.get(Uri.parse(ApiConfig.selectAlunosPorCursoUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes));
      if (data.containsKey('data')) {
        final Map<String, dynamic> cursosData = data['data'];

        cursosData.forEach((curso, alunos) {
          cursosComAlunos[curso] = List<String>.from(alunos);
        });

        setState(() {});
      }
    } else {
      throw Exception('Falha ao carregar dados da API');
    }
  }

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
          'Alunos Por Curso',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: cursosComAlunos.length,
        itemBuilder: (context, index) {
          String curso = cursosComAlunos.keys.elementAt(index);
          List<String> alunos = cursosComAlunos[curso] ?? [];

          return ListTile(
            title: Text(
              curso,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: alunos
                  .map((aluno) => Text(
                        aluno,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
