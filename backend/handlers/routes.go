package handlers

import (
	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

type Curso struct {
	Descricao string `json:"descricao"`
	Ementa    string `json:"ementa"`
}

type Aluno struct {
	Nome string `json:"nome"`
}

type Curso_Aluno struct {
	Codigo_aluno uint `json:"codigo_aluno"`
	Codigo_curso uint `json:"codigo_curso"`
}

type Repository struct {
	DB *gorm.DB
}

func (r *Repository) SetupRoute(app *fiber.App) {
	api := app.Group("/api")
	//Rotas para Curso
	api.Post("/create-curso", r.CreateCurso)
	api.Put("/update-curso/:id", r.UpdateCurso)
	api.Get("/select-cursos", r.SelectCursos)
	api.Get("/select-curso/:id", r.SelectCurso)
	api.Delete("/delete-curso/:id", r.DeleteCurso)
	api.Get("/select-nome-curso", r.SelectCursoNome)

	// Rotas para alunos
	api.Post("/create-aluno", r.CreateAluno)
	api.Put("/update-aluno/:id", r.UpdateAluno)
	api.Get("/select-alunos", r.SelectAlunos)
	api.Get("/select-aluno/:id", r.SelectAluno)
	api.Delete("/delete-aluno/:id", r.DeleteAluno)
	api.Get("/select-nome-aluno", r.SelectAlunoNome)

	// Rotas para curso_aluno
	api.Post("/create-matricula", r.MatricularAluno)
	api.Get("/alunos-por-curso", r.AlunosPorCurso)

}
