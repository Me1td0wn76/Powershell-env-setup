# ---------------------------------------------
# 開発環境セットアップスクリプト（管理者権限なし）
# Scoop + Git + Java + VSCode + Node.js + Maven + Gradle + jq + curl + Docker + Postman + Wireshark + HTTPie + Everything
#ほかにいいのあれば追加していくつもりです。
# ---------------------------------------------
# 各ツールのパスを環境変数に追加
# ---------------------------------------------

Add-Type -AssemblyName System.Windows.Forms

# Gitは必ずインストールするのでリストから除外
$apps = @(
    @{ name = "openjdk21";  label = "OpenJDK21";  bucket = "java"   },
    @{ name = "vscode";     label = "VSCode";     bucket = "extras" },
    @{ name = "nodejs";     label = "Node.js";    bucket = "main"   },
    @{ name = "maven";      label = "Maven";      bucket = "main"   },
    @{ name = "gradle";     label = "Gradle";     bucket = "main"   },
    @{ name = "jq";         label = "jq";         bucket = "main"   },
    @{ name = "curl";       label = "curl";       bucket = "main"   },
    @{ name = "docker";     label = "Docker (CLI)";     bucket = "main"   },
    @{ name = "docker-desktop"; label = "Docker Desktop (GUI)"; bucket = "extras" },
    @{ name = "postman";    label = "Postman";    bucket = "extras" },
    @{ name = "wireshark";  label = "Wireshark";  bucket = "extras" },
    @{ name = "httpie";     label = "HTTPie";     bucket = "main"   },
    @{ name = "everything"; label = "Everything"; bucket = "extras" } 
        
        
    # 他のツールを追加する場合はここに追加
    # @{ name = "toolname"; label = "Tool Label"; bucket = "bucketname"  },
)

# フォーム作成
$form = New-Object Windows.Forms.Form
$form.Text = "インストールするツールを選択"
$form.Size = New-Object Drawing.Size(360, 440)
$form.StartPosition = "CenterScreen"

# アプリ数に応じてフォームの高さを自動調整
$baseHeight = 80    # ボタンや余白分の高さ
$itemHeight = 30    # チェックボックス1つあたりの高さ
$formWidth  = 400   # フォームの幅

$formHeight = $baseHeight + ($apps.Count * $itemHeight)
$form.Size = New-Object Drawing.Size($formWidth, $formHeight)

$checkboxes = @()
$y = 20
foreach ($app in $apps) {
    $cb = New-Object Windows.Forms.CheckBox
    $cb.Text = $app.label
    $cb.Tag = $app
    $cb.Left = 20
    $cb.Top = $y
    $cb.Width = 200
    $form.Controls.Add($cb)
    $checkboxes += $cb
    $y += 30
}

$okButton = New-Object Windows.Forms.Button
$okButton.Text = "Install"
$okButton.Width = 100
$okButton.Top = $y + 10
$okButton.Left = 50
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)

$cancelButton = New-Object Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Width = 100
$cancelButton.Top = $y + 10
$cancelButton.Left = 160
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.Controls.Add($cancelButton)

$form.AcceptButton = $okButton
$form.CancelButton = $cancelButton

$result = $form.ShowDialog()

if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "キャンセルされました。"
    exit
}

# 選択されたアプリのみ抽出
$selectedApps = $checkboxes | Where-Object { $_.Checked } | ForEach-Object { $_.Tag }

if ($selectedApps.Count -eq 0) {
    Write-Host "何も選択されていません。"
    exit
}

# Scoopインストール確認
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoopが見つかりません。インストールを開始します..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
} else {
    Write-Host "Scoopは既にインストールされています。"
}

# 必ずGitをインストール
if (-not (scoop list | Select-String -Pattern "^git\s")) {
    Write-Host "Git をインストールします..."
    scoop install git
} else {
    Write-Host "Git は既にインストールされています。"
}

# 必要なバケットを追加
$neededBuckets = $selectedApps.bucket | Select-Object -Unique
foreach ($bucket in $neededBuckets) {
    if (-not (scoop bucket list | Select-String -Pattern ("^" + [regex]::Escape($bucket) + "$"))) {
        Write-Host "$bucket バケットを追加します..."
        scoop bucket add $bucket
    }
}

