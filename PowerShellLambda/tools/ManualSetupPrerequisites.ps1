#requires -Version 6

#######################################################
# Installs the dotnetcore-sdk powershell-core awscli
# Installs the ChocoLatey if not exists.
if (-NOT (Get-Command choco -ErrorAction SilentlyContinue))
{
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
# Using chocolatey to install dotnetcore-sdk powershell-core and awscli
& choco install dotnetcore-sdk powershell-core awscli -y
#######################################################
# Install the required modules
$ModuleHash = @(
    @{
        Name       = 'AWSPowerShell.NetCore'
        Scope      = 'CurrentUser'
        Repository = 'PSGallery'
    }
    @{
        Name       = 'AWSLambdaPSCore'
        Scope      = 'CurrentUser'
        Repository = 'PSGallery'
    }
    @{
        Name       = 'Plaster'
        Scope      = 'CurrentUser'
        Repository = 'PSGallery'
    }
)

foreach ($m in $ModuleHash)
{
    Get-Module -Name $m.Name -ListAvailable -ErrorAction SilentlyContinue
    Install-Module @m -Force
}