@echo off
setlocal enabledelayedexpansion

:: === CONFIGURATION ===
set "InputFile=FTFHAPort.data.unityweb"    :: Change this to your file name
set "PartSizeMB=19.9"          :: Desired size in MB

:: === CALCULATIONS ===
for /f "tokens=1,2 delims=." %%a in ("%PartSizeMB%") do (
    set /a "PartSizeBytes=%%a*1024*1024"
    set "Fraction=%%b"
)
if defined Fraction (
    set /a "FractionBytes=(%Fraction%*1024*1024)/10"
    set /a "PartSizeBytes+=FractionBytes"
)

echo Splitting "%InputFile%" into %PartSizeMB% MB chunks...
set /a "chunkSize=%PartSizeBytes%"

:: === RUN POWERSHELL TO SPLIT ===
powershell -Command ^
    "$infile='%InputFile%';" ^
    "$chunk=%chunkSize%;" ^
    "$fs=[IO.File]::OpenRead($infile);" ^
    "$buffer=New-Object byte[] $chunk;" ^
    "$part=1;" ^
    "while(($read=$fs.Read($buffer,0,$buffer.Length)) -gt 0){" ^
    "  $outfile=('{0}.part{1}' -f $infile,$part);" ^
    "  $fsOut=[IO.File]::OpenWrite($outfile);" ^
    "  $fsOut.Write($buffer,0,$read);" ^
    "  $fsOut.Close();" ^
    "  Write-Host 'Wrote' $outfile;" ^
    "  $part++" ^
    "};" ^
    "$fs.Close()"

echo Done!
pause
