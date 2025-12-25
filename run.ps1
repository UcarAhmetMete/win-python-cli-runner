<#
.SYNOPSIS
  Run the Python CLI with an idempotent virtual environment and optional logging.

.DESCRIPTION
  Creates (or re-uses) a local `.venv`, optionally installs `requirements.txt`,
  runs `app.py` with `-Name` and `-Out`, and supports logging via `-LogPath`.

.PARAMETER Name
  Name to include in the greeting written by `app.py`.

.PARAMETER Out
  Output directory where `result.json` will be written.

.PARAMETER LogPath
  Optional path to write a transcript/log of the session.

.PARAMETER ForceRecreateVenv
  If specified, removes any existing `.venv` before creating a new one.

.PARAMETER SkipInstall
  If specified, do not run `pip install -r requirements.txt`.

.EXAMPLE
  .\run.ps1 -Name "Veldhoven" -Out out -LogPath .\run.log -Verbose
#>

[CmdletBinding()]
param(
  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$Name = "ASML",

  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$Out = "out",

  [Parameter()]
  [string]$LogPath,

  [switch]$ForceRecreateVenv,

  [switch]$SkipInstall
)

begin {
  if ($PSBoundParameters.ContainsKey('LogPath')) {
    Try {
      Start-Transcript -Path $LogPath -Force -ErrorAction Stop
      Write-Verbose "Started transcript: $LogPath"
    } Catch {
      Write-Warning "Could not start transcript: $_"
    }
  }
}

try {
  Write-Verbose "Locating Python executable..."
  $pythonCmd = $null
  $pyCmd = (Get-Command python -ErrorAction SilentlyContinue)
  if ($pyCmd) { $pythonCmd = $pyCmd.Source; $pythonArgs = "" }
  else {
    $py3 = (Get-Command py -ErrorAction SilentlyContinue)
    if ($py3) { $pythonCmd = $py3.Source; $pythonArgs = "-3" }
  }

  if (-not $pythonCmd) {
    throw "Python executable not found. Ensure Python is installed and in PATH."
  }

  $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
  if (-not $scriptRoot) { $scriptRoot = Get-Location }
  Push-Location $scriptRoot

  $venvPath = Join-Path $scriptRoot '.venv'
  if (Test-Path $venvPath) {
    if ($ForceRecreateVenv) {
      Write-Verbose "Removing existing .venv because -ForceRecreateVenv was set"
      Remove-Item -Recurse -Force $venvPath
    } else {
      Write-Verbose "Re-using existing .venv"
    }
  }

  if (-not (Test-Path $venvPath)) {
    Write-Verbose "Creating virtual environment at $venvPath"
    if ($pythonArgs) { & $pythonCmd $pythonArgs -m venv $venvPath } else { & $pythonCmd -m venv $venvPath }
  }

  $activate = Join-Path $venvPath 'Scripts\Activate.ps1'
  if (-not (Test-Path $activate)) { throw "Activation script not found at $activate" }
  . $activate

  if (-not $SkipInstall) {
    if (Test-Path (Join-Path $scriptRoot 'requirements.txt')) {
      Write-Verbose "Installing from requirements.txt"
      pip install -r requirements.txt
    } else {
      Write-Verbose "No requirements.txt found; skipping install"
      Write-Host "No requirements.txt; skipping pip install"
    }
  } else {
    Write-Verbose "Skipping pip install because -SkipInstall was set"
  }

  Write-Verbose "Running app.py"
  python app.py --name $Name --out $Out
  Write-Host "Done."
  Pop-Location
  if ($PSBoundParameters.ContainsKey('LogPath')) { Stop-Transcript }
  exit 0
}
catch {
  Write-Error "Error: $_"
  try { Pop-Location } catch {}
  if ($PSBoundParameters.ContainsKey('LogPath')) { Stop-Transcript }
  exit 1
}

