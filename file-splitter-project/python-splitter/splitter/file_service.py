import os
from typing import List, Tuple
from core.config import settings
from core.logger import logger
from splitter.schemas import SplitRequest, SplitPart, SplitResponse
from splitter.text_splitter import TextSplitter
import asyncio
import aiofiles # For asynchronous file operations
from docx import Document # For .docx specific handling
import magic # You'll need to install python-magic for MIME type detection: pip install python-magic

class FileService:
    def __init__(self):
        # Ensure static directories exist as per config
        os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
        os.makedirs(settings.SPLIT_DIR, exist_ok=True)
        logger.info(f"FileService initialized. Uploads: {settings.UPLOAD_DIR}, Splits: {settings.SPLIT_DIR}")

    async def _read_file_content(self, file_path: str) -> Tuple[str, str]:
        """Reads file content and determines its type."""
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")

        # Determine file type using python-magic for robustness
        mime = magic.Magic(mime=True)
        file_mime_type = mime.from_file(file_path)
        logger.info(f"Detected MIME type for {file_path}: {file_mime_type}")

        if 'text/plain' in file_mime_type or file_path.lower().endswith(".txt"):
            async with aiofiles.open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = await f.read()
            return content, '.txt'
        elif 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' in file_mime_type or file_path.lower().endswith((".doc", ".docx")):
            # python-docx doesn't support async, so perform synchronously
            document = Document(file_path)
            full_text = []
            for para in document.paragraphs:
                full_text.append(para.text)
            return "\n\n".join(full_text), '.docx'
        else:
            raise ValueError(f"Unsupported file type: {file_mime_type} for {file_path}. Only .txt and .docx are supported for splitting content.")

    async def _write_chunk_to_file(self, content: str, original_filename: str, part_num: int, ext: str) -> SplitPart:
        """Writes a single content chunk to a file in the splits directory."""
        base_name = os.path.splitext(original_filename)[0]
        split_filename = f"{base_name}_part{part_num}{ext}"
        split_file_path = os.path.join(settings.SPLIT_DIR, split_filename)

        async with aiofiles.open(split_file_path, 'w', encoding='utf-8') as f:
            await f.write(content)
        
        logger.info(f"Saved split part: {split_file_path}")
        return SplitPart(filename=split_filename)

    async def split_file(self, request: SplitRequest) -> SplitResponse:
        """
        Main function to handle file splitting.
        Reads the file, splits it using TextSplitter, and writes parts.
        """
        file_path = settings.get_upload_path(request.filename)
        logger.info(f"Processing split request for: {file_path}")

        if not os.path.exists(file_path):
            logger.error(f"File not found for splitting: {file_path}")
            raise FileNotFoundError(f"File not found: {request.filename}")

        # Read content and determine file type
        content, detected_ext = await self._read_file_content(file_path)
        
        # Convert chunk_size from MB (from Go) to bytes
        chunk_size_bytes = request.chunk_size * 1024 * 1024
        
        splitter = TextSplitter(chunk_size_bytes=chunk_size_bytes)
        
        # Split the content
        split_contents = splitter.split_text_content(content, request.smart_split)
        
        generated_parts: List[SplitPart] = []
        for i, chunk_content in enumerate(split_contents):
            part = await self._write_chunk_to_file(chunk_content, request.filename, i + 1, detected_ext)
            generated_parts.append(part)

        logger.info(f"File {request.filename} split into {len(generated_parts)} parts.")
        return SplitResponse(parts=generated_parts, total=len(generated_parts))

