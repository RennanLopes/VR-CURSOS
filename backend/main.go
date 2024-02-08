package main

import (
	"log"
	"os"

	"github.com/RennanLopes/vr-cursos/handlers"
	"github.com/RennanLopes/vr-cursos/models"
	"github.com/RennanLopes/vr-cursos/storage"
	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Fatal(err)
	}
	config := &storage.Config{
		Host:     os.Getenv("DB_HOST"),
		Port:     os.Getenv("DB_PORT"),
		User:     os.Getenv("DB_USER"),
		Password: os.Getenv("DB_PASS"),
		DBName:   os.Getenv("DB_NAME"),
		SSLMode:  os.Getenv("DB_SSLMODE"),
	}

	db, err := storage.NewConnection(config)
	if err != nil {
		log.Fatal("Não foi possível conectar ao Banco de Dados")
	}

	err = models.MigrateCursos(db)
	if err != nil {
		log.Fatal("Não foi possível criar a tabela cursos no Banco de Dados")
	}

	err = models.MigrateAlunos(db)
	if err != nil {
		log.Fatal("Não foi possível criar a tabela alunos no Banco de Dados")
	}

	err = models.MigrateCursoAluno(db)
	if err != nil {
		log.Fatal("Não foi possível criar a tabela curso_aluno no Banco de Dados")
	}

	r := handlers.Repository{
		DB: db,
	}

	app := fiber.New()
	r.SetupRoute(app)
	app.Listen(":9090")
}
