<#
By default in this template, we are including the AWSPowerShell.NetCore module
when packing the PowerShell code.
If you do not need AWSPowerShell.NetCore module, you can move following #Requires line into the comment block.
#>

#Requires -Modules 'AWSPowerShell.NetCore'

# By default, outputting to the environment to CloudWatch for easier troubleshooting later on.
# Comment this section if you don't need it.
Write-Host '$LambdaInput'
Write-Host -Object $LambdaInput
$LambdaInputJson = ConvertTo-Json -Compress $LambdaInput -Depth 5
Write-Verbose -Message $LambdaInputJson -Verbose

Write-Host 'ENV'
$ENVJson = Get-ChildItem env:\ | ConvertTo-Json -Depth 1
Write-Verbose -Message $ENVJson -Verbose

# Add your own code below. Have fun building. :)
try
{
    Write-Verbose 'Hello World!' -Verbose
    'Hello World!'
}
catch
{
    $MyError = $Error[0]
    Write-Error $MyError
    throw "Error - $MyError"
}