# 選択されたアプリをインストール
foreach ($app in $selectedApps) {
    if (-not (scoop list | Select-String -Pattern ("^" + $app.name + "\s"))) {
        Write-Host "$($app.label) をインストールします..."
        scoop install $app.name
    } else {
        Write-Host "$($app.label) は既にインストールされています。"
    }
}

Write-Host "インストールが完了しました。必要に応じてPowerShellやVSCodeを再起動してください。"

# ========== 環境変数の設定 ==========

# 既存ユーザーPath取得
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")

# 追記対象パスのリスト
$pathsToAdd = @()

# Gitのbinパスは必ず追加
$gitPath = (scoop prefix git)
$pathsToAdd += "$gitPath\bin"

foreach ($app in $selectedApps) {
    switch ($app.name) {
        "openjdk21" {
            $javaPath = (scoop prefix openjdk21)
            [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "User")
            $pathsToAdd += "$javaPath\bin"
        }
        "nodejs" {
            $nodePath = (scoop prefix nodejs)
            $pathsToAdd += "$nodePath\bin"
        }
        "maven" {
            $mavenPath = (scoop prefix maven)
            $pathsToAdd += "$mavenPath\bin"
        }
        "gradle" {
            $gradlePath = (scoop prefix gradle)
            $pathsToAdd += "$gradlePath\bin"
        }
        "jq" {
            $jqPath = (scoop prefix jq)
            $pathsToAdd += "$jqPath"
        }
        "curl" {
            $curlPath = (scoop prefix curl)
            $pathsToAdd += "$curlPath"
        }
        "docker" {
            $dockerPath = (scoop prefix docker)
            $pathsToAdd += "$dockerPath"
        }
        "postman" {
            $postmanPath = (scoop prefix postman)
            $pathsToAdd += "$postmanPath"
        }
        "wireshark" {
            $wiresharkPath = (scoop prefix wireshark)
            $pathsToAdd += "$wiresharkPath"
        }
        "httpie" {
            $httpiePath = (scoop prefix httpie)
            $pathsToAdd += "$httpiePath"
        }
        "everything" {
            $everythingPath = (scoop prefix everything)
            $pathsToAdd += "$everythingPath"
        }
    }
}

# 重複チェックしてPathに追記
foreach ($p in $pathsToAdd) {
    if (-not ($oldPath -split ";" | Where-Object { $_ -eq $p })) {
        $oldPath += ";$p"
    }
}

# 更新されたPathを保存
[Environment]::SetEnvironmentVariable("Path", $oldPath, "User")

# ========== 完了メッセージ ==========

Write-Host "`n環境のインストールが完了しました！"
Write-Host " - Git（bin追加）"
foreach ($app in $selectedApps) {
    switch ($app.name) {
        "openjdk21" { Write-Host " - OpenJDK 21（JAVA_HOME 設定済）" }
        "nodejs"    { Write-Host " - Node.js（bin追加）" }
        "vscode"    { Write-Host " - VSCode" }
        "maven"     { Write-Host " - Maven（bin追加）" }
        "gradle"    { Write-Host " - Gradle（bin追加）" }
        "jq"        { Write-Host " - jq（bin追加）" }
        "curl"      { Write-Host " - curl（bin追加）" }
        "docker"    { Write-Host " - Docker（bin追加）" }
        "postman"   { Write-Host " - Postman（bin追加）" }
        "wireshark" { Write-Host " - Wireshark（bin追加）" }
        "httpie"    { Write-Host " - HTTPie（bin追加）" }
    }
}
Write-Host "`n環境変数 Path に以下のパスが追加されました："
$pathsToAdd | ForEach-Object { Write-Host "   $_" }
Write-Host "`nPowerShell や VSCode を再起動して反映を確認してください。"

