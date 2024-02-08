import 'dart:async';
import 'dart:convert';
import 'package:vr_cursos/views/Alunos/alunos.list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/api.config.dart';
import '../Home/home.page.dart';

class AlunoAdd extends StatefulWidget {
  //const AlunoAdd({super.key});

  @override
  State<AlunoAdd> createState() => _AlunoAddState();
}

class _AlunoAddState extends State<AlunoAdd> {
  final _formkey = GlobalKey<FormState>();
  final nomeAlunoController = TextEditingController();

  Future<void> createAluno() async {
    final response = await http.post(
      Uri.parse(ApiConfig.createAlunoUrl),
      body: {"nome": nomeAlunoController.text},
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
    } else if (response.statusCode == 409) {
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
        content: Text("Erro ao adicionar aluno. Tente novamente."),
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
          'Adicionar Aluno',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: nomeAlunoController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Nome do Aluno:',
                ),
                onChanged: (_) {
                  setState(
                      () {}); // Atualiza o estado do widget quando o texto muda
                },
              ),
              const SizedBox(height: 16.0), //
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: nomeAlunoController.text.isNotEmpty
                      ? () {
                          createAluno();
                        }
                      : null, // Desabilita o botão se o campo estiver vazio
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
