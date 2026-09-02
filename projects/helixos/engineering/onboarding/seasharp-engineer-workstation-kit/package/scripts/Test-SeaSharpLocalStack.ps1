#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$WorkspaceRoot = 'C:\dev',
    [ValidateSet('Helix', 'Zorka', 'All')]
    [string]$Product = 'All',
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'SeaSharp.Onboarding.psm1') -Force
$config = Get-SeaSharpConfig
$root = Resolve-SeaSharpWorkspaceRoot $WorkspaceRoot
$products = if ($Product -eq 'All') { @('Helix', 'Zorka') } else { @($Product) }
$results = New-Object 'System.Collections.Generic.List[object]'

foreach ($productName in $products) {
    $repoPath = Get-SeaSharpProductPath -Product $productName -WorkspaceRoot $root
    $repoPresent = Test-Path -LiteralPath (Join-Path $repoPath '.git')
    $results.Add([pscustomobject]@{
        Product = $productName
        Check = 'Repository'
        Target = $repoPath
        Status = if ($repoPresent) { 'PASS' } else { 'SKIP' }
        Detail = if ($repoPresent) { 'Checkout found.' } else { 'Checkout not found at the conventional path.' }
    })

    foreach ($check in @($config.healthChecks.$productName)) {
        $passed = $false
        $testedTarget = $null
        if ([string]$check.kind -eq 'tcp') {
            $testedTarget = "$($check.host):$($check.port)"
            $passed = Test-SeaSharpTcpPort -HostName ([string]$check.host) -Port ([int]$check.port)
        }
        elseif ([string]$check.kind -eq 'http') {
            $testedTarget = [string]$check.target
            $passed = Test-SeaSharpHttpEndpoint -Uri $testedTarget
            if (-not $passed -and $check.alternateTarget) {
                $alternate = [string]$check.alternateTarget
                if (Test-SeaSharpHttpEndpoint -Uri $alternate) {
                    $passed = $true
                    $testedTarget = $alternate
                }
            }
        }
        else {
            throw "Unsupported health check kind '$($check.kind)' in workstation.json."
        }

        $results.Add([pscustomobject]@{
            Product = $productName
            Check = [string]$check.name
            Target = $testedTarget
            Status = if ($passed) { 'PASS' } else { 'FAIL' }
            Detail = if ($passed) { 'Reachable' } else { 'Not reachable' }
        })
    }
}

$failures = @($results | Where-Object { $_.Status -eq 'FAIL' }).Count
if ($Json) {
    $results | ConvertTo-Json -Depth 4
}
else {
    $results | Format-Table -AutoSize -Wrap
    if ($failures -eq 0) { Write-SeaSharpStatus PASS 'All selected local services are reachable.' }
    else { Write-SeaSharpStatus FAIL "$failures selected local service(s) are not reachable." }
}
if ($failures -gt 0) { exit 1 }
