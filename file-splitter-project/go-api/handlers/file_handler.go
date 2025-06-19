package handlers

import (
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"go-api/models"
	"go-api/services"
)

// FileHandler defines the interface for file-related HTTP handlers.
type FileHandler interface {
	UploadFile(c *gin.Context)
	InitiateSplit(c *gin.Context)
	ListSplitFiles(c *gin.Context)
}

// fileHandler implements the FileHandler interface.
type fileHandler struct {
	fileService services.FileService
}

// NewFileHandler creates a new instance of FileHandler.
func NewFileHandler(fileService services.FileService) FileHandler {
	return &fileHandler{
		fileService: fileService,
	}
}

// UploadFile handles POST requests to /upload.
// It receives a multipart form with a file, saves it, and returns a success message.
func (h *fileHandler) UploadFile(c *gin.Context) {
	file, err := c.FormFile("file") // "file" is the key from the multipart form
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file found in request or failed to parse form", "details": err.Error()})
		log.Printf("UploadFile error: %v", err)
		return
	}

	response, err := h.fileService.UploadFile(file)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload file", "details": err.Error()})
		log.Printf("UploadFile service error: %v", err)
		return
	}

	c.JSON(http.StatusOK, response)
	log.Printf("File uploaded successfully: %s", response.FileName)
}

// InitiateSplit handles POST requests to /split.
// It receives a JSON payload, calls the Python service to split the file,
// and returns the list of split parts.
func (h *fileHandler) InitiateSplit(c *gin.Context) {
	var req models.SplitRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request payload", "details": err.Error()})
		log.Printf("InitiateSplit error binding JSON: %v", err)
		return
	}

	splitParts, err := h.fileService.InitiateSplit(req)
	if err != nil {
		log.Printf("InitiateSplit service error: %v", err)
		// Distinguish between file not found (user error) and service error
		if strings.Contains(err.Error(), "uploaded file not found") {
			c.JSON(http.StatusNotFound, gin.H{"error": "File not found for splitting", "details": err.Error()})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to initiate file splitting", "details": err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"parts": splitParts})
	log.Printf("Split initiated successfully for %s, %d parts generated.", req.Filename, len(splitParts))
}

// ListSplitFiles handles GET requests to /splits.
// It retrieves and returns a list of available split files.
func (h *fileHandler) ListSplitFiles(c *gin.Context) {
	// The frontend expects the GET /splits endpoint to return the list of files directly
	// without needing a query parameter like "filename".
	// It will simply list all currently available split files in the splits directory.
	
	splitFiles, err := h.fileService.ListSplitFiles()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list split files", "details": err.Error()})
		log.Printf("ListSplitFiles service error: %v", err)
		return
	}

	// The frontend expects an array directly, not an object with a "files" key.
	// Adjusting the response structure to match Flutter's expectation (List<SplitResultModel>).
	c.JSON(http.StatusOK, splitFiles)
	log.Printf("Successfully listed %d split files.", len(splitFiles))
}