# VSCodeのデスクトップショートカットを作成（VSCodeが選択されていた場合のみ）
if ($selectedApps.name -contains "vscode") {
    $vscodePath = (scoop prefix vscode)
    $shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "VSCode.lnk")

    if (-not (Test-Path $shortcutPath)) {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = [System.IO.Path]::Combine($vscodePath, "Code.exe")
        $Shortcut.IconLocation = [System.IO.Path]::Combine($vscodePath, "Code.exe")
        $Shortcut.Save()
        Write-Host "VSCodeのデスクトップショートカットを作成しました。"
    } else {
        Write-Host "VSCodeのデスクトップショートカットは既に存在します。"
    }

    # 拡張機能インストールの確認
    $answer = Read-Host "VSCode拡張機能（日本語化・Java Extension Pack・GitHub）もインストールしますか？ (y/n)"
    if ($answer -eq "y") {
        $codeCmd = [System.IO.Path]::Combine($vscodePath, "bin", "code.cmd")
        if (-not (Test-Path $codeCmd)) {
            Write-Host "VSCodeのcodeコマンドが見つかりません。VSCodeを一度起動し、PATHを再読み込みしてください。"
        } else {
            & $codeCmd --install-extension ms-ceintl.vscode-language-pack-ja
            & $codeCmd --install-extension vscjava.vscode-java-pack
            & $codeCmd --install-extension github.vscode-pull-request-github
            Write-Host "VSCode拡張機能（日本語化・Java Extension Pack・GitHub）をインストールしました。"
            Write-Host "Displayから日本語化を選択し、VSCodeを再起動してください。"
        }
    } else {
        Write-Host "VSCode拡張機能のインストールはスキップされました。"
    }
}
# Docker Desktopのショートカットをデスクトップに作成
if ($selectedApps.name -contains "docker-desktop") {
    $dockerDesktopPath = (scoop prefix docker-desktop)
    $dockerShortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Docker Desktop.lnk")

    if (-not (Test-Path $dockerShortcutPath)) {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($dockerShortcutPath)
        $Shortcut.TargetPath = [System.IO.Path]::Combine($dockerDesktopPath, "Docker Desktop.exe")
        $Shortcut.IconLocation = [System.IO.Path]::Combine($dockerDesktopPath, "Docker Desktop.exe")
        $Shortcut.Save()
        Write-Host "Docker Desktopのデスクトップショートカットを作成しました。"
    } else {
        Write-Host "Docker Desktopのデスクトップショートカットは既に存在します。"
    }
}



# logファイルの作成
$logFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "PowerShell-env-setup.log")
$logContent = @()
$logContent += "セットアップが完了しました。"
$logContent += ""
$logContent += "インストールされたツール:"
$logContent += " - Git（bin追加）"
foreach ($app in $selectedApps) {
    switch ($app.name) {
        "openjdk21" { $logContent += " - OpenJDK 21（JAVA_HOME 設定済）" }
        "nodejs"    { $logContent += " - Node.js（bin追加）" }
        "vscode"    { $logContent += " - VSCode" }
        "maven"     { $logContent += " - Maven（bin追加）" }
        "gradle"    { $logContent += " - Gradle（bin追加）" }
        "jq"        { $logContent += " - jq（bin追加）" }
        "curl"      { $logContent += " - curl（bin追加）" }
        "docker"    { $logContent += " - Docker（bin追加）" }
        "docker-desktop" { $logContent += " - Docker Desktop（bin追加・ショートカット）" }
        "postman"   { $logContent += " - Postman（bin追加）" }
        "wireshark" { $logContent += " - Wireshark（bin追加）" }
        "httpie"    { $logContent += " - HTTPie（bin追加）" }
        "everything" { $logContent += " - Everything（bin追加・ショートカット）" }
    }
}
$logContent += ""
$logContent += "追加された環境変数 Path:"
foreach ($p in $pathsToAdd) {
    $logContent += "   $p"
}
$logContent += ""
$logContent += "PowerShell や VSCode を再起動して反映を確認してください。"

Set-Content -Path $logFilePath -Value $logContent -Encoding UTF8
Write-Host "セットアップログをデスクトップに保存しました: $logFilePath"

Write-Host ""
Write-Host "セットアップが完了しました。何かキーを押して終了してください。"
[void][System.Console]::ReadKey($true)
# スクリプトの終了