param($installPath, $toolsPath, $package, $project)
 
  # Need to load MSBuild assembly if it's not loaded yet.
  Add-Type -AssemblyName 'Microsoft.Build, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'

  # Grab the loaded MSBuild project for the project
  $msbuild = [Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($project.FullName) | Select-Object -First 1

  # Grab the target framework version and identifier from the loaded MSBuild proect
  $targetFrameworkIdentifier = $msbuild.Xml.Properties | Where-Object { $_.Name.Equals("TargetFrameworkIdentifier") } | Select-Object -First 1
  $targetFrameworkVersion = $msbuild.Xml.Properties | Where-Object { $_.Name.Equals("TargetFrameworkVersion") } | Select-Object -First 1

  $importToRemove = $msbuild.Xml.Imports | Where-Object { $_.Project.Endswith($package.Id + '.targets') }

  if ($importToRemove)
  {
      # Remove the import and save the project
      $msbuild.Xml.RemoveChild($importToRemove) | out-null
      $project.Save()
  }
 