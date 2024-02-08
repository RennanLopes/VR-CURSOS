package models

import "gorm.io/gorm"

type Curso_Aluno struct {
	Codigo       uint `gorm:"primary key;autoIncrement" json:"codigo"`
	Codigo_aluno uint `json:"codigo_aluno"`
	Codigo_curso uint `json:"codigo_curso"`
}

func MigrateCursoAluno(db *gorm.DB) error {
	err := db.AutoMigrate(&Curso_Aluno{})
	return err
}
