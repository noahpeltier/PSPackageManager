function Get-RemoteFileHash {
    param($URI)
    $wc = [System.Net.WebClient]::new()
    return Get-FileHash -InputStream ($wc.OpenRead($URI))
}


$savedManifest

$AppList = Find-EvergreenApp
$Global:Manifest = [System.Collections.ArrayList]::new()
foreach ($app in $AppList) {

    Write-output $app
    $PackageData = Get-EvergreenApp -Name $app.name

    $entry = [PSCustomObject][ordered]@{
        AppName = $App.Name
        DisplayName = $App.Application
        Provider = $App.Link
        Packages = $PackageData #[System.Collections.ArrayList]::new()
    }
    $Manifest.Add($entry) | Out-Null
}


$Application = Find-EvergreenApp -Name MicrosoftTeams
$PackageData = Get-EvergreenApp -Name MicrosoftTeams