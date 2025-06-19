package clients

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"

	"go-api/config"
	"go-api/models"
)

// PythonSplitterClient provides methods to interact with the Python splitter service.
type PythonSplitterClient struct {
	baseURL    string
	httpClient *http.Client
}

// NewPythonSplitterClient creates and returns a new PythonSplitterClient instance.
func NewPythonSplitterClient() *PythonSplitterClient {
	cfg := config.GetConfig()
	return &PythonSplitterClient{
		baseURL: cfg.PythonServiceURL,
		httpClient: &http.Client{
			Timeout: 60 * time.Second, // Increased timeout for potentially long splitting operations
		},
	}
}

// CallSplitService sends a POST request to the Python splitter service's /split endpoint.
func (c *PythonSplitterClient) CallSplitService(request models.PythonSplitRequest) ([]models.SplitPart, error) {
	url := fmt.Sprintf("%s/split", c.baseURL)
	log.Printf("Calling Python splitter service at: %s with request: %+v", url, request)

	// Marshal the request payload to JSON
	payloadBytes, err := json.Marshal(request)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal PythonSplitRequest: %w", err)
	}

	// Create a new HTTP POST request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(payloadBytes))
	if err != nil {
		return nil, fmt.Errorf("failed to create HTTP request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	// Send the request
	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request to Python service: %w", err)
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body from Python service: %w", err)
	}

	// Check if the response status code indicates an error
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Python service returned non-200 status code %d: %s", resp.StatusCode, string(body))
	}

	// Unmarshal the response body into PythonSplitResponse
	var pythonResponse models.PythonSplitResponse
	if err := json.Unmarshal(body, &pythonResponse); err != nil {
		return nil, fmt.Errorf("failed to unmarshal Python service response: %w", err)
	}

	log.Printf("Received response from Python service: %+v", pythonResponse)
	return pythonResponse.Parts, nil
}
