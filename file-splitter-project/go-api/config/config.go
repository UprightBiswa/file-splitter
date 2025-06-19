package config

import (
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

// AppConfig holds all application-wide configurations
type AppConfig struct {
	Port           string
	PythonServiceURL string
	UploadDir        string
	SplitDir         string
	AllowedTypes     []string
}

// Global variable to hold the loaded configuration
var Cfg *AppConfig

// LoadConfig initializes the application configuration from environment variables
func LoadConfig() {
	// Load .env file if it exists
	if err := godotenv.Load(); err != nil {
		log.Printf("No .env file found, falling back to OS environment variables: %v", err)
	}

	// Set default values or load from environment
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Default port
	}

	pythonServiceURL := os.Getenv("PYTHON_SERVICE_URL")
	if pythonServiceURL == "" {
		pythonServiceURL = "http://localhost:8000" // Default Python service URL
	}

	uploadDir := os.Getenv("UPLOAD_DIR")
	if uploadDir == "" {
		uploadDir = "./static/uploads" // Default upload directory
	}

	splitDir := os.Getenv("SPLIT_DIR")
	if splitDir == "" {
		splitDir = "./static/splits" // Default split directory
	}

	allowedTypesStr := os.Getenv("ALLOWED_TYPES")
	if allowedTypesStr == "" {
		allowedTypesStr = ".txt,.doc,.docx,.pdf" // Default allowed types
	}
	allowedTypes := strings.Split(allowedTypesStr, ",")
	for i, t := range allowedTypes {
		allowedTypes[i] = strings.TrimSpace(t) // Trim whitespace
	}

	Cfg = &AppConfig{
		Port:           port,
		PythonServiceURL: pythonServiceURL,
		UploadDir:        uploadDir,
		SplitDir:         splitDir,
		AllowedTypes:     allowedTypes,
	}

	log.Printf("Configuration Loaded: %+v\n", *Cfg)
}

// GetConfig returns the loaded application configuration
func GetConfig() *AppConfig {
	if Cfg == nil {
		log.Fatal("Config not loaded. Call LoadConfig() first.")
	}
	return Cfg
}
