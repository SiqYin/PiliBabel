param(
    [string]$Arg = ''
)

try {
    $versionName = $null

    $versionCode = [int](git rev-list --count HEAD).Trim()

    $commitHash = (git rev-parse HEAD).Trim()

    $updatedContent = foreach ($line in (Get-Content -Path 'pubspec.yaml' -Encoding UTF8)) {
        if ($line -match '^\s*version:\s*([\d\.]+)') {
            $versionName = $matches[1]
            if ($Arg -eq 'android') {
                $versionName += '-' + $commitHash.Substring(0, 9)
            }
            "version: $versionName+$versionCode"
        }
        else {
            $line
        }
    }

    if ($null -eq $versionName) {
        throw 'version not found'
    }

    # 版本自洽校验：tag 的数字部分必须与 pubspec 的 x.y.z 一致。
    # 之前发 v3.6.4.1 时 pubspec 还是 3.6.4，APP 自报 3.6.4、却看到更新的 tag，
    # 于是反复提示更新。这里直接拦住这类不一致的发布。
    if ($env:GITHUB_REF_NAME -and $env:GITHUB_REF_NAME -match '^v?(\d+(?:\.\d+)*)$') {
        $tagVersion = $matches[1]
        if ($tagVersion -ne $versionName) {
            throw "tag $env:GITHUB_REF_NAME does not match pubspec version $versionName"
        }
    }

    $updatedContent | Set-Content -Path 'pubspec.yaml' -Encoding UTF8

    $buildTime = [int]([DateTimeOffset]::Now.ToUnixTimeSeconds())

    $data = @{
        'pili.name' = $versionName
        'pili.code' = $versionCode
        'pili.hash' = $commitHash
        'pili.time' = $buildTime
    }

    $data | ConvertTo-Json -Compress | Out-File 'pili_release.json' -Encoding UTF8

    Add-Content -Path $env:GITHUB_ENV -Value "version=$versionName+$versionCode"
}
catch {
    Write-Error "Prebuild Error: $($_.Exception.Message)"
    exit 1
}