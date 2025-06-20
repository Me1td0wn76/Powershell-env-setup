# ---------------------------------------------
# 開発環境セットアップスクリプト（管理者権限なし）
# Scoop + Git + Java + VSCode + Node.js
# 各ツールのパスを環境変数に追加
# ---------------------------------------------

# Scoopがインストールされているか確認し、未インストールならインストール
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoopが見つかりません。インストールを開始します..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
} else {
    Write-Host "Scoopは既にインストールされています。"
}

# gitがインストールされているか確認し、未インストールならインストール
if (-not (scoop list | Select-String -Pattern "^git\s")) {
    Write-Host "gitが見つかりません。インストールを開始します..."
    scoop install git
} else {
    Write-Host "gitは既にインストールされています。"
}

# extrasバケットが追加されているか確認し、未追加なら追加
if (-not (scoop bucket list | Select-String -Pattern "^extras$")) {
    Write-Host "Scoop extrasバケットを追加します..."
    scoop bucket add extras
} else {
    Write-Host "Scoop extrasバケットは既に追加されています。"
}

# mainバケットが追加されているか確認し、未追加なら追加
if (-not (scoop bucket list | Select-String -Pattern "^main$")) {
    Write-Host "Scoop mainバケットを追加します..."
    scoop bucket add main
} else {
    Write-Host "Scoop mainバケットは既に追加されています。"
}

# インストールしたいアプリ一覧（gitはすでに処理済みなので除外）
$apps = @(
    @{ name = "nodejs"; bucket = "main" },
    @{ name = "vscode"; bucket = "extras" },
    @{ name = "maven"; bucket = "main" },
    @{ name = "gradle"; bucket = "main" },
    @{ name = "jq"; bucket = "main" },
    @{ name = "curl"; bucket = "main" }
)

foreach ($app in $apps) {
    if (-not (scoop list | Select-String -Pattern ("^" + $app.name + "\s"))) {
        Write-Host "$($app.name) が見つかりません。インストールを開始します..."
        scoop install $app.name
    } else {
        Write-Host "$($app.name) は既にインストールされています。"
    }
}

# VS CodeのパスをユーザーPATHに追加（必要な場合のみ）
$codePath = "$env:USERPROFILE\scoop\apps\vscode\current\bin"
if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $codePath })) {
    Write-Host "VS CodeのパスをユーザーPATHに追加します..."
    [Environment]::SetEnvironmentVariable(
        "PATH",
        "$env:PATH;$codePath",
        [EnvironmentVariableTarget]::User
    )
} else {
    Write-Host "VS Codeのパスは既にPATHに含まれています。"
}

# VS Codeのショートカットをデスクトップに作成
$desktop = [Environment]::GetFolderPath("Desktop")
$vscodeExe = "$env:USERPROFILE\scoop\apps\vscode\current\Code.exe"
$shortcutPath = Join-Path $desktop "Visual Studio Code.lnk"

if (Test-Path $vscodeExe) {
    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $vscodeExe
    $shortcut.WorkingDirectory = Split-Path $vscodeExe
    $shortcut.IconLocation = $vscodeExe
    $shortcut.Save()
    Write-Host "VS Codeのショートカットをデスクトップに作成しました。"
} else {
    Write-Host "VS Codeの実行ファイルが見つかりませんでした。ショートカットは作成されません。"
}

# Javaバケットを追加
scoop bucket add java

# 必要なツールをインストール
scoop install openjdk21
scoop install vscode
scoop install nodejs
scoop install maven
scoop install gradle
scoop install jq
scoop install curl

# ========== 環境変数の設定 ==========

# 既存ユーザーPath取得
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")

# 追記対象パスのリスト
$pathsToAdd = @()

# JAVA_HOME 設定（OpenJDKのプレフィックスを取得）
$javaPath = (scoop prefix openjdk21)
[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "User")
$pathsToAdd += "$javaPath\bin"

# Git の bin パス追加
$gitPath = (scoop prefix git)
$pathsToAdd += "$gitPath\bin"

# Node.js の bin パス追加
$nodePath = (scoop prefix nodejs)
$pathsToAdd += "$nodePath\bin"

# Maven の bin パス追加
$mavenPath = (scoop prefix maven)
$pathsToAdd += "$mavenPath\bin"

# Gradle の bin パス追加
$gradlePath = (scoop prefix gradle)
$pathsToAdd += "$gradlePath\bin"

# jq の bin パス追加
$jqPath = (scoop prefix jq)
$pathsToAdd += "$jqPath"

# curl の bin パス追加
$curlPath = (scoop prefix curl)
$pathsToAdd += "$curlPath"

# 重複チェックしてPathに追記
foreach ($p in $pathsToAdd) {
    if (-not ($oldPath -split ";" | Where-Object { $_ -eq $p })) {
        $oldPath += ";$p"
    }
}

# 更新されたPathを保存
[Environment]::SetEnvironmentVariable("Path", $oldPath, "User")

# ========== 完了メッセージ ==========

Write-Host "`環境のインストールが完了しました！"
Write-Host " - OpenJDK 21（JAVA_HOME 設定済）"
Write-Host " - Git（bin追加）"
Write-Host " - Node.js（bin追加）"
Write-Host " - VSCode"
Write-Host " - VSCodeのデスクトップショートカット"
Write-Host " - Maven（bin追加）"
Write-Host " - Gradle（bin追加）"
Write-Host " - jq（bin追加）"
Write-Host " - curl（bin追加）"
Write-Host "`環境変数 Path に以下のパスが追加されました："
$pathsToAdd | ForEach-Object { Write-Host "   $_" }
Write-Host "`PowerShell や VSCode を再起動して反映を確認してください。"
