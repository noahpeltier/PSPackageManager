function apt {
    param(
        [ValidateSet('install', 'uninstall')]
        $arg,
        [switch]$force
    )

    switch ($arg) {
        'install' {
            
            $Package = (Get-PackageObject $args)
            Write-host "Downloading $($package.displayname)`nfrom $($package.pkgsource)"
            $File = Get-PackageFile $Package.pkgSource
            $FileHash = Get-FileHash $File
            Write-host "File hash check PASS" -ForegroundColor White

            if ((Compare-FileHash $Package.Hash -manifestHash (Get-FileHash $File))) {
                Write-host "File hashes do not match!" -ForegroundColor DarkRed
                Write-host "Expected Hash was: $($Package.pkgHash)`nBut was $FileHash"
                exit 1
            }

            switch ( (Get-item $File).extension ) {
                '.exe' {
                    $Silent = '/S'
                }
                '.msi' {
                    $Silent = '/quiet'
                }
            }

            if ($Force) {
                Write-host "Type of file is .exe`nInstalling software from $File Please Wait ..."
                Start-Process $File -ArgumentList "$Silent" -Wait -PassThru
            }
            else {
                if ((confirm -message "Continue Installing $($Package.displayname)")) {
                    Write-host "Type of file is .exe`nInstalling software from $File Please Wait ..."
                    Start-Process $File -ArgumentList "$Silent" -Wait -PassThru
                }
                else {
                    exit 0
                }
                
            }
        }

        'Uninstall' {
            $Uninstall = Get-InstalledSoftware -DisplayName $args
            if ($Uninstall -like "MsiExec.exe*") {
                $argumentList = @($Uninstall -replace 'MsiExec.exe' -split " ")
                $argumentList = ($argumentList += '/quiet') -join " "
                "Uninstalling $($Package.DisplayName)"
                Start-Process msiexec.exe -ArgumentList $argumentList -PassThru
            }
            else {
                "Uninstalling $($Package.DisplayName)"
                Start-Process $Uninstall -ArgumentList "/S" -PassThru
            }
            
        }
    }        
}

function Get-PackageManifest {
    $manifest = irm "https://raw.githubusercontent.com/noahpeltier/PSPackageManager/dev/software_manifest.json"
    return $manifest
}
function Get-PackageObject {
    param($Search)
    Get-PackageManifest | where { $_.pkgName -eq $Search }
}

function Find-PackageObject {
    param($Search)
    Get-PackageManifest | where { $_.pkgName -like "*$Search*" }
} 

function Get-PackageFile {
    param([uri]$url)
    $outPath = ("$env:windir\temp\" + ($url | Split-Path -Leaf))
    $wc = New-Object net.webclient
    $wc.Downloadfile($url, $outPath)
    return $outPath
}

function Compare-FileHash {
    param(
        $localFile,
        $manifestHash
    )
    
    return [bool](!(Compare-Object $localFile -DifferenceObject $manifestHash))
}

function Get-InstalledSoftware {
    param($DisplayName)

    $paths = @(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
    )
    $list = foreach ($path in $paths) {
        Get-ChildItem -Path $path | Get-ItemProperty | Select DisplayName, Publisher, InstallDate, DisplayVersion, uninstallstring
    }
    return ($list | where { $_.displayname -like "*$DisplayName*" }).uninstallstring
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

