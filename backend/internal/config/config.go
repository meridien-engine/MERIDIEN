package config

import (
	"fmt"
	"os"

	"github.com/spf13/viper"
)

// Config holds all application configuration
type Config struct {
	App      AppConfig
	Database DatabaseConfig
	JWT      JWTConfig
	Redis    RedisConfig
}

// AppConfig holds application-level configuration
type AppConfig struct {
	Name        string
	Environment string
	Port        string
	Debug       bool
}

// DatabaseConfig holds database configuration
type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	Name     string
	SSLMode  string
}

// JWTConfig holds JWT configuration
type JWTConfig struct {
	Secret          string
	ExpirationHours int
}

// RedisConfig holds Redis configuration
type RedisConfig struct {
	Host     string
	Port     string
	Password string
	DB       int
}

// Load reads configuration from environment variables and .env file
func Load() (*Config, error) {
	// Set config file
	viper.SetConfigFile("configs/.env")
	viper.SetConfigType("env")

	// Read config file
	if err := viper.ReadInConfig(); err != nil {
		// It's okay if .env doesn't exist, we'll use environment variables
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return nil, fmt.Errorf("error reading config file: %w", err)
		}
	}

	// Auto read environment variables
	viper.AutomaticEnv()

	// Build config
	config := &Config{
		App: AppConfig{
			Name:        getEnvOrDefault("APP_NAME", "MERIDIEN"),
			Environment: getEnvOrDefault("APP_ENV", "development"),
			Port:        getEnvOrDefault("APP_PORT", "8080"),
			Debug:       getEnvOrDefault("APP_DEBUG", "true") == "true",
		},
		Database: DatabaseConfig{
			Host:     getEnvOrDefault("DB_HOST", "localhost"),
			Port:     getEnvOrDefault("DB_PORT", "5432"),
			User:     getEnvOrDefault("DB_USER", "postgres"),
			Password: getEnvOrDefault("DB_PASSWORD", "postgres"),
			Name:     getEnvOrDefault("DB_NAME", "meridien_dev"),
			SSLMode:  getEnvOrDefault("DB_SSLMODE", "disable"),
		},
		JWT: JWTConfig{
			Secret:          getEnvOrDefault("JWT_SECRET", "your-super-secret-jwt-key-change-this-in-production"),
			ExpirationHours: getEnvOrDefaultInt("JWT_EXPIRATION_HOURS", 24),
		},
		Redis: RedisConfig{
			Host:     getEnvOrDefault("REDIS_HOST", "localhost"),
			Port:     getEnvOrDefault("REDIS_PORT", "6379"),
			Password: getEnvOrDefault("REDIS_PASSWORD", ""),
			DB:       getEnvOrDefaultInt("REDIS_DB", 0),
		},
	}

	// Validate required fields
	if err := config.Validate(); err != nil {
		return nil, err
	}

	return config, nil
}

// Validate checks if all required configuration is present
func (c *Config) Validate() error {
	if c.JWT.Secret == "your-super-secret-jwt-key-change-this-in-production" && c.App.Environment == "production" {
		return fmt.Errorf("JWT_SECRET must be set in production environment")
	}

	if c.Database.Host == "" {
		return fmt.Errorf("DB_HOST is required")
	}

	if c.Database.Name == "" {
		return fmt.Errorf("DB_NAME is required")
	}

	return nil
}

// GetDSN returns the database connection string
func (c *DatabaseConfig) GetDSN() string {
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.Host, c.Port, c.User, c.Password, c.Name, c.SSLMode,
	)
}

// Helper functions
func getEnvOrDefault(key, defaultValue string) string {
	if value := viper.GetString(key); value != "" {
		return value
	}
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvOrDefaultInt(key string, defaultValue int) int {
	if value := viper.GetInt(key); value != 0 {
		return value
	}
	return defaultValue
}
