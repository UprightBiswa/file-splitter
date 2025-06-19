package utils

import (
	"io"
	"log"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"

	"go-api/config" // Import the config package
)

// IsAllowedFileType checks if the file extension is among the allowed types.
func IsAllowedFileType(filename string) bool {
	ext := strings.ToLower(filepath.Ext(filename))
	cfg := config.GetConfig() // Get the loaded configuration

	for _, allowed := range cfg.AllowedTypes {
		if ext == allowed {
			return true
		}
	}
	log.Printf("File type %s not allowed.", ext)
	return false
}

// SaveUploadedFile saves a multipart file to the specified directory.
// It returns the full path to the saved file or an error.
func SaveUploadedFile(file *multipart.FileHeader, destDir string) (string, error) {
	// Ensure the destination directory exists
	err := CreateDirIfNotExist(destDir)
	if err != nil {
		return "", err
	}

	dst := filepath.Join(destDir, file.Filename)
	// Open the uploaded file
	src, err := file.Open()
	if err != nil {
		return "", err
	}
	defer src.Close()

	// Create the destination file
	out, err := os.Create(dst) // Using os.Create directly
	if err != nil {
		return "", err
	}
	defer out.Close()

	// Copy the file content
	_, err = io.Copy(out, src) // Using io.Copy directly
	if err != nil {
		return "", err
	}

	log.Printf("File saved successfully to: %s", dst)
	return dst, nil
}

// CreateDirIfNotExist creates a directory if it does not already exist.
func CreateDirIfNotExist(dir string) error {
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		log.Printf("Creating directory: %s", dir)
		return os.MkdirAll(dir, 0755) // 0755 permissions: rwx for owner, rx for group/others
	}
	return nil
}

// GetFileExtension returns the extension of a filename.
func GetFileExtension(filename string) string {
	return strings.ToLower(filepath.Ext(filename))
}

// GetBaseFilename returns the filename without its extension.
func GetBaseFilename(filename string) string {
	return strings.TrimSuffix(filename, filepath.Ext(filename))
}
