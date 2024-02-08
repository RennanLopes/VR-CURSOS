package handlers

import (
	"errors"
	"net/http"
	"strings"

	"github.com/RennanLopes/vr-cursos/models"
	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

func (r *Repository) CreateCurso(context *fiber.Ctx) error {
	curso := Curso{}

	err := context.BodyParser(&curso)
	if err != nil {
		context.Status(http.StatusUnprocessableEntity).JSON(
			&fiber.Map{"message": "Falha na requisição"})
		return err
	}

	// Verifica se já existe um curso com o mesmo nome no banco de dados
	var existingCurso Curso
	err = r.DB.Where("descricao = ?", curso.Descricao).First(&existingCurso).Error
	if err == nil {
		context.Status(http.StatusConflict).JSON(
			&fiber.Map{"message": "Já existe um curso com esse nome"})
		return err
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Erro ao verificar a existência do curso"})
		return err
	}

	err = r.DB.Create(&curso).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "Não foi possível criar curso"})
		return err
	}

	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "O curso foi adicionado"})
	return nil
}

func (r *Repository) UpdateCurso(context *fiber.Ctx) error {
	id := context.Params("id")
	curso := Curso{}

	if id == "" {
		context.Status(http.StatusInternalServerError).JSON(&fiber.Map{
			"message": "ID não pode ser vazio",
		})
		return nil
	}

	err := context.BodyParser(&curso)
	if err != nil {
		context.Status(http.StatusUnprocessableEntity).JSON(
			&fiber.Map{"message": "Falha na requisição"})
		return err
	}

	existingCurso := &models.Cursos{}
	err = r.DB.Where("codigo = ?", id).First(existingCurso).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "Curso não encontrado"})
		return err
	}

	err = r.DB.Model(&existingCurso).Where("codigo = ?", id).Updates(&curso).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "Não foi possível atualizar o curso"})
		return err
	}

	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "Curso atualizado com sucesso",
		"data":    existingCurso,
	})
	return nil
}

func (r *Repository) SelectCursos(context *fiber.Ctx) error {
	cursoModels := &[]models.Cursos{}

	err := r.DB.Order("codigo DESC").Limit(20).Find(cursoModels).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			&fiber.Map{"message": "Não foi possível encontar cursos"})
		return err

	}

	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "Cursos encontrados com sucesso",
		"data":    cursoModels,
	})
	return nil
}

func (r *Repository) SelectCurso(context *fiber.Ctx) error {
	id := context.Params("id")
	cursoModel := &models.Cursos{}

	if id == "" {
		context.Status(http.StatusInternalServerError).JSON(&fiber.Map{
			"message": "id não pode ser vazio",
		})
		return nil
	}

	//fmt.Println("O id é: ", id)

	err := r.DB.Where("codigo = ?", id).First(cursoModel).Error

	if err != nil {
		context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Não foi possível pegar o curso"})
		return context.Status(http.StatusInternalServerError).JSON(
			&fiber.Map{"message": "Não foi possível pegar o curso"})
	}
	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "Curso obitido com sucesso",
		"data":    cursoModel,
	})
	return nil
}

func (r *Repository) DeleteCurso(context *fiber.Ctx) error {
	cursoModel := models.Cursos{}
	id := context.Params("id")
	if id == "" {
		context.Status(http.StatusInternalServerError).JSON(&fiber.Map{
			"message": "codigo não pode ser vazio",
		})
		return nil
	}

	err := r.DB.Delete(cursoModel, id)

	if err.Error != nil {
		context.Status(http.StatusBadRequest).JSON(&fiber.Map{
			"message": "Não foi possível deletar o curso",
		})
		return err.Error
	}
	context.Status(http.StatusOK).JSON(&fiber.Map{
		"message": "curso deletado com sucesso",
	})
	return nil
}

func (r *Repository) SelectCursoNome(context *fiber.Ctx) error {
	descricao := context.Query("descricao")
	descricao = strings.ToLower(descricao)
	descricaoParts := strings.Split(descricao, " ")
	cursos := []models.Cursos{}
	Messages := make(map[uint]string)

	query := r.DB
	for _, part := range descricaoParts {
		query = query.Where("LOWER(REPLACE(descricao, ' ', '')) LIKE ?", "%"+part+"%")
	}

	err := query.Find(&cursos).Error
	if err != nil {
		context.Status(http.StatusBadRequest).JSON(
			fiber.Map{"message": "Não foi possível encontrar cursos"})
		return err
	}

	for _, curso := range cursos {
		var count int64
		if err := r.DB.Model(&Curso_Aluno{}).Where("codigo_curso = ?", curso.Codigo).Count(&count).Error; err != nil {
			context.Status(http.StatusInternalServerError).JSON(
				fiber.Map{"message": "Erro ao verificar a quantidade de alunos matriculados no curso"})
			return err
		}
		if count >= 10 {
			Messages[curso.Codigo] = "O curso " + *curso.Descricao + " já está cheio"
		}
	}

	responseData := struct {
		Data     []models.Cursos `json:"data"`
		Messages map[uint]string `json:"messages"`
	}{
		Data:     cursos,
		Messages: Messages,
	}

	context.Status(http.StatusOK).JSON(responseData)
	return nil
}
