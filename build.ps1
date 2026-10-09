$ErrorActionPreference = "Stop"

$jdkBin = "C:\Users\vanes\AppData\Roaming\.tlauncher\legacy\Minecraft\jre\java-runtime-epsilon\windows-x64\java-runtime-epsilon\bin"
$javac = Join-Path $jdkBin "javac.exe"
$jar = Join-Path $jdkBin "jar.exe"

$mcJar = "C:\Users\vanes\AppData\Roaming\.tlauncher\legacy\Minecraft\game\versions\26.3\26.3.jar"
$librariesDir = "C:\Users\vanes\AppData\Roaming\.tlauncher\legacy\Minecraft\game\libraries"

$classesDir = "build\classes"
$outDir = "build\libs"

if (Test-Path $classesDir) { Remove-Item -Recurse -Force $classesDir }
if (Test-Path $outDir) { Remove-Item -Recurse -Force $outDir }

New-Item -ItemType Directory -Force -Path $classesDir | Out-Null
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$cpList = [System.Collections.Generic.List[string]]::new()
$cpList.Add($mcJar)

Get-ChildItem -Path $librariesDir -Recurse -Filter "*.jar" | ForEach-Object {
    $cpList.Add($_.FullName)
}

Get-ChildItem -Path "build\fabric-libs\*.jar" | ForEach-Object {
    $cpList.Add($_.FullName)
}

$classpath = $cpList -join ";"

Write-Host "Compiling Java sources..."
& $javac -cp $classpath -d $classesDir "src\main\java\com\example\hotbarscroll\HotbarScrollMod.java"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Compilation failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host "Copying resources..."
Copy-Item -Path "src\main\resources\*" -Destination $classesDir -Recurse -Force

$modJsonPath = Join-Path $classesDir "fabric.mod.json"
(Get-Content $modJsonPath) -replace '\$\{version\}', '1.0.0' | Set-Content $modJsonPath

Write-Host "Packaging JAR..."
$targetJar = Join-Path $outDir "hotbarscroll-1.0.0-mc26.3.jar"
& $jar cf $targetJar -C $classesDir .

Write-Host "SUCCESS: Mod JAR built at $targetJar"
