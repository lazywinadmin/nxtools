<#
    $env:PSGalleryKey is set in the Continous Integration plaform
    $env:modulePath is set in the build.ps1
    $env:moduleName is set in the build.ps1
    $ENV:BH* are set by the BuildHelpers module

    https://psdeploy.readthedocs.io/en/latest/PSDeploy-Configuration-Files/
#>
if(
    $env:modulePath -and
    $env:BHBuildSystem -ne 'Unknown' -and
    $env:BHBranchName -eq "master" -and
    $env:BHCommitMessage -match '!deploy'
)
{
    Deploy -Name Module {
        By -DeploymentType PSGalleryModule {
            FromSource -Source $env:modulePath
            To -Targets PSGallery
            WithOptions -Options @{
                ApiKey = $env:psgallerykey
            }
        }
    }
}
else
{
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
    "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
    "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)" |
        Write-Host
}