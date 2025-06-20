import os

class Settings:
    # Define directories relative to where the application is run,
    # assuming `static` is in the project root.
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    STATIC_DIR = os.path.join(BASE_DIR, "static")
    UPLOAD_DIR = os.path.join(STATIC_DIR, "uploads")
    SPLIT_DIR = os.path.join(STATIC_DIR, "splits")

    # Ensure directories exist
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    os.makedirs(SPLIT_DIR, exist_ok=True)

    # API Host and Port
    API_HOST: str = os.getenv("API_HOST", "0.0.0.0")
    API_PORT: int = int(os.getenv("API_PORT", 8000))

    # Splitting parameters (defaults, can be overridden by request)
    DEFAULT_CHUNK_SIZE_MB: int = int(os.getenv("DEFAULT_CHUNK_SIZE_MB", 2)) # 2 MB default
    MAX_FILE_SIZE_MB: int = int(os.getenv("MAX_FILE_SIZE_MB", 100)) # Max file size to prevent OOM
    ALLOWED_EXTENSIONS: list[str] = [".txt", ".doc", ".docx"] # Consistent with Go backend

    @classmethod
    def get_upload_path(cls, filename: str) -> str:
        return os.path.join(cls.UPLOAD_DIR, filename)

    @classmethod
    def get_split_path(cls, filename: str) -> str:
        return os.path.join(cls.SPLIT_DIR, filename)

# Instantiate settings
settings = Settings()
