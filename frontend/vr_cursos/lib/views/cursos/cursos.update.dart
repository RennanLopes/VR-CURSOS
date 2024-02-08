import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vr_cursos/views/cursos/cursos.list.dart';

import '../../api/api.config.dart';
import '../Home/home.page.dart';

class CursoUpdate extends StatefulWidget {
  final int codCurso;
  final String nDescricao;
  final String nEmenta;

  CursoUpdate(this.codCurso, this.nDescricao, this.nEmenta);

  @override
  State<CursoUpdate> createState() => _CursoUpdateState();
}

class _CursoUpdateState extends State<CursoUpdate> {
  TextEditingController editCursoController = TextEditingController();
  TextEditingController editEmentaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editCursoController = TextEditingController(text: widget.nDescricao);
    editEmentaController = TextEditingController(text: widget.nEmenta);
  }

  Future<void> updateCurso() async {
    final response = await http.put(
      Uri.parse(ApiConfig.updateCursoUrl(widget.codCurso)),
      body: {
        "descricao": editCursoController.text,
        "ementa": editEmentaController.text,
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
        content: Text("Erro ao atualizar curso. Tente novamente."),
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
          'Editar Curso',
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
                    child: Column(
                      children: [
                        TextField(
                          controller: editCursoController,
                          maxLength: 50,
                          decoration: InputDecoration(
                            labelText: 'Nome do Curso',
                          ),
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: editEmentaController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Ementa do Curso',
                          ),
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: editCursoController.text.isNotEmpty &&
                    editEmentaController.text.isNotEmpty
                ? () {
                    updateCurso();
                  }
                : null,
            child: Text('Salvar Alterações'),
          ),
        ],
      ),
    );
  }
}
