package models

import "gorm.io/gorm"

type Alunos struct {
	Codigo uint    `gorm:"primary key;autoIncrement" json:"codigo"`
	Nome   *string `json:"nome"`
}

func MigrateAlunos(db *gorm.DB) error {
	err := db.AutoMigrate(&Alunos{})
	return err
}
