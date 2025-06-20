# ---------------------------------------------
# 開発環境セットアップスクリプト（管理者権限なし）
# Scoop + Git + Java + VSCode + Node.js
# 各ツールのパスを環境変数に追加
# ---------------------------------------------

# 実行ポリシーをユーザー範囲で許可
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Scoopが未インストールならインストール
if (-not (Test-Path "$env:USERPROFILE\scoop")) {
    iwr -useb get.scoop.sh | iex
}

# Gitを先にインストール（Scoop操作に必要）
scoop install git

# Javaバケットを追加
scoop bucket add java

# 必要なツールをインストール
scoop install openjdk21
scoop install vscode
scoop install nodejs

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

# 重複チェックしてPathに追記
foreach ($p in $pathsToAdd) {
    if (-not ($oldPath -split ";" | Where-Object { $_ -eq $p })) {
        $oldPath += ";$p"
    }
}

# 更新されたPathを保存
[Environment]::SetEnvironmentVariable("Path", $oldPath, "User")

# ========== 完了メッセージ ==========

Write-Host "`n✅ 開発環境のインストールが完了しました！"
Write-Host " - OpenJDK 21（JAVA_HOME 設定済）"
Write-Host " - Git（bin追加）"
Write-Host " - Node.js（bin追加）"
Write-Host " - VSCode"
Write-Host "`環境変数 Path に以下のパスが追加されました："
$pathsToAdd | ForEach-Object { Write-Host "   $_" }
Write-Host "`PowerShell や VSCode を再起動して反映を確認してください。"
