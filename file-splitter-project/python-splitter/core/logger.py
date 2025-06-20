import logging
import sys

def setup_logging():
    """Configures centralized logging for the application."""
    log_format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    logging.basicConfig(
        level=logging.INFO, # Default logging level
        format=log_format,
        handlers=[
            logging.StreamHandler(sys.stdout) # Log to console
            # You could add FileHandler here for logging to a file in production
            # logging.FileHandler("app.log")
        ]
    )
    # Set log level for uvicorn access logs separately if needed
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.error").setLevel(logging.INFO)

    # Return the root logger
    return logging.getLogger(__name__)

# Initialize logger for use throughout the application
logger = setup_logging()
