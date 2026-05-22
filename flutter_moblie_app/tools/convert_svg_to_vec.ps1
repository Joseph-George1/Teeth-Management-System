Shell script to convert SVG files to Flutter Vector Graphics (.vec) format

# Path to the directory containing SVG files
$svgDir = "$PSScriptRoot/../assets/vector_graphics"

# Create output directory if it doesn't exist
$outputDir = "$svgDir"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Get all SVG files in the directory
$svgFiles = Get-ChildItem -Path $svgDir -Filter "*.svg"

foreach ($svgFile in $svgFiles) {
    $inputPath = $svgFile.FullName
    $outputPath = Join-Path $outputDir "$($svgFile.BaseName).svg.vec"
    
    Write-Host "Converting $($svgFile.Name) to $($svgFile.Name).vec..."
    
    # Run the vector_graphics_compiler
    flutter pub run vector_graphics_compiler --source $inputPath --output $outputPath
}

Write-Host "Conversion complete!"
