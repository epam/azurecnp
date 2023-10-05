function Format-Text {
    param (
        [string]$dir,
        [string]$input_string,
        [string]$output_string,
        [array]$fileMask
    )
    Write-Host "Replace content in the files $($fileMask) in the directory $($dir):"
    $files = Get-ChildItem -Path "$dir\/*" -Recurse -Force -Include $fileMask
    foreach ($file in $files) {
      $content = [System.IO.File]::ReadAllText($file.FullName) -replace "$input_string","$output_string"
      [System.IO.File]::WriteAllText($file.FullName, $content)
      Write-Host "Processing $file ..."
    }
}