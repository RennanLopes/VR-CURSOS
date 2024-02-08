import 'package:flutter/material.dart';
import 'package:vr_cursos/views/Alunos/alunos.add.dart';
import 'package:vr_cursos/views/Alunos/alunos.list.dart';
import 'package:vr_cursos/views/cursos/cursos.add.dart';
import 'package:vr_cursos/views/cursos/cursos.list.dart';
import 'package:vr_cursos/views/matricula/alunos.po.curso.dart';

import '../matricula/matricular.aluno.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AlunoAdd()));
              },
              child: Text('Cadastrar Aluno'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListaAlunos()));
              },
              child: Text('Listar Alunos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CursoAdd()));
              },
              child: Text('Cadastrar Curso'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListaCursos()));
              },
              child: Text('Listar Cursos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MatricularAluno()));
              },
              child: Text('Matricular Aluno'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListaCursosAlunos()));
              },
              child: Text('Alunos Por Curso'),
            ),
          ],
        ),
      ),
    );
  }
}
