#region notes
# The prerequisites are:
# .Net Core SDK
# AWS CLI
# PowerShell Core 6
# PowerShell modules:
#     AWSPowerShell.NetCore
#     AWSLambdaPSCore
# Pre-created S3 bucket in the target account.
# Pre-configured AWSPowerShell.NetCore/ AWS CLI credentials
#
# **Note: This will overwrite the existing default profile for AWS CLI.**
#
# In VSCode, run this file using Ctrl+F5. If you use F8 or select and run, this won't work.
#endregion notes

#region parameters
# The lambda name should be under 25 so it doesn't get truncated.
$lambdaname = '[[LambdaName]]'
$s3bucketname = '[[S3BucketName]]'

$s3prefix = $lambdaname
$FolderPath = Split-Path -Path ($MyInvocation.InvocationName) -Parent
$ScriptPath = Join-Path -Path $folderPath -ChildPath "$lambdaname.ps1"
$OutputPackagePath = Join-Path -Path $folderPath -ChildPath "$lambdaname.zip"

$ServerlessTemplateFilePath = Join-Path -Path $folderPath -ChildPath '[[LambdaName]]-serverless.template'
$UpdatedTemplateFilePath = Join-Path -Path $folderPath -ChildPath '[[LambdaName]]-updated.template'

$module = 'AWSPowerShell.NetCore'
if (-Not (Get-Module $module))
{
    Import-Module $module
}
#endregion parameters

#region helper function
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

# Packging the AWS PowerShell Lamda package.
New-AWSPowerShellLambdaPackage -ScriptPath $ScriptPath -OutputPackage $OutputPackagePath -PowerShellSdkVersion '6.1.0'

# Transforming the template using the SAM module and aws cloudformation package command
aws cloudformation package --template-file $ServerlessTemplateFilePath --s3-bucket $s3bucketname --s3-prefix $s3prefix --output-template-file $UpdatedTemplateFilePath

# Deploy the transformed cloudformation tempalte into the account. Here I am using the lambdaname as the stack name but really you can pick whatever you like.
aws cloudformation deploy --template-file $UpdatedTemplateFilePath --stack-name $lambdaname --capabilities CAPABILITY_IAM

break
# Section below invokes the lambda
if ($lambdaname.Length -le 20)
{
    Get-LMFunctionList | Where-Object FunctionName -like "$lambdaname*" | Invoke-LMFunction
}
else
{
    Get-LMFunctionList | Where-Object FunctionName -like "*$($lambdaname.Substring(0,20))*" | Invoke-LMFunction
}