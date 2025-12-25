# Windows Python CLI Runner

Minimal example showing **Python + Windows PowerShell scripting** to run a repeatable workflow.

## Run (Windows PowerShell)
```powershell
.\run.ps1 -Name "Veldhoven" -Out out
```

## Run (Unix / Linux / macOS)
```bash
./run.sh "Veldhoven" out
```

Notes:
- `run.ps1` now skips `pip install` if there is no `requirements.txt` file.
- `run.sh` is a simple cross-platform runner for Unix-like systems that creates a virtualenv, activates it, installs dependencies if `requirements.txt` exists, and runs `app.py`.

Files added/updated:
- `run.sh`: Unix-like shell runner
- `requirements.txt`: placeholder for Python dependencies
- `run.ps1`: updated to skip pip install when `requirements.txt` is missing
# Windows Python CLI Runner

Minimal example showing **Python + Windows PowerShell scripting** to run a repeatable workflow.

## Run (Windows PowerShell)
```powershell
.\run.ps1 -Name "Veldhoven" -Out out
