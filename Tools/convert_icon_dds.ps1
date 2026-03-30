# Run with: powershell -ExecutionPolicy Bypass -File Tools/convert_icon_dds.ps1 -InputPath <path> [-BaseName <name>] [-Sizes 400x400,380x380,152x152]
param(
    [Parameter(Mandatory=$true)]
    [Alias("Input")]
    [string]$InputPath,

    [string]$OutDir = "RagnarokOnlineMod/Icons/dds",
    [string]$BaseName = "icon",
    [string[]]$Sizes = @("400x400", "380x380", "152x152"),
    [string]$PixelFormat = "DXT5"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($InputPath)) {
    throw "InputPath is empty."
}
if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "Input file not found: $InputPath"
}

$tool = "Tools/png_to_dds.py"
if (-not (Test-Path -LiteralPath $tool)) {
    throw "Converter not found: $tool"
}

$py = $null
if (Get-Command py -ErrorAction SilentlyContinue) {
    $py = "py"
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $py = "python"
} else {
    throw "Python launcher not found. Install Python and Pillow: pip install pillow"
}

$pyArgs = @(
    $tool,
    "convert",
    "--input", $InputPath,
    "--out-dir", $OutDir,
    "--basename", $BaseName,
    "--pixel-format", $PixelFormat,
    "--sizes"
) + $Sizes

Write-Host "Running: $py $($pyArgs -join ' ')"
& $py @pyArgs
if ($LASTEXITCODE -ne 0) {
    throw "Conversion failed with exit code $LASTEXITCODE"
}

Write-Host "Done. Generated DDS files in: $OutDir"
