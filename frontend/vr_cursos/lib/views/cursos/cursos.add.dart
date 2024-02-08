import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vr_cursos/views/cursos/cursos.list.dart';

import '../../api/api.config.dart';
import '../Home/home.page.dart';

class CursoAdd extends StatefulWidget {
  const CursoAdd({super.key});

  @override
  State<CursoAdd> createState() => _CursoAddState();
}

class _CursoAddState extends State<CursoAdd> {
  final _formkey = GlobalKey<FormState>();
  final descricaoCursoController = TextEditingController();
  final ementaCursoController = TextEditingController();

  Future<void> createCurso() async {
    final response = await http.post(
      Uri.parse(ApiConfig.createCursoUrl),
      body: {
        "descricao": descricaoCursoController.text,
        "ementa": ementaCursoController.text,
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
          builder: (context) => ListaCursos(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Erro ao adicionar curso. Tente novamente."),
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
          'Adicionar Curso',
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
                controller: descricaoCursoController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Nome do Curso:',
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: ementaCursoController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Ementa do Curso:',
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: descricaoCursoController.text.isNotEmpty &&
                          ementaCursoController.text.isNotEmpty
                      ? () {
                          createCurso();
                        }
                      : null, // Desabilita o botão se algum dos campos estiver vazio
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
