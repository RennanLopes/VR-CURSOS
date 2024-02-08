class ApiConfig {
  static const String baseUrl = 'http://localhost:9090';

  //AEndpoints de Alunos
  static String get createAlunoUrl => '$baseUrl/api/create-aluno/';
  static String get selectAlunosUrl => '$baseUrl/api/select-alunos';
  static String updateAlunoUrl(int alunoId) => '$baseUrl/api/update-aluno/$alunoId';
  static String deleteAlunoUrl(int alunoId) => '$baseUrl/api/delete-aluno/$alunoId';
  static String selectAlunoByNameUrl(String alunoNome) => '$baseUrl/api/select-nome-aluno/?nome=$alunoNome';

  //AEndpoints de Curso
  static String get createCursoUrl => '$baseUrl/api/create-curso/';
  static String get selectCursosUrl => '$baseUrl/api/select-cursos';
  static String updateCursoUrl(int alunoId) => '$baseUrl/api/update-curso/$alunoId';
  static String deleteCursoUrl(int alunoId) => '$baseUrl/api/delete-curso/$alunoId';
  static String selectCursoByNameUrl(String cursoNome) => '$baseUrl/api/select-nome-curso/?descricao=$cursoNome';

  //Matricuar Aluno
  static String get matricularAlunoUrl => '$baseUrl/api/create-matricula/';
  static String get selectAlunosPorCursoUrl => '$baseUrl/api/alunos-por-curso';
}