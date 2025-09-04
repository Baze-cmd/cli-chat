from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, PlainTextResponse
from pathlib import Path
import os
import re

app = FastAPI(title="Stateless LLM CLI Dispenser", version="1.0.0")

SCRIPT_PATH = Path(__file__).parent / "bash_script.sh"
MESSAGING_SCRIPT_PATH = Path(__file__).parent / "messaging.sh"

@app.get("/", response_class=PlainTextResponse)
def root_script():
    if not SCRIPT_PATH.exists():
        raise HTTPException(status_code=500, detail="bash_script.sh not found.")
    
    api_key = os.getenv("OPENROUTER_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="OPENROUTER_API_KEY not set in environment.")
    
    script_text = SCRIPT_PATH.read_text()

    # Replace $OPENROUTER_API_KEY with the actual key
    script_text = re.sub(r"\$OPENROUTER_API_KEY\b", api_key, script_text)

    return PlainTextResponse(script_text, media_type="text/plain; charset=utf-8")

@app.get("/file")
def get_file():
    p = Path(__file__).parent / "file"
    if not p.exists() or not p.is_file():
        raise HTTPException(status_code=404, detail="File named 'file' not found next to the app.")
    return FileResponse(path=str(p), media_type="application/octet-stream", filename="file")

@app.get("/messaging", response_class=FileResponse)
def get_messaging_script():
    if not MESSAGING_SCRIPT_PATH.exists() or not MESSAGING_SCRIPT_PATH.is_file():
        raise HTTPException(status_code=404, detail="messaging.sh not found.")
    return FileResponse(
        path=str(MESSAGING_SCRIPT_PATH),
        media_type="application/x-sh",
        filename="messaging.sh"
    )

@app.get("/info", response_class=PlainTextResponse)
def messaging_text():
    return "mkdir -p ~/bin cd ~/bin wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 chmod +x ~/bin/jq export PATH=\"$HOME/bin:$PATH\""

