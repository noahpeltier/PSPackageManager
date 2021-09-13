@"
"pkgName": "chrome",
"displayName": "Google Chrome",
"publisher": "Google",
"publisherSite": "https://www.google.com/chrome/",
"pkgVersion": "93.0.4577.63",
"pkgSource": "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi",
"hash": "A1F5DE9B726DB664A5F15DD0A777F75C5F8C240F176CACF696B9C74ED2407A60",
"LastUpdate": "8/31/2021"
"@

function New-ManifestEntry {
    param($appName)
    $ea = Find-EvergreenApp -Name $appName
    $eap = Find-EvergreenApp -Name $appName | Get-EvergreenApp #| Where-Object { $_.Language -eq "English" -or $_.Language -eq 'En' -or $_.Architecture -eq "x64" })[0]

    $wc = [System.Net.WebClient]::new()
    $FileHash = Get-FileHash -InputStream ($wc.OpenRead($eap.URI))

    $entry = [PSCustomObject][ordered]@{
        pkgName = $ea.Name
        DisplayName = $ea.Application
        publisher = $ea.Linkw
        pkgversion = $eap.version
        pkgSource = $eap.uri
        hash = $FileHash.hash
        LastUpdate = $eap.date
    }   
    return $entry
} 


function New-ManifestEntry {
    param($name,[switch]$Test)
    $ea = Find-EvergreenApp -Name $Name
    $eap = Get-EvergreenApp -Name $Name
    if ($eap.count -gt 1) {
        $eap = ($eap -match "$($env:PROCESSOR_ARCHITECTURE -replace 'AMD','x')")[0]
    }
    if ($ea.count -gt 1) {
        $ea = $ea[0]
    }

    $wc = [System.Net.WebClient]::new()
    $FileHash = Get-FileHash -InputStream ($wc.OpenRead($eap.URI))

    $entry = [PSCustomObject][ordered]@{
        pkgName = $ea.Name
        DisplayName = $ea.Application
        publisher = $ea.Linkw
        pkgversion = $eap.version
        pkgSource = $eap.uri
        hash = $FileHash.hash
        LastUpdate = $eap.date
    }
    
    if (!$Test) {
        $list = [System.Collections.ArrayList]::new()
        $jsonObject = ConvertFrom-Json -InputObject (get-content .\software_manifest.json -Raw)
        foreach ($item in $jsonObject) {$list.Add($item)}
        $list.Add($entry)
        Set-Content .\software_manifest.json -Value ($list | ConvertTo-Json)
        $list = $null
    }
    else {
        $entry
    }
    
}


$filter = where {$_.channel -eq 'Stable' -and $_.architecture -eq 'x64'}