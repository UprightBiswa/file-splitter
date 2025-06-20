from pydantic import BaseModel
from typing import List

# Request model from Go backend for splitting a file
class SplitRequest(BaseModel):
    filename: str          # Name of the file to split, assumed to be in UPLOAD_DIR
    chunk_size: int        # Desired chunk size in bytes (as MB from Go, converted in service)
    smart_split: bool = False # Whether to attempt smart splitting (e.g., by paragraphs)

# Model for a single split file part in the response
# This matches the Go backend's models.SplitPart (only filename needed here)
class SplitPart(BaseModel):
    filename: str          # Name of the generated split file (e.g., "original_part1.txt")

# Response model back to Go backend
class SplitResponse(BaseModel):
    parts: List[SplitPart] # List of split file parts
    total: int             # Total number of parts generated
