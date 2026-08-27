from pathlib import Path

from pypdf import PdfReader


ROOT = Path(__file__).resolve().parent


for pdf_path in sorted(ROOT.glob("*.pdf")):
    reader = PdfReader(pdf_path)
    text_path = pdf_path.with_suffix(".txt")
    with text_path.open("w", encoding="utf-8", newline="\n") as output:
        for page_number, page in enumerate(reader.pages, start=1):
            output.write(f"\n\n===== PDF PAGE {page_number} =====\n\n")
            output.write(page.extract_text() or "")
    print(f"{pdf_path.name}\t{len(reader.pages)}\t{text_path.stat().st_size}")
