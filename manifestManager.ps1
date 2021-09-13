function Get-RemoteFileHash {
    param($URI)
    $wc = [System.Net.WebClient]::new()
    return Get-FileHash -InputStream ($wc.OpenRead($URI))
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
    $FileHash = Get-RemoteFileHash -URI $eap.URI

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
        Set-Content .\software_manifest.json -Value ($list | Sort-Object pkgname | ConvertTo-Json)
        $list = $null
    }
    else {
        $entry
    }
    
}
