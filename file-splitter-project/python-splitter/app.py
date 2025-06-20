import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os

from core.logger import logger
from core.config import settings
from splitter.schemas import SplitRequest, SplitResponse
from splitter.file_service import FileService

# Initialize logger early
logger.info("Starting FastAPI application setup.")
logger.info("Uploads directory: %s", settings.UPLOAD_DIR)
logger.info("Splits directory: %s", settings.SPLIT_DIR)
# Initialize the FileService
file_service = FileService()

app = FastAPI(
    title="Python File Splitter Microservice",
    description="Microservice to split files (txt, docx) based on size or smart logic, serving as a backend for a Go gateway.",
    version="1.0.0",
)

# CORS Middleware for allowing communication from the Go API/Flutter Frontend
# In a production environment, replace "*" with specific origins (e.g., ["http://localhost:8080", "http://localhost:XXXX"])
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows all origins for development.
                         # Change this to specific domains in production, e.g., ["http://localhost:8080"]
    allow_credentials=True,
    allow_methods=["*"], # Allows all methods (POST, GET, etc.)
    allow_headers=["*"], # Allows all headers
)

@app.on_event("startup")
async def startup_event():
    """Event handler for application startup."""
    logger.info("FastAPI application startup completed.")
    logger.info(f"Uploads directory: {settings.UPLOAD_DIR}")
    logger.info(f"Splits directory: {settings.SPLIT_DIR}")
    # Ensure directories exist upon startup as well
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    os.makedirs(settings.SPLIT_DIR, exist_ok=True)


@app.get("/status", summary="Health check endpoint")
async def check_status():
    """
    Health check endpoint to verify the microservice is running.
    """
    logger.info("Status check requested.")
    return {"status": "ok", "service": "Python File Splitter"}

@app.post("/split", response_model=SplitResponse, summary="Initiate file splitting")
async def split_file_endpoint(request: SplitRequest):
    """
    Receives a file splitting request from the Go backend.
    Reads the specified file from the shared uploads directory,
    splits it according to chunk size and smart split options,
    and saves the parts to the shared splits directory.
    Returns the filenames of the generated parts.
    """
    logger.info(f"Received split request for filename: {request.filename}, "
                f"chunk_size: {request.chunk_size}MB, smart_split: {request.smart_split}")
    
    try:
        response = await file_service.split_file(request)
        logger.info(f"Successfully split {request.filename} into {response.total} parts.")
        return response
    except FileNotFoundError as e:
        logger.error(f"File not found: {e}")
        raise HTTPException(status_code=404, detail=str(e))
    except ValueError as e:
        logger.error(f"Invalid input or unsupported file type: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.exception(f"An unexpected error occurred during splitting: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")

if __name__ == "__main__":
    # This block allows you to run the application directly using 'python app.py'
    # For production, it's recommended to use 'uvicorn app:app' directly.
    logger.info(f"Starting Uvicorn server at http://{settings.API_HOST}:{settings.API_PORT}")
    uvicorn.run(
        "app:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=True,  # Auto-reload for development
        log_level="info",
    )
