#Requires -Modules 'AWSPowerShell.NetCore'

#Outputting to CloudWatch for troubleshooting. Comment this section if you don't need it.
Write-Host '$LambdaInput'
Write-Host -Object $LambdaInput
$t1 = ConvertTo-Json -Compress $LambdaInput -Depth 5
Write-Verbose -Message $t1 -Verbose
Write-Host 'ENV'
$t2 = Get-ChildItem env:\ | ConvertTo-Json -Depth 1
Write-Verbose -Message $t2 -Verbose

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