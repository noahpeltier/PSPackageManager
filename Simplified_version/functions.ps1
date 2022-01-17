function Get-FileWCAsynchronous {
    param(
        [Parameter(Mandatory = $true)]
        $url, 
        $destinationFolder = "$env:USERPROFILE\Downloads", 
        [switch]$includeStats
    )
    $wc = New-Object Net.WebClient
    $wc.UseDefaultCredentials = $true
    $file = $url | Split-Path -Leaf
    $destination = Join-Path $destinationFolder $file
    $start = Get-Date
    $null = Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged `
        -MessageData @{start = $start; includeStats = $includeStats } `
        -SourceIdentifier WebClient.DownloadProgressChanged -Action { 
        filter Get-FileSize {
            "{0:N2} {1}" -f $(
                if ($_ -lt 1kb) { $_, 'Bytes' }
                elseif ($_ -lt 1mb) { ($_ / 1kb), 'KB' }
                elseif ($_ -lt 1gb) { ($_ / 1mb), 'MB' }
                elseif ($_ -lt 1tb) { ($_ / 1gb), 'GB' }
                elseif ($_ -lt 1pb) { ($_ / 1tb), 'TB' }
                else { ($_ / 1pb), 'PB' }
            )
        }
        $elapsed = ((Get-Date) - $event.MessageData.start)
        #calculate average speed in Mbps
        $averageSpeed = ($EventArgs.BytesReceived * 8 / 1MB) / $elapsed.TotalSeconds
        $elapsed = $elapsed.ToString('hh\:mm\:ss')
        #calculate remaining time considering average speed
        $remainingSeconds = ($EventArgs.TotalBytesToReceive - $EventArgs.BytesReceived) * 8 / 1MB / $averageSpeed
        $receivedSize = $EventArgs.BytesReceived | Get-FileSize
        $totalSize = $EventArgs.TotalBytesToReceive | Get-FileSize        
        Write-Progress -Activity (" $url {0:N2} Mbps" -f $averageSpeed) `
            -Status ("{0} of {1} ({2}% in {3})" -f $receivedSize, $totalSize, $EventArgs.ProgressPercentage, $elapsed) `
            -SecondsRemaining $remainingSeconds `
            -PercentComplete $EventArgs.ProgressPercentage
        if ($EventArgs.ProgressPercentage -eq 100) {
            Write-Progress -Activity (" $url {0:N2} Mbps" -f $averageSpeed) `
                -Status 'Done' -Completed
            if ($event.MessageData.includeStats.IsPresent) {
                    ([PSCustomObject]@{Name = 'Get-FileWCAsynchronous'; TotalSize = $totalSize; Time = $elapsed }) | Out-Host
            }
        }
    }    
    $null = Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted `
        -SourceIdentifier WebClient.DownloadFileCompleted -Action { 
        Unregister-Event -SourceIdentifier WebClient.DownloadProgressChanged
        Unregister-Event -SourceIdentifier WebClient.DownloadFileCompleted
        Get-Item $destination | Unblock-File
    }  
    try {  
        $wc.DownloadFileAsync($url, $destination)  
    }  
    catch [System.Net.WebException] {  
        Write-Warning "Download of $url failed"  
    }   
    finally {    
        $wc.Dispose()  
    }  
}

Find-Manifestentry

function Invoke-Download {
    param(
        $url,
        $destination
    )
    $wc = New-Object Net.WebClient
    $wc.UseDefaultCredentials = $true
    $file = $url | Split-Path -Leaf
    $destination = Join-Path $destination $file

    Get-EventSubscriber -SourceIdentifier WebClient.DownloadFileCompleted | Unregister-Event
    $Event = Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted `
        -SourceIdentifier WebClient.DownloadFileCompleted -Action {
        Write-Host "File download completed"
        #Get-Item $destination | Unblock-File
    }
    try {
        Write-host "Downloading $file" -ForegroundColor Green
        $wc.DownloadFileAsync($url, $destination)
        function spinner {
            Write-host "Please Wait    |`r" -NoNewline
            Start-Sleep -Milliseconds 50
            Write-host "Please Wait.   /`r" -NoNewline
            Start-Sleep -Milliseconds 50
            Write-host "Please Wait..  -`r" -NoNewline
            Start-Sleep -Milliseconds 50
            Write-host "Please Wait... \`r" -NoNewline
            Start-Sleep -Milliseconds 50
        }

        do { spinner } until(-not $wc.IsBusy)
    }
    catch [System.Net.WebException] {
        Write-Warning "Download of $url failed"
    }
    finally {
        $wc.Dispose()
    }
}
function Get-RemoteFileHash {
    param($URI)
    $wc = [System.Net.WebClient]::new()
    return Get-FileHash -InputStream ($wc.OpenRead($URI))
}

function confirm {
    param($message)
    $choice = ""
    while ($choice -notmatch "[y|n]") {
        $choice = read-host "$message (Y/N)"
    }

    if ($choice -eq "y") {
        $result = 1
    }
    else {
        $result = 0
    }
    return [bool]$result
}
