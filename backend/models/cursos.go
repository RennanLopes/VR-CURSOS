package models

import "gorm.io/gorm"

type Cursos struct {
	Codigo    uint    `gorm:"primary key;autoIncrement" json:"codigo"`
	Descricao *string `json:"descricao"`
	Ementa    *string `json:"ementa"`
}

func MigrateCursos(db *gorm.DB) error {
	err := db.AutoMigrate(&Cursos{})
	return err
}
