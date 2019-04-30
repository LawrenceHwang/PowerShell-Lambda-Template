param (
    [string]$ConfigName = 'psl_default',
    [string]$ConfigPath
)
#region helper function
function Get-PSLConfig {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Path,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $ConfigName
    )
    try {
        $ConfigContent = Get-Content -Path $Path -Raw
        $Config = ConvertFrom-Json -InputObject $ConfigContent | Select-Object -ExpandProperty $ConfigName
    }
    catch {
        $TError = $error[0]
        throw "Error: $TError"
    }
    Finally {
        $Config
    }
}
function Show-ErrorDetail {
    [CmdletBinding()]
    param(
        $ErrorRecord = $Error[0]
    )

    $ErrorRecord | Format-List -Property * -Force
    $ErrorRecord.InvocationInfo | Format-List -Property * -Force
    $Exception = $ErrorRecord.Exception
    for ($depth = 0; $null -ne $Exception; $depth++) {
        "$depth" * 80
        $Exception | Format-List -Property * -Force
        $Exception = $Exception.InnerException
    }
}
#endregion helper function

#region parameters
# The lambda name should be under 25 so it doesn't get truncated.
$RootFolderPath = Split-Path -Path $PSScriptRoot -Parent
$toolsFolderPath = Join-Path -Path $RootFolderPath -ChildPath 'tools'


# Using the default config.json path
if ($ConfigPath -eq '') {
    $ConfigPath = Join-Path $toolsFolderPath -ChildPath 'psl_config.json'
}

Write-Verbose "ConfigPath: $ConfigPath" -verbose

try {
    $Config = Get-PSLConfig -Path $ConfigPath -ConfigName $ConfigName -ErrorAction Stop
}
catch {
    throw 'Missing Config.'
}

$lambdaname = $Config.lambdaname
$AWSAccountID = $Config.AWSAccountID
$AWSAccountIAMRole = $Config.AWSAccountIAMRole
$AWSRegion = $Config.AWSRegion

$module = 'AWSPowerShell.NetCore'
if (-Not (Get-Module $module)) {
    Import-Module $module
}
# Setting up the credential for both AWSPowerShell.NetCore and the aws cli
if ($PSEdition -eq 'Desktop') {
    throw 'This deployment script does not work with non PS Core version'
}
elseif ($PSEdition -eq 'Core') {
    if ($IsWindows) {
        $AWSCredProfileLocation = "$env:USERPROFILE\.aws\credentials"
    }
    else {
        $AWSCredProfileLocation = '~/.aws/credentials'
    }
}
Set-DefaultAWSRegion -Region $AWSRegion -Verbose
#endregion parameters
if ($lambdaname.Length -le 20) {
    $Result = Get-LMFunctionList | Where-Object FunctionName -like "$lambdaname*" | Invoke-LMFunction -Verbose
}
else {
    $Result = Get-LMFunctionList | Where-Object FunctionName -like "*$($lambdaname.Substring(0,20))*" | Invoke-LMFunction -Verbose
}

if ($null -ne $Result.Payload) {
    $StreamReader = [System.IO.StreamReader]::new($Result.Payload)
    $StreamReader.ReadToEnd()
}
else {
    Write-Warning 'Lambda did not output any result.'
}