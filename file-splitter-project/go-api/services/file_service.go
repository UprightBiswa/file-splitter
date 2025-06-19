package services

import (
	"fmt"
	"io/ioutil"
	"log"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"

	"go-api/clients"
	"go-api/config"
	"go-api/models"
	"go-api/utils"
)

// FileService defines the interface for file-related operations.
type FileService interface {
	UploadFile(file *multipart.FileHeader) (*models.UploadResponse, error)
	InitiateSplit(req models.SplitRequest) ([]models.SplitPart, error)
	ListSplitFiles() ([]models.SplitPart, error)
}

// fileService implements the FileService interface.
type fileService struct {
	cfg                *config.AppConfig
	pythonSplitterClient *clients.PythonSplitterClient
}

// NewFileService creates a new instance of FileService.
func NewFileService(cfg *config.AppConfig, pythonClient *clients.PythonSplitterClient) FileService {
	return &fileService{
		cfg:                cfg,
		pythonSplitterClient: pythonClient,
	}
}

// UploadFile handles saving the uploaded file to the designated directory.
func (s *fileService) UploadFile(file *multipart.FileHeader) (*models.UploadResponse, error) {
	if !utils.IsAllowedFileType(file.Filename) {
		return nil, fmt.Errorf("file type not allowed: %s", filepath.Ext(file.Filename))
	}

	savedPath, err := utils.SaveUploadedFile(file, s.cfg.UploadDir)
	if err != nil {
		return nil, fmt.Errorf("failed to save uploaded file: %w", err)
	}

	return &models.UploadResponse{
		Message:  "File uploaded successfully",
		FilePath: savedPath,
		FileName: file.Filename,
	}, nil
}

// InitiateSplit sends a request to the Python splitter service to split a file.
func (s *fileService) InitiateSplit(req models.SplitRequest) ([]models.SplitPart, error) {
	// Construct the path to the file in the upload directory
	uploadedFilePath := filepath.Join(s.cfg.UploadDir, req.Filename)

	// Ensure the file exists before attempting to split
	if _, err := ioutil.ReadFile(uploadedFilePath); err != nil {
		return nil, fmt.Errorf("uploaded file not found or accessible: %s", req.Filename)
	}

	pythonReq := models.PythonSplitRequest{
		Filename:   req.Filename, // Pass only the filename, Python service will read from shared volume
		ChunkSize:  req.ChunkSize,
		SmartSplit: req.SmartSplit,
	}

	// Call the Python splitter service
	splitParts, err := s.pythonSplitterClient.CallSplitService(pythonReq)
	if err != nil {
		return nil, fmt.Errorf("failed to call Python splitter service: %w", err)
	}

	// For each split part, construct the full downloadable URL
	for i := range splitParts {
		// Assuming Python returns just the filename of the split part
		// We need to prepend the base URL for the static splits directory
		splitParts[i].URL = fmt.Sprintf("http://localhost:%s/static/splits/%s", s.cfg.Port, splitParts[i].Filename)
	}

	return splitParts, nil
}

// ListSplitFiles lists all files in the splits directory.
func (s *fileService) ListSplitFiles() ([]models.SplitPart, error) {
	files, err := ioutil.ReadDir(s.cfg.SplitDir)
	if err != nil {
		if os.IsNotExist(err) {
            log.Printf("Split directory %s does not exist, returning empty list.", s.cfg.SplitDir)
            return []models.SplitPart{}, nil // Return empty list if directory doesn't exist
        }
		return nil, fmt.Errorf("failed to read split directory: %w", err)
	}

	var splitParts []models.SplitPart
	for _, file := range files {
		if !file.IsDir() && !strings.HasPrefix(file.Name(), ".") { // Exclude directories and hidden files
			// Construct the full downloadable URL for each file
			fileURL := fmt.Sprintf("http://localhost:%s/static/splits/%s", s.cfg.Port, file.Name())
			splitParts = append(splitParts, models.SplitPart{
				Filename: file.Name(),
				URL:      fileURL,
			})
		}
	}
	return splitParts, nil
}
