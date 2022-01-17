$architecture = "$($env:PROCESSOR_ARCHITECTURE -replace "AMD")"

function Get-SpiManifest {
    param($path)
    $Manifest = import-clixml $path
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
    $outPath = ("$env:windir\temp\" + (Resolve-Uri $url).filename)
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

function Resolve-Uri {
    <#
    .SYNOPSIS
        Resolves a URI and also returns the filename and last modified date if found.

    .DESCRIPTION
        Resolves a URI and also returns the filename and last modified date if found.

    .NOTES
        Site: https://packageology.com
        Author: Dan Gough
        Twitter: @packageologist

    .LINK
        https://github.com/DanGough/Nevergreen

    .PARAMETER Uri
        The URI resolve. Accepts an array of strings or pipeline input.

    .PARAMETER UserAgent
        Optional parameter to provide a user agent for Invoke-WebRequest to use. Examples are:

        Googlebot: 'Googlebot/2.1 (+http://www.google.com/bot.html)'
        Microsoft Edge: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246'

    .EXAMPLE
        Resolve-Uri -Uri 'http://somewhere.com/somefile.exe'

        Description:
        Returns the absolute redirected URI, filename and last modified date.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [ValidatePattern('^(http|https)://')]
        [Alias('Url')]
        [String[]] $Uri,
        [Parameter(
            Mandatory = $false,
            Position = 1)]
        [String] $UserAgent
    )

    begin {
        $ProgressPreference = 'SilentlyContinue'
    }

    process {

        foreach ($UriToResolve in $Uri) {

            try {

                $ParamHash = @{
                    Uri              = $UriToResolve
                    Method           = 'Head'
                    UseBasicParsing  = $True
                    DisableKeepAlive = $True
                    ErrorAction      = 'Stop'
                }

                if ($UserAgent) {
                    $ParamHash.UserAgent = $UserAgent
                }

                $Response = Invoke-WebRequest @ParamHash

                if ($IsCoreCLR) {
                    $ResolvedUri = $Response.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
                }
                else {
                    $ResolvedUri = $Response.BaseResponse.ResponseUri.AbsoluteUri
                }

                Write-Verbose "$($MyInvocation.MyCommand): URI resolved to: $ResolvedUri"

                #PowerShell 7 returns each header value as single unit arrays instead of strings which messes with the -match operator coming up, so use Select-Object:
                $ContentDisposition = $Response.Headers.'Content-Disposition' | Select-Object -First 1

                if ($ContentDisposition -match 'filename="?([^\\/:\*\?"<>\|]+)') {
                    $FileName = $matches[1]
                    Write-Verbose "$($MyInvocation.MyCommand): Content-Disposition header found: $ContentDisposition"
                    Write-Verbose "$($MyInvocation.MyCommand): File name determined from Content-Disposition header: $FileName"
                }
                else {
                    $Slug = [uri]::UnescapeDataString($ResolvedUri.Split('?')[0].Split('/')[-1])
                    if ($Slug -match '^[^\\/:\*\?"<>\|]+\.[^\\/:\*\?"<>\|]+$') {
                        Write-Verbose "$($MyInvocation.MyCommand): URI slug is a valid file name: $FileName"
                        $FileName = $Slug
                    }
                    else {
                        $FileName = $null
                    }
                }

                try {
                    $LastModified = [DateTime]($Response.Headers.'Last-Modified' | Select-Object -First 1)
                    Write-Verbose "$($MyInvocation.MyCommand): Last modified date: $LastModified"
                }
                catch {
                    Write-Verbose "$($MyInvocation.MyCommand): Unable to parse date from last modified header: $($Response.Headers.'Last-Modified')"
                    $LastModified = $null
                }

            }
            catch {
                Throw "$($MyInvocation.MyCommand): Unable to resolve URI: $($_.Exception.Message)"
            }

            if ($ResolvedUri) {
                [PSCustomObject]@{
                    Uri          = $ResolvedUri
                    FileName     = $FileName
                    LastModified = $LastModified
                }
            }

        }
    }

    end {
    }

}

