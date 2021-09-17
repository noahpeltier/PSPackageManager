$architecture = "$($env:PROCESSOR_ARCHITECTURE -replace "AMD")"

function Get-SpiManifest {
    param($path)
    $Manifest = import-clixml .\Manifest.xml
    return $Manifest
}

function Find-SpiApp {
    param($SearchString)
    $Manifest = Get-SpiManifest -Path .\Manifest.xml
    return ($Manifest | where {$_.DisplayName -like "*$SearchString*"})
}

function Get-SpiApp-OLD {
    [Parameter(ValueFromPipeline)]
    param(
        $AppName,
        [string[]]$Filter
    )
    
    $Manifest = Get-SpiManifest -Path .\Manifest.xml
    $result = ($Manifest | where {$_.AppName -eq "GoogleChrome" }) #$AppName
    $result.packages | where {$_.architecture -match ($env:PROCESSOR_ARCHITECTURE -replace 'AMD') -and $_.Language -match '(\Wen\W)|en_us|en-us|English' }
}

function Get-SpiApp {
    param(
        #[Parameter(ValueFromRemainingArguments)]
        $Name,
        $SpecialFilter
    )

    $result = ($Manifest | where {$_.AppName -eq $Name })
    $filter = [System.Collections.ArrayList]::new()
    switch ($result.Packages[0].psobject.properties) {
        {$_.name -contains "Architecture"} {
            if ($result.packages -match "$($architecture)|\Wx64\W|x64") {
                $filter.Add('$_.architecture -match "$($architecture)|\W64\W|x64"')
            }
        }
        {$_.name -contains "Language"} {
            $filter.Add('$_.Language -match "(\Wen\W)|en_us|en-us|English"' )
        }
        {$_.name -contains "Ring"} {
            $filter.Add('$_.Ring -eq "General"')
        }
        {$_.value -match ".exe" } {
            $filter.Add('$_.URI -match ".exe"')
        }
    }
    if ($SpecialFilter) {
        $filter.Add('$_ -match "$($SpecialFilter)"')
    }

    $where = [scriptblock]::Create(($Filter -join " -and "))
    if (($where.ToString()).tochararray().count -gt 0) {
        $result.packages | where $where
    }
    else {
        $result.packages
    }
}

function Get-SpiAppInstaller {
    param([uri]$url)
    $outPath = ("$env:windir\temp\" + ($url | Split-Path -Leaf))
    $wc = New-Object net.webclient
    $wc.Downloadfile($url, $outPath)
    return $outPath
}

function Install-SpiApp {

}

function spi {
    param(
        [ValidateSet('Install','Uninstall','Search')]
        $arg,
        [switch]$Force
    )

    if ($arg -eq 'Install') {
        
    }

    if ($arg -eq 'Uninstall') {
        
    }
   
    if ($arg -eq 'Search') {
        
    }
}



$result = ($Manifest | where {$_.AppName -eq "AdobeAcrobat" })
$filter = [System.Collections.ArrayList]::new()
switch ($result.Packages[0].psobject.properties) {
    {$_.name -contains "Architecture"} {
        if ($result.packages -match "$($architecture)|\W64\W|x64") {
            $filter.Add('$_.architecture -match "$($architecture)|\W64\W|x64"')
        }
    }
    {$_.name -contains "Language"} {
        $filter.Add('$_.Language -match "(\Wen\W)|en_us|en-us|English"' )
    }
    {$_.name -contains "Ring"} {
        $filter.Add('$_.Ring -eq "General"')
    }
    {$_.value -match ".exe" } {
        $filter.Add('$_.URI -match ".exe"')
    }
}
if ($SpecialFilter) {
    $filter.Add('$_ -match "$($SpecialFilter)"')
}

$where = [scriptblock]::Create(($Filter -join " -and "))
if (($where.ToString()).tochararray().count -gt 0) {
    $result.packages | where $where
}
else {
    $result.packages
}




$result.packages | where {}

$array = [System.Collections.ArrayList]::new()

switch (("My Name is Noah" -split " ")) {
    {$_ -contains "Noah"} {
        $array.add("It's Noah")
    }
    {$_ -contains "Name"} {
        $array.add("Includes Name")
    }
}

