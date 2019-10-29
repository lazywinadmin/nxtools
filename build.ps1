<#
.SYNOPSIS
Used to start the build of a PowerShell Module
.DESCRIPTION
This script will install dependencies using PSDepend module and start the build tasks using InvokeBuild module
.NOTES
Change History
-1.0 | 2019/06/17 | Francois-Xavier Cat
    Initial version
#>
[CmdletBinding()]
Param(
    #[string[]]$tasks,
    [string]$GalleryRepository,
    [pscredential]$GalleryCredential,
    [string]$GalleryProxy,
    [string[]]$tasks, # @('build','test','deploy')
    [switch]$InstallDependencies
    )
try{
    ################
    # EDIT THIS PART
    $guid = 'f6349442-d0c2-4026-9445-a520005b5d65'
    $moduleName = "nxtools" # get from source control or module ?
    $author = 'Francois-Xavier Cat' # fetch from source or module
    $description = 'nxtools is a set of tools to use in *nx Operationg systems' # fetch from module ?
    $companyName = 'lazywinadmin.com' # fetch from module ?
    $projectUri = "https://github.com/lazywinadmin/$moduleName" # get from module of from source control, env var
    $licenseUri = "https://github.com/lazywinadmin/$moduleName/blob/master/LICENSE.md"
    $tags = @('linux','nx')
    ################

    #$rootpath = Split-Path -path $PSScriptRoot -parent
    $rootpath = $PSScriptRoot                       # \             -- root of the project
    $buildOutputPath = "$rootpath\buildoutput"      # \buildoutput  -- final module format folder location and tests results files
    $buildPath = "$rootpath\build"                  # \build        -- scripts used to build the module
    $srcPath = "$rootpath\src"                      # \src          -- source files such as Public/Private etc...
    $testPath = "$rootpath\tests"                   # \tests        -- Pester tests
    $modulePath = "$buildoutputPath\$moduleName"    # \buildoutput\<modulename> -- final module format
    $dependenciesPath = "$rootpath\dependencies"    # \dependencies -- folder to store modules

    $env:moduleName = $moduleName
    $env:modulePath = $modulePath

    $buildRequirementsFilePath = "$buildPath\build.psdepend.psd1" # contains dependencies/requirements
    $buildTasksFilePath = "$buildPath\build.tasks.ps1" # contains tasks to execute
    $buildPSDeployFilePath = "$buildPath\build.psdeploy.ps1" # contains deployment info used by psdeploy
    $buildPSScriptAnalyzerSettingsFilePath = "$buildPath\build.scriptanalyzersettings.psd1" # contains deployment info used by psdeploy

    $buildOutputTestResultFilePath = "$buildoutputPath\test-results.xml"

    if($InstallDependencies)
    {
        # Setup PowerShell Gallery as PSrepository  & Install PSDepend module
        if (-not(Get-PackageProvider -Name NuGet -ForceBootstrap)) {
            $providerBootstrapParams = @{
                Name = 'nuget'
                force = $true
                ForceBootstrap = $true
            }

            if($PSBoundParameters['verbose']) {$providerBootstrapParams.add('verbose',$verbose)}
            if($GalleryProxy) { $providerBootstrapParams.Add('Proxy',$GalleryProxy) }
            $null = Install-PackageProvider @providerBootstrapParams
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        # (Test)Install


        if (-not(Get-Module -Listavailable -Name PSDepend)) {
            Write-verbose "BootStrapping PSDepend"
            "Parameter $buildOutputPath"| Write-verbose
            $InstallPSDependParams = @{
                Name = 'PSDepend'
                AllowClobber = $true
                Confirm = $false
                Force = $true
                Scope = 'CurrentUser'
            }
            if($PSBoundParameters['verbose']) { $InstallPSDependParams.add('verbose',$verbose)}
            if ($GalleryRepository) { $InstallPSDependParams.Add('Repository',$GalleryRepository) }
            if ($GalleryProxy)      { $InstallPSDependParams.Add('Proxy',$GalleryProxy) }
            if ($GalleryCredential) { $InstallPSDependParams.Add('ProxyCredential',$GalleryCredential) }
            Install-Module @InstallPSDependParams
        }

        # Install module dependencies with PSDepend
        $PSDependParams = @{
            Force = $true
            Path = $buildRequirementsFilePath
        }
        if($PSBoundParameters['verbose']) { $PSDependParams.add('verbose',$verbose)}
        Invoke-PSDepend @PSDependParams -Target $dependenciesPath
        Write-Verbose -Message "Project Bootstrapped"
    }else{
        Write-Verbose -Message "Skip InstallDependencies"
    }

    # Start build using InvokeBuild module
    Invoke-Build -Result 'Result' -File $buildTasksFilePath -Task $tasks

    # Return error to CI
    if ($Result.Error)
    {
        $Error[-1].ScriptStackTrace | Out-String
        exit 1
    }
    exit 0
}catch{
    throw $_
}