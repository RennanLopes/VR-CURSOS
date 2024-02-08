import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/api.config.dart';
import '../Home/home.page.dart';
import 'alunos.list.dart';

class AlunoDelete extends StatefulWidget {
  final int codAluno;
  final String nAluno;

  AlunoDelete(this.codAluno, this.nAluno);

  @override
  State<AlunoDelete> createState() => _AlunoDeleteState();
}

class _AlunoDeleteState extends State<AlunoDelete> {
  TextEditingController deleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    deleteController = TextEditingController(text: widget.nAluno);
  }

  Future<void> deleteAluno() async {
    final response = await http.delete(
      Uri.parse(ApiConfig.deleteAlunoUrl(widget.codAluno))
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
          builder: (context) => ListaAlunos(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Erro ao excluir aluno. Tente novamente."),
      ));
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
          'Excluir Aluno',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Código: ${widget.codAluno}',
                style: TextStyle(fontSize: 16,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aluno: ${widget.nAluno}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirmar exclusão"),
                        content: Text("Tem certeza que deseja excluir o aluno?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteAluno();
                            },
                            child: Text("Confirmar"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Excluir Aluno'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
