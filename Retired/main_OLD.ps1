function apt {
    param(
        [ValidateSet('install','uninstall')]
        $arg
    )

    switch ($arg) {
        'install' {
           
            $File = Download-File ($args | out-string)

            switch ( (Get-item $File).extension ) {
                '.exe' {
                    Write-host "Type of file is .exe`nInstalling software from $File Please Wait ..."
                    Start-Process $File -ArgumentList "/S" -Wait -PassThru
                }
                   
                '.msi' {
                    Write-host "Installing software from $File`nPlease Wait"
                    Start-Process $File -ArgumentList "/quiet" -Wait -PassThru
                }
            }
        }
        'Uninstall' {
            $Uninstall = Get-InstalledSoftware -DisplayName $args
            Start-Process $Uninstall -ArgumentList "/S" -Verb runas
        }
    }
}

function Download-File {
    param([uri]$url)
    $outPath = ("$env:windir\temp\" + ($url | Split-Path -Leaf))
    $wc = New-Object net.webclient
    $wc.Downloadfile($url, $outPath)
    return $outPath
}

function Get-InstalledSoftware {
    param($DisplayName)

    $paths=@(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
    )
   $list = foreach($path in $paths){
        Get-ChildItem -Path $path | Get-ItemProperty | Select DisplayName, Publisher, InstallDate, DisplayVersion, uninstallstring
    }
    return ($list | where {$_.displayname -like "*$DisplayName*"}).uninstallstring
}


