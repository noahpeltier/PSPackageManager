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