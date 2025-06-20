import os
import re
from typing import List, Tuple
from docx import Document
from io import StringIO
from core.logger import logger

class TextSplitter:
    def __init__(self, chunk_size_bytes: int):
        self.chunk_size_bytes = chunk_size_bytes

    def _split_by_paragraphs(self, text: str) -> List[str]:
        """Splits text by double newlines, typically indicating paragraphs."""
        return [p.strip() for p in text.split('\n\n') if p.strip()]

    def _split_by_sentences(self, text: str) -> List[str]:
        """Splits text by common sentence terminators, attempting to preserve integrity."""
        # This regex attempts to split by .!? followed by whitespace or end of string.
        # It's a basic approach; more advanced NLP libraries might be needed for perfect sentence segmentation.
        sentences = re.split(r'(?<=[.!?])\s+|\n', text)
        return [s.strip() for s in sentences if s.strip()]

    def _get_bytes(self, text: str) -> bytes:
        """Helper to get bytes of text using UTF-8 encoding."""
        return text.encode('utf-8')

    def split_text_content(self, content: str, smart_split: bool) -> List[str]:
        """
        Splits a string content into chunks based on size and smart_split flag.
        Returns a list of content strings, each representing a chunk.
        """
        chunks: List[str] = []
        current_chunk_buffer = StringIO()
        current_chunk_size = 0

        if smart_split:
            logger.info("Performing smart splitting (paragraphs/sentences).")
            # Prioritize paragraph splitting, then sentences within large paragraphs
            segments = self._split_by_paragraphs(content)
            if not segments: # Fallback if paragraph splitting yields nothing (e.g. single long line)
                 segments = self._split_by_sentences(content)

            for segment in segments:
                segment_bytes = len(self._get_bytes(segment + "\n\n")) # Add delimiter back for size estimation
                
                # If adding this segment exceeds chunk size, save current buffer and start new
                if current_chunk_size + segment_bytes > self.chunk_size_bytes and current_chunk_size > 0:
                    chunks.append(current_chunk_buffer.getvalue().strip())
                    current_chunk_buffer = StringIO()
                    current_chunk_size = 0
                
                # If a single segment is larger than chunk_size, split it further (e.g., by words or raw)
                if segment_bytes > self.chunk_size_bytes:
                    logger.warning(f"Segment larger than chunk size: {segment_bytes} bytes. Falling back to simple split for this segment.")
                    # For a too-large segment, do a raw split
                    sub_chunks = self._raw_split_text(segment, self.chunk_size_bytes)
                    for sc in sub_chunks:
                        chunks.append(sc.strip())
                else:
                    current_chunk_buffer.write(segment + "\n\n") # Re-add delimiter
                    current_chunk_size += segment_bytes
            
            # Add any remaining content in the buffer
            if current_chunk_buffer.getvalue().strip():
                chunks.append(current_chunk_buffer.getvalue().strip())

        else:
            logger.info("Performing raw byte-based splitting.")
            chunks = self._raw_split_text(content, self.chunk_size_bytes)
        
        logger.info(f"Generated {len(chunks)} text chunks.")
        return chunks

    def _raw_split_text(self, content: str, chunk_size_bytes: int) -> List[str]:
        """
        Performs raw byte-based slicing of text content.
        Attempts to avoid breaking multi-byte UTF-8 characters.
        """
        chunks: List[str] = []
        content_bytes = self._get_bytes(content)
        total_bytes = len(content_bytes)
        
        current_byte_pos = 0
        while current_byte_pos < total_bytes:
            end_byte_pos = min(current_byte_pos + chunk_size_bytes, total_bytes)
            
            # Adjust end_byte_pos to not break multi-byte UTF-8 characters
            # Move back until we are at the start of a UTF-8 character
            while end_byte_pos > current_byte_pos and (content_bytes[end_byte_pos] & 0xC0) == 0x80:
                end_byte_pos -= 1
            
            # If after adjusting, end_byte_pos is same as current_byte_pos, and there's still content,
            # it means a single character is larger than chunk_size_bytes. Force a cut.
            if end_byte_pos == current_byte_pos and total_bytes > current_byte_pos:
                end_byte_pos = min(current_byte_pos + chunk_size_bytes, total_bytes) # Force cut
            
            chunk_bytes = content_bytes[current_byte_pos:end_byte_pos]
            chunks.append(chunk_bytes.decode('utf-8', errors='ignore'))
            current_byte_pos = end_byte_pos
            
        return chunks

    def extract_text_from_docx(self, docx_path: str) -> str:
        """Extracts all text from a .docx file."""
        try:
            document = Document(docx_path)
            full_text = []
            for paragraph in document.paragraphs:
                full_text.append(paragraph.text)
            return "\n\n".join(full_text) # Use double newline for paragraph separation
        except Exception as e:
            logger.error(f"Error extracting text from DOCX {docx_path}: {e}")
            raise ValueError(f"Could not read DOCX file: {e}")

