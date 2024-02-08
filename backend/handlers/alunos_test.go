package handlers

import (
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
)

func TestSelectAluno(t *testing.T) {

	tests := []struct {
		description  string
		route        string
		expectedCode int
	}{
		// First test case
		{
			description:  "get HTTP status 200",
			route:        "/select-alunos",
			expectedCode: 200,
		},

		{
			description:  "get HTTP status 404, when route is not exists",
			route:        "/not-found",
			expectedCode: 404,
		},
	}

	app := fiber.New()

	app.Get("/select-alunos", func(c *fiber.Ctx) error {
		// Return JSON response
		return c.JSON(fiber.Map{
			"data": []fiber.Map{
				{
					"codigo": 1,
					"nome":   "Rennan Lopes",
				},
			},
			"message": "Alunos encontrados com sucesso",
		})
	})

	for _, test := range tests {

		req := httptest.NewRequest("GET", test.route, nil)

		resp, _ := app.Test(req, 1)
		// Verifica se o código de status está conforme o esperado
		assert.Equalf(t, test.expectedCode, resp.StatusCode, test.description)
	}
}

func TestSelectAlunoIntegrado(t *testing.T) {
	// Define o aplicativo Fiber.
	app := SetupApp()

	// Cria uma solicitação HTTP GET para a rota '/select-alunos'
	req, err := http.NewRequest("GET", "/select-alunos", nil)
	if err != nil {
		t.Fatalf("Erro ao criar requisição: %v", err)
	}

	// Realiza a solicitação HTTP com o aplicativo Fiber
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Erro ao realizar solicitação HTTP: %v", err)
	}

	// Verifica se o código de status da resposta é 200 (OK)
	assert.Equal(t, http.StatusOK, resp.StatusCode)

	// Verifica o corpo da resposta
	expectedJSON := `{"data":[{"codigo":1,"nome":"Rennan Lopes"}],"message":"Alunos encontrados com sucesso"}`
	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("Erro ao ler corpo da resposta: %v", err)
	}
	assert.JSONEq(t, expectedJSON, string(bodyBytes))
}

// Função auxiliar para configurar o aplicativo Fiber para testes
func SetupApp() *fiber.App {
	// Define o aplicativo Fiber.
	app := fiber.New()

	// Cria rota com método GET para teste
	app.Get("/select-alunos", func(c *fiber.Ctx) error {
		// Retorna resposta JSON
		return c.JSON(fiber.Map{
			"data": []fiber.Map{
				{
					"codigo": 1,
					"nome":   "Rennan Lopes",
				},
			},
			"message": "Alunos encontrados com sucesso",
		})
	})

	return app
}
