# PowerShell-Lambda-Template

This template  is to enable a PowerShell developer with faster feedback loop when developing a PowerShell Lambda function. The workflow uses AWS Serverless Application Module (SAM) template to describe the Lambda function as an application. The template can then be transformed, deployed, updated and teared down quickly via command line, which enables the developer to observer and receive feedbacks quickly.

## File conttent

* `Deploy.ps1`: The `Deploy.ps1` script to help with deploy the PowerShell Lamnda application using the AWS SAM model.
* `serverless.template`: The `serverless.template` is the SAM (CloudFormation) template that describes the AWS Lambda.
* `PowerShellLambda.ps1`: The `PowerShellLambda.ps1`, which will be renamed by Plaster as the Lambda name, is the PowerShell Lambda code.
* `plasterManifest.xml`: The `plasterManifest.xml` contains the Plaster construct that transforms the template into actual project folder structures.

## Prequisites

* [.Net Core SDK](https://dotnet.microsoft.com/download)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html)
* [PowerShell Core 6](https://github.com/PowerShell/PowerShell)
* PowerShell modules:
  * [Plaster](https://github.com/PowerShell/Plaster)- Plaster is a template-based file and project generator similar to [Yeoman](https://yeoman.io/)
  * [AWSPowerShell.NetCore](https://www.powershellgallery.com/packages/AWSPowerShell.NetCore)
  * [AWSLambdaPSCore](https://www.powershellgallery.com/packages/AWSLambdaPSCore)

## Assumptions

Assuming you already have:

* Pre-created S3 bucket in the target AWS account.
* Already configured the AWSPowerShell.NetCore and AWS CLI credentials/ profiles/ default regions.
  * AWS PowerShell - [Using AWS Credentials](https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html)
  * AWS CLI - [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

## Usage

Once you have the prequisites ready, you can use following steps to create a new PowerShell SAM Lambda project using the template.
**NOTE: make sure you have the AWS credential configured for both AWS PowerShell and AWS CLI.**

### High Level Steps

1. Open the `PowerShell Core 6` console.
2. Type this command and press enter: `Invoke-Plaster -TemplatePath 'C:\Code\PowerShell-Lambda-Template' -DestinationPath C:\Code\MyHelloWorldLambda`
3. You will be prompted for Lambda name, S3 bucket name. Please provide answers. (Hint: Press `Ctrl-C` to stop)
4. You should see output similar to the following:
  - ![example](./Content/Example.PNG)
5. Let's go to the `C:\Code` folder. It will have following files and structures. The descriptions is in the brackets.
    ```
    C:\Code
    \---MyHelloWorldLambda (from the -Destination of Invoke-Plaster)
        \---HelloWorld (The lambda name)
                Deploy.ps1 (The PowerShell Script for code deployemnt)
                HelloWorld-serverless.template (SAM template)
                HelloWorld.ps1 (The actual PowerShell Lambda code)
    ```
7. Now, open the `HelloWorld` folder in Visual Studio Code.
8. The `HelloWorld.ps1` contains the basic PowerShell Code to output environmental variales.
9. Open the `Deploy.ps1` file
10. Make sure you have `PowerShell 6.x` selected on the bottom left. This ensures we are using PowerShell Core 6 in the VSCode's Integrated Console.
11. Press `Ctrl + F5` to deploy the default Lambda to the AWS account (using default region). **NOTE: make sure you have the AWS credential configured for both AWS PowerShell and AWS CLI.**
12. Now, you can iterate quickly with:
    1. update the `HelloWorld.ps1` with the code you want.
    2. Go to `Deploy.ps1`
    3. Press `Ctrl + F5` to update the Lambda, test, observe and repeat.

## Note

**If in VSCode, run the Deploy.ps1 file using Ctrl+F5. F8 or select and run won't work.**