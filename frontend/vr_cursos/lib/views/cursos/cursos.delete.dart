import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vr_cursos/views/cursos/cursos.list.dart';

import '../../api/api.config.dart';
import '../Home/home.page.dart';

class CursoDelete extends StatefulWidget {
  final int codCurso;
  final String descCurso;
  final String ementaCurso;

  CursoDelete(this.codCurso, this.descCurso, this.ementaCurso);

  @override
  State<CursoDelete> createState() => _CursoDeleteState();
}

class _CursoDeleteState extends State<CursoDelete> {
  TextEditingController deleteDescController = TextEditingController();
  TextEditingController deleteEmentaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    deleteDescController = TextEditingController(text: widget.descCurso);
    deleteEmentaController = TextEditingController(text: widget.ementaCurso);
  }

  Future<void> deleteCUrso() async {
    final response =
        await http.delete(Uri.parse(ApiConfig.deleteCursoUrl(widget.codCurso)));

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
        content: Text("Erro ao excluir curso. Tente novamente."),
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
          'Excluir Curso',
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
                'Código: ${widget.codCurso}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Curso: ${widget.descCurso}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ementa: ${widget.ementaCurso}',
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
                        content:
                            Text("Tem certeza que deseja excluir o curso?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteCUrso();
                            },
                            child: Text("Confirmar"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Excluir Curso'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
