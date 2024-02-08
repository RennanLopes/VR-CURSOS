import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vr_cursos/api/api.config.dart';
import '../Home/home.page.dart';
import 'alunos.list.dart';

class AlunoUpdate extends StatefulWidget {
  final int codAluno;
  final String nAluno;

  AlunoUpdate(this.codAluno, this.nAluno);

  @override
  _AlunoUpdateState createState() => _AlunoUpdateState();
}

class _AlunoUpdateState extends State<AlunoUpdate> {
  TextEditingController editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.nAluno);
  }

  Future<void> updateAluno() async {
    final response = await http.put(
      Uri.parse(ApiConfig.updateAlunoUrl(widget.codAluno)),
      body: {"nome": editController.text},
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
        content: Text("Erro ao atualizar aluno. Tente novamente."),
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
          'Editar Aluno',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
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
                      controller: editController,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'Nome do Aluno',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              updateAluno();
            },
            child: Text('Salvar Alterações'),
          ),
        ],
      ),
    );
  }
}
