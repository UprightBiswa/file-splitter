package main

import (
	"fmt"
	"log"

	"go-api/config"
	"go-api/router"
)

func main() {
	// 1. Load application configuration from .env or environment variables
	config.LoadConfig()
	cfg := config.GetConfig()

	// 2. Setup Gin router with all handlers and middleware
	r := router.SetupRouter()

	// 3. Start the HTTP server
	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("Go Gin server starting on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
