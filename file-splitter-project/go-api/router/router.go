package router

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"

	"go-api/clients"
	"go-api/config"
	"go-api/handlers"
	"go-api/middleware"
	"go-api/services"
	"go-api/utils" // Import utils for directory creation
)

// SetupRouter initializes the Gin router with all routes and middleware.
func SetupRouter() *gin.Engine {
	cfg := config.GetConfig() // Get the application configuration

	// Set Gin mode
	gin.SetMode(gin.ReleaseMode) // Set to gin.ReleaseMode in production

	r := gin.New() // Use gin.New() for more control over middleware chain

	// Global Middleware
	r.Use(gin.Logger())   // Logs HTTP requests
	r.Use(gin.Recovery()) // Recovers from panics and writes a 500
	r.Use(middleware.CORSMiddleware()) // Apply CORS middleware

	// Initialize dependencies
	pythonSplitterClient := clients.NewPythonSplitterClient()
	fileService := services.NewFileService(cfg, pythonSplitterClient)
	fileHandler := handlers.NewFileHandler(fileService)

	// --- Routes ---
	api := r.Group("/") // No specific /api prefix needed for these routes

	// POST /upload: Handles file uploads
	api.POST("/upload", fileHandler.UploadFile)

	// POST /split: Initiates file splitting via Python service
	api.POST("/split", fileHandler.InitiateSplit)

	// GET /splits: Lists available split files
	// Note: This endpoint will be changed to serve static files directly in the next step.
	// For now, it will return a JSON list of files.
	api.GET("/splits", fileHandler.ListSplitFiles)


	// Serve static files from the 'static' directory
	// Ensure these directories exist
	if err := utils.CreateDirIfNotExist(cfg.UploadDir); err != nil {
		log.Fatalf("Failed to create upload directory %s: %v", cfg.UploadDir, err)
	}
	if err := utils.CreateDirIfNotExist(cfg.SplitDir); err != nil {
		log.Fatalf("Failed to create split directory %s: %v", cfg.SplitDir, err)
	}

	// Serve the 'static' directory which contains 'uploads' and 'splits'
	// This makes split files directly downloadable by the frontend
	r.StaticFS("/static", http.Dir("./static"))
	log.Printf("Serving static files from ./static at /static endpoint.")


	// Health Check / Root route
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "Go Gin File Splitter API is running!"})
	})

	return r
}
