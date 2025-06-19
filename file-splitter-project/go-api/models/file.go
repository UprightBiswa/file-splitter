package models

// UploadResponse represents the response after a file upload.
// This is returned by the Go backend's POST /upload endpoint to the Flutter frontend.
type UploadResponse struct {
	Message  string `json:"message"`
	FilePath string `json:"filePath"` // Path where the file was saved on the Go backend's server
	FileName string `json:"fileName"` // Original file name
}

// SplitRequest represents the incoming JSON payload for the Go backend's POST /split endpoint
// received from the Flutter frontend (if the frontend directly calls /split).
// Alternatively, it's the structure the Go backend's FileService uses to define a split job.
type SplitRequest struct {
	Filename   string `json:"filename" binding:"required"`
	ChunkSize  int    `json:"chunk_size" binding:"required"`
	SmartSplit bool   `json:"smart_split"`
}

// PythonSplitRequest represents the JSON payload sent by the Go backend to the Python splitter service's /split endpoint.
// This mirrors the SplitRequest but is explicitly for the Python communication.
type PythonSplitRequest struct {
	Filename   string `json:"filename"`
	ChunkSize  int    `json:"chunk_size"`
	SmartSplit bool   `json:"smart_split"`
}

// SplitPart represents a single split file part.
// This struct is used in both the PythonSplitResponse and as individual elements
// returned by the Go backend's GET /splits endpoint to the Flutter frontend.
// It directly matches the Flutter frontend's SplitResultModel.
type SplitPart struct {
	Filename string `json:"filename"` // Name of the generated split file (e.g., "original_part1.txt")
	URL      string `json:"url"`      // Full URL to download the split part (e.g., "http://localhost:8080/static/splits/original_part1.txt")
}

// PythonSplitResponse represents the expected JSON response from the Python splitter service.
// The Go backend receives this structure from the Python service.
type PythonSplitResponse struct {
	Parts []SplitPart `json:"parts"`
}

// FileListResponse is an optional wrapper for listing files.
// In this specific implementation, the Go backend's GET /splits endpoint
// directly returns an array of SplitPart (i.e., `[]SplitPart`) to match Flutter's
// expectation of `List<SplitResultModel>` directly from `response.data`.
// While defined, this struct is not used as the top-level return type for GET /splits.
type FileListResponse struct {
	Files []SplitPart `json:"files"`
}
