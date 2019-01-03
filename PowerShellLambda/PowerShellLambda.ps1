#Requires -Modules 'AWSPowerShell.NetCore'

#Outputting to CloudWatch for troubleshooting. Comment out this section if you don't need it.
write-host '$LambdaInput'
write-host -Object $LambdaInput
$t1 = ConvertTo-Json -Compress $LambdaInput -Depth 5
Write-Verbose -Message $t1 -Verbose
write-host 'ENV'
$t2 = Get-ChildItem env:\ | convertto-json -Depth 1
Write-Verbose -Message $t2 -Verbose


# Add your own code below. Have fun building. :)