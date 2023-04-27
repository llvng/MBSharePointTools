$folders = Get-PnpFolderItem -FolderSiteRelativeUrl "Clients/Old"

$d1 = Get-Date
foreach ($f in $folders){
	$folder = $f.Name
	try{
		$job = Move-PnPFile -SourceUrl "/sites/migration/Clients/Old/$($folder)" -TargetUrl "/sites/company/Clients%20 Inactive" -NoWait -Force
	}
	catch{
		Write-Host "An error occurred:" -ForegroundColor Red
		Write-Host $_.Exception.Message
	}
	# $d1 = Get-Date
	$jobStatus = Receive-PnPCopyMoveJobStatus -Job $job
	while($jobStatus.JobState -eq 4){
		Write-Host "Getting job status for $($folder)..." -ForegroundColor Yellow
		$progress = ($jobstatus.Logs | ConvertFrom-Json) | ? {$_.Event -like "JobProgress"} | Select -Last 1
		Write-Host "Processed $($progress.ObjectsProcessed) out of $($progress.TotalExpectedSPObjects)"
		if ($progress.TotalErrors -gt 0){Write-Host "Current Errors: $($progress.TotalErrors)" -ForegroundColor Red}
		if($progress.ObjectsProcessed -gt 0 -and $progress.TotalExpectedSPObjects -gt 0){
			$percent = [math]::Round((($progress.ObjectsProcessed / $progress.TotalExpectedSPObjects) * 100),2)
			Write-Host "$($percent)% completed"
		}
		$d2 = Get-Date
		$diff = $d2 - $d1
		Write-Host "Time Elapsed [hh:mm:ss:ms]:  $diff"
		Start-Sleep 5
		$jobStatus = Receive-PnPCopyMoveJobStatus -Job $job
	}
}

