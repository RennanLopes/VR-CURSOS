package handlers

import (
	"net/http"

	"github.com/RennanLopes/vr-cursos/models"
	"github.com/gofiber/fiber/v2"
)

func (r *Repository) MatricularAluno(context *fiber.Ctx) error {
	matricula := Curso_Aluno{}

	err := context.BodyParser(&matricula)
	if err != nil {
		context.Status(http.StatusUnprocessableEntity).JSON(
			&fiber.Map{"message": "Falha na Requisição"})
		return err
	}

	// Verificar se o curso está cheio
	var count int64
	if err := r.DB.Model(&Curso_Aluno{}).Where("codigo_curso = ?", matricula.Codigo_curso).Count(&count).Error; err != nil {
		context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Erro ao verificar a quantidade de alunos matriculados no curso"})
		return err
	}
	if count >= 10 {
		context.Status(http.StatusUnprocessableEntity).JSON(
			&fiber.Map{"message": "O curso já está cheio"})
		return nil
	}

	// Verificar se o aluno já está matriculado em 3 cursos
	if err := r.DB.Model(&Curso_Aluno{}).Where("codigo_aluno = ?", matricula.Codigo_aluno).Count(&count).Error; err != nil {
		context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Erro ao verificar a quantidade de cursos matriculados pelo aluno"})
		return err
	}
	if count >= 3 {
		context.Status(http.StatusUnprocessableEntity).JSON(
			&fiber.Map{"message": "O aluno já está matriculado em 3 cursos"})
		return nil
	}

	if err := r.DB.Create(&matricula).Error; err != nil {
		context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Erro ao criar matrícula"})
		return err
	}

	context.Status(http.StatusCreated).JSON(
		&fiber.Map{"message": "Aluno matriculado com sucesso"})

	return nil
}

func (r *Repository) AlunosPorCurso(context *fiber.Ctx) error {
	cursosAlunos := &[]models.Curso_Aluno{}

	// Obtenha os registros de Curso_Aluno
	if err := r.DB.Find(cursosAlunos).Error; err != nil {
		context.Status(http.StatusBadRequest).JSON(
			fiber.Map{"message": "Não foi possível encontrar os cursos e alunos matriculados"})
		return err
	}

	// Mapa para armazenar os nomes dos cursos e seus alunos
	cursosComAlunos := make(map[string][]string)

	for _, ca := range *cursosAlunos {
		curso := &models.Cursos{}
		aluno := &models.Alunos{}

		if err := r.DB.Where("codigo = ?", ca.Codigo_curso).First(curso).Error; err != nil {
			return err
		}

		if err := r.DB.Where("codigo = ?", ca.Codigo_aluno).First(aluno).Error; err != nil {
			return err
		}

		cursosComAlunos[*curso.Descricao] = append(cursosComAlunos[*curso.Descricao], *aluno.Nome)
	}

	context.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Cursos e alunos encontrados com sucesso",
		"data":    cursosComAlunos,
	})

	return nil
}
