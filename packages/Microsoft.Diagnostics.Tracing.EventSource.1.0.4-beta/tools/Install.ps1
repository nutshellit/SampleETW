param($installPath, $toolsPath, $package, $project)
    # This is the MSBuild targets file to add
    $targetsFile = [System.IO.Path]::Combine($toolsPath, $package.Id + '.targets')
 
    # Need to load MSBuild assembly if it's not loaded yet.
    Add-Type -AssemblyName 'Microsoft.Build, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'

    # Grab the loaded MSBuild project for the project
    $msbuild = [Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($project.FullName) | Select-Object -First 1

    # Grab the target framework version and identifier from the loaded MSBuild proect
    $targetFrameworkIdentifier = $msbuild.Xml.Properties | Where-Object { $_.Name.Equals("TargetFrameworkIdentifier") } | Select-Object -First 1
    $targetFrameworkVersion = $msbuild.Xml.Properties | Where-Object { $_.Name.Equals("TargetFrameworkVersion") } | Select-Object -First 1

    # Make the path to the targets file relative.
    $projectUri = new-object Uri($project.FullName, [System.UriKind]::Absolute)
    $targetUri = new-object Uri($targetsFile, [System.UriKind]::Absolute)
    $relativePath = [System.Uri]::UnescapeDataString($projectUri.MakeRelativeUri($targetUri).ToString()).Replace([System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar)

    # Add the import and save the project
    $msbuild.Xml.AddImport($relativePath) | out-null
    $project.Save()
