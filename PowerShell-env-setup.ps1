# ---------------------------------------------
# 開発環境セットアップスクリプト（管理者権限なし）
# Scoop + Git + Java + VSCode + Node.js
# ---------------------------------------------

# 実行ポリシーをユーザー範囲で許可（必要なら）
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Scoopが未インストールならインストール
if (-not (Test-Path "$env:USERPROFILE\scoop")) {
    iwr -useb get.scoop.sh | iex
}

# Gitを先にインストール（Scoop操作に必要）
scoop install git

# Javaバケットを追加（OpenJDKが含まれる）
scoop bucket add java

# OpenJDK 21 をインストール
scoop install openjdk21

# バケットを追加（VSCodeが含まれる）
scoop bucket add versions
# Visual Studio Code のバージョンをインストール
scoop bucket add extras
# VSCode をインストール
scoop install vscode

# Node.js をインストール
scoop install nodejs

# JAVA_HOMEを設定
$javaPath = (scoop prefix openjdk21)
[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "User")

# Path に JAVA_HOME\bin を追加（重複防止あり）
$binPath = "$javaPath\bin"
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")

if (-not ($oldPath -split ";" | Where-Object { $_ -eq $binPath })) {
    $newPath = "$oldPath;$binPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
}

# 完了メッセージ
Write-Host "`n✅ 開発環境のインストールが完了しました！"
Write-Host "インストール済みツール："
Write-Host " - Git"
Write-Host " - OpenJDK 21 (JAVA_HOME 設定済み)"
Write-Host " - Visual Studio Code"
Write-Host " - Node.js"
Write-Host "`n🔁 環境変数を反映するには PowerShell を再起動してください。"
