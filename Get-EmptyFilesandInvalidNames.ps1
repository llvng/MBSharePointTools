# Use this script to find empty files and those with invalid names

$datestring = (get-date -Format "dd-MM-yy_hhmm").toString()

# Prompt the user to enter the path they wish to scan
$location = Read-Host "Enter the local file path that you wish to scan, i.e. C:\Files"

# Change directory to that location
Write-Host "Changing directory to $($location)`n" -ForegroundColor Yellow
Set-Location $location

# Find files that are empty
Write-Host "Finding empty files in $($location)..." -ForegroundColor Yellow
$empty_files = Get-ChildItem $location -Recurse -Force | Where-Object {$_.Length -eq 0}
if($empty_files.Count -gt 0){
    Write-Host "Found $($empty_files.Count) empty files"
    # Make a backup of the file names and then change them
    Write-Host "Making a backup of empty files"
    New-Item -Path . -Name "EmptyFiles_$($datestring).txt" -ItemType "file"
    foreach ($file in $empty_files){
        Add-Content -Path "EmptyFiles_$($datestring).txt" -Value $file.FullName
    }
    # Set the contents of the empty files to the title
    Write-Host "Setting contents of files to their title"
    foreach ($file in $empty_files){
        Set-Content -Path $file.FullName -Value $file.Name
    }
}else{
    Write-Host "No empty files found!" -ForegroundColor Green
}

# Find files beginning with a Tilda (most common)
Write-Host "Finding invalid file names in $($location)..." -ForegroundColor Yellow
$invalid_filenames = Get-ChildItem $location -Recurse -Force | Where-Object {$_.Name -like "~*"}

if($invalid_filenames.Count -gt 0){
    Write-Host "Found $($invalid_filenames.Count) files with invalid names"

    # Make a backup of the invalid file names
    Write-Host "Making a backup of invalid files"
    New-Item -Path . -Name "InvalidFiles_$($datestring).txt" -ItemType "file"
    foreach ($file in $invalid_filenames){
        Add-Content -Path "InvalidFiles_$($datestring).txt" -Value $file.FullName
    }
    
    # Delete the invalid file names - they are likely to be temporary files that were never closed anyway
    Write-Host "Deleting files with invalid filenames"
    foreach ($file in $invalid_filenames){
        Remove-Item -Path $file.FullName -Force
    }
}else{
    Write-Host "No invalid filenames found!" -ForegroundColor Green
}
