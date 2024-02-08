package handlers

import (
	"errors"
	"net/http"
	"strings"

	"github.com/RennanLopes/vr-cursos/models"
	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func (r *Repository) CreateAluno(context *fiber.Ctx) error {
	aluno := Aluno{}

	err := context.BodyParser(&aluno)
	if err != nil {
		context.Status(http.StatusUnprocessableEntity).JSON(
			&fiber.Map{"message": "Falha na requisição"})
		return err
	}

	// Verifica se já existe um aluno com o mesmo nome no banco de dados
	var existingAluno Aluno
	err = r.DB.Where("nome = ?", aluno.Nome).First(&existingAluno).Error
	if err == nil {
		context.Status(http.StatusConflict).JSON(
			&fiber.Map{"message": "Já existe um aluno cadastrado com esse nome"})
		return err
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Erro ao verificar a existência do aluno"})
		return err
	}

	err = r.DB.Create(&aluno).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "Não foi possível criar aluno"})
		return err
	}

	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "O aluno foi adicionado"})
	return nil
}

func (r *Repository) UpdateAluno(context *fiber.Ctx) error {
	id := context.Params("id")
	aluno := Aluno{}

	if id == "" {
		context.Status(http.StatusInternalServerError).JSON(&fiber.Map{
			"message": "ID não pode ser vazio",
		})
		return nil
	}

	err := context.BodyParser(&aluno)
	if err != nil {
		context.Status(http.StatusUnprocessableEntity).JSON(
			&fiber.Map{"message": "Falha na requisição"})
		return err
	}

	existingAluno := &models.Alunos{}
	err = r.DB.Where("codigo = ?", id).First(existingAluno).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "aluno não encontrado"})
		return err
	}

	err = r.DB.Model(&existingAluno).Where("codigo = ?", id).Updates(&aluno).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "Não foi possível atualizar o aluno"})
		return err
	}

	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "aluno atualizado com sucesso",
		"data":    existingAluno,
	})
	return nil
}

func (r *Repository) SelectAlunos(context *fiber.Ctx) error {
	alunoModels := &[]models.Alunos{}

	err := r.DB.Order("codigo DESC").Limit(20).Find(alunoModels).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "Não foi possível encontar alunos"})
		return err

	}

	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "Alunos encontrados com sucesso",
		"data":    alunoModels,
	})
	return nil
}

func (r *Repository) SelectAluno(context *fiber.Ctx) error {
	id := context.Params("id")
	alunoModel := &models.Alunos{}

	if id == "" {
		context.Status(http.StatusInternalServerError).JSON(&fiber.Map{
			"message": "id não pode ser vazio",
		})
		return nil
	}

	err := r.DB.Where("codigo = ?", id).First(alunoModel).Error

	if err != nil {
		context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Não foi possível pegar o aluno"})
		return context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Não foi possível pegar o aluno"})
	}
	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "Aluno obitido com sucesso",
		"data":    alunoModel,
	})
	return nil
}

func (r *Repository) DeleteAluno(context *fiber.Ctx) error {
	alunoModel := models.Alunos{}
	id := context.Params("id")
	if id == "" {
		context.Status(http.StatusInternalServerError).JSON(&fiber.Map{
			"message": "codigo não pode ser vazio",
		})
		return nil
	}

	err := r.DB.Delete(alunoModel, id)

	if err.Error != nil {
		context.Status(http.StatusBadRequest).JSON(&fiber.Map{
			"message": "Não foi possível deletar o aluno",
		})
		return err.Error
	}
	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "Aluno deletado com sucesso",
	})
	return nil
}

func (r *Repository) SelectAlunoNome(context *fiber.Ctx) error {
	nome := context.Query("nome")
	nome = strings.ToLower(nome)
	nomeParts := strings.Split(nome, " ")
	alunoModels := &[]models.Alunos{}

	query := r.DB
	for _, part := range nomeParts {
		query = query.Where("LOWER(REPLACE(nome, ' ', '')) LIKE ?", "%"+part+"%")
	}

	err := query.Find(alunoModels).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "Não foi possível encontrar alunos"})
		return err
	}

	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "Alunos encontrados com sucesso",
		"data":    alunoModels,
	})
	return nil
}
