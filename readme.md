# PowerShell-Lambda-Template

## Synopsis

This template can provide a PowerShell developer with a faster feedback loop when developing a PowerShell Lambda function/ application.

## Description

This workflow/ template leverages [AWS Serverless Application Model (SAM) template](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) to describe the Lambda function as an application. The template can then be transformed, deployed, updated, and torn down quickly via command line, enabling the developer to observe and receive feedback quickly.

## File Content

* `tools\DeployLambda.ps1`: The `DeployLambda.ps1` script will deploy the PowerShell Lambda application using the AWS SAM model. It will create an AWS CloudFormation stack with the Lambda resources.
* `tools\InvokeLambda.ps1`: The `InvokeLambda.ps1` invokes the AWS Lambda function and shows the output in the console. 
* `tools\s3bucket.yml`: This is a CloudFormation template that you can use to create a S3 bucket.
* `tools\sample-vscode-tasks.json`: This is the VSCode task json file. Plaster will use this to
* `src\serverless.template`: The `serverless.template` is the SAM (CloudFormation) template that describes the AWS Lambda. You
* `src\PowerShellLambda.ps1`: The `PowerShellLambda.ps1`, which will be renamed by Plaster as the Lambda name, is the PowerShell Lambda code.
* `plasterManifest.xml`: The `plasterManifest.xml` contains the Plaster construct that transforms the template into actual project folder structures.

## Prerequisites

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

Once you have the prerequisites ready, use the following steps to create a new PowerShell SAM Lambda project using the template.

***NOTE: make sure you have the AWS credential configured for both AWS PowerShell and AWS CLI.***

### High Level Steps

1. Open the `PowerShell Core 6` console.
2. Type the following command and press enter:
    ``` powershell
    Invoke-Plaster -TemplatePath 'C:\Code\PowerShell-Lambda-Template' -DestinationPath C:\Code\MyHelloWorldLambda
    ```
3. You will be prompted for a Lambda name, target AWS region and S3 bucket name. Please provide them.

    *(Hint: Press `Ctrl-C` to stop)*
4. You should see output similar to the following:

    ![example](./Content/Example.PNG)
5. Navigate to the `C:\Code` folder. It will contain the following folder and file structure. The descriptions are in the brackets.

```
C:\CODE\MYHELLOWORLDLAMBDA (from the -Destination of Invoke-Plaster)
\---HelloWorld (The lambda name)
    |   readme.txt
    |
    +---.vscode
    |       tasks.json
    |
    +---artifact
    |       .gitignore (The git ignore prevents the generated artifacts getting tracked.)
    |
    +---src
    |       HelloWorld-serverless.template (SAM template)
    |       HelloWorld.ps1 (The actual PowerShell Lambda code)
    |       HelloWorld.tests.ps1 (Write tests for your PowerShell code)
    |
    \---tools
            DeployLambda.ps1 (The PowerShell Script for deploying the lamnda - SAM template)
            InvokeLambda.ps1 (The PowerShell Script for invoking the lambda)
            psl_config.json (The configuration file storing the lamba/ s3/ AWS region information)
```

1. Open the `HelloWorld` folder in Visual Studio Code.
2. The `HelloWorld.ps1` contains the basic PowerShell Code to output environmental variables.
3. Open the `Deploy.ps1` file
4.  Make sure you have `PowerShell 6.x` selected on the bottom right. This ensures we are using PowerShell Core 6 in the VSCode's Integrated Console.
5.  Press `F1` - `Tasks: Run Task` - `DeployLambda` to deploy the default Lambda to the AWS.
6.  Once deployed, press `F1` - `Tasks: Run Task` - `InvokeLambda` to invoke the deployed Lambda. If there is any output, it will be shown in the VSCode console.

    ***NOTE: make sure you have the AWS credential configured for both AWS PowerShell and AWS CLI.***
7.  Now, you can iterate quickly with:
    1. update the `HelloWorld.ps1` with the code you want.
    2. If you need to add permission to your lambda; add trigger; add other AWS resources, you can do so using the SAM model in the `serverless.template`
    3. Re-deploy the Lambda, invoke, test, observe and repeat. Have fun building!

## Notes

The `DeployLambda.ps1` and `InvokeLambda.ps1` can be used from console or other editor also. I include the VSCode task config for my own convenience. :-)