param (
    [string]$ConfigName = 'psl_default',
    [string]$ConfigPath
)

#region helper function
function Get-PSLConfig
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Path,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $ConfigName
    )
    try
    {
        $ConfigContent = Get-Content -Path $Path -Raw
        $Config = ConvertFrom-Json -InputObject $ConfigContent | Select-Object -ExpandProperty $ConfigName
    }
    catch
    {
        $TError = $error[0]
        throw "Error: $TError"
    }
    Finally
    {
        $Config
    }
}
function Show-ErrorDetail
{
    [CmdletBinding()]
    param(
        $ErrorRecord = $Error[0]
    )

    $ErrorRecord | Format-List -Property * -Force
    $ErrorRecord.InvocationInfo | Format-List -Property * -Force
    $Exception = $ErrorRecord.Exception
    for ($depth = 0; $null -ne $Exception; $depth++)
    {
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
$srcFolderPath = Join-Path -Path $RootFolderPath -ChildPath 'src'
$artifactFolderPath = Join-Path -Path $RootFolderPath -ChildPath 'artifact'


# Using the default config.json path
if ($ConfigPath -eq '')
{
    $ConfigPath = Join-Path $toolsFolderPath -ChildPath 'psl_config.json'
}

Write-Verbose "ConfigPath: $ConfigPath" -verbose

try
{
    $Config = Get-PSLConfig -Path $ConfigPath -ConfigName $ConfigName -ErrorAction Stop
}
catch
{
    throw 'Missing Config.'
}

$lambdaname = $Config.lambdaname
$s3bucketname = $Config.s3bucketname
$AWSRegion = $Config.AWSRegion

$s3prefix = $lambdaname
$ScriptPath = Join-Path -Path $srcFolderPath -ChildPath "$lambdaname.ps1"
$ArtifactPath = Join-Path -Path $artifactFolderPath -ChildPath "$lambdaname.zip"
$ServerlessTemplateFilePath = Join-Path -Path $srcFolderPath -ChildPath '[[LambdaName]]-serverless.template'
$UpdatedTemplateFilePath = Join-Path -Path $artifactFolderPath -ChildPath '[[LambdaName]]-updated.template'

$module = 'AWSPowerShell.NetCore'
if (-Not (Get-Module $module))
{
    Import-Module $module
}
# Setting up the credential for both AWSPowerShell.NetCore and the aws cli
if ($PSEdition -eq 'Desktop')
{
    throw 'This deployment script does not work with PowerShell Desktop version (v5.1..etc)'
}
elseif ($PSEdition -eq 'Core')
{
    if ($IsWindows)
    {
        $AWSCredProfileLocation = "$env:USERPROFILE\.aws\credentials"
    }
    else
    {
        $AWSCredProfileLocation = '~/.aws/credentials'
    }
}
#endregion parameters

# Packging the AWS PowerShell Lamda package.
New-AWSPowerShellLambdaPackage -ScriptPath $ScriptPath -OutputPackage $ArtifactPath -PowerShellSdkVersion ($psversiontable.psversion.ToString())

# Transforming the template using the SAM module and aws cloudformation package command
aws cloudformation package --template-file $ServerlessTemplateFilePath --s3-bucket $s3bucketname --s3-prefix $s3prefix --output-template-file $UpdatedTemplateFilePath --region $AWSRegion

# Deploy the transformed cloudformation tempalte into the account. Here I am using the lambdaname as the stack name but really you can pick whatever you like.
aws cloudformation deploy --template-file $UpdatedTemplateFilePath --stack-name $lambdaname --capabilities CAPABILITY_IAM --region $AWSRegion