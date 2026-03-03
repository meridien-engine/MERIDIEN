package models

import (
	"database/sql/driver"
	"encoding/json"
	"errors"
)

// JSONB is a custom type for JSONB columns in PostgreSQL
type JSONB map[string]interface{}

// Value implements the driver.Valuer interface
func (j JSONB) Value() (driver.Value, error) {
	if j == nil {
		return "{}", nil
	}
	return json.Marshal(j)
}

// Scan implements the sql.Scanner interface
func (j *JSONB) Scan(value interface{}) error {
	if value == nil {
		*j = make(JSONB)
		return nil
	}

	bytes, ok := value.([]byte)
	if !ok {
		return errors.New("failed to scan JSONB value")
	}

	return json.Unmarshal(bytes, j)
}
