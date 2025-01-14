Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"


# File path for logging
$logFile = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), "KeystrokesLog.txt")

function Write-ToFile($text) {
    [System.IO.File]::AppendAllText($logFile, $text)
}

# Function to display a dialog box to get user input (masked for password)
function Get-Input {
    param (
        [string]$prompt,
        [switch]$isPassword
    )

    $inputBox = New-Object System.Windows.Forms.Form
    $inputBox.Text = $prompt
    $inputBox.Size = New-Object System.Drawing.Size(300, 150)
    $inputBox.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $prompt
    $label.Size = New-Object System.Drawing.Size(260, 20)
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $inputBox.Controls.Add($label)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Size = New-Object System.Drawing.Size(260, 20)
    $textbox.Location = New-Object System.Drawing.Point(20, 50)
    if ($isPassword) {
        $textbox.PasswordChar = '*'
    }
    $inputBox.Controls.Add($textbox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Size = New-Object System.Drawing.Size(75, 30)
    $okButton.Location = New-Object System.Drawing.Point(100, 80)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $inputBox.Controls.Add($okButton)

    $inputBox.AcceptButton = $okButton

    $result = $inputBox.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textbox.Text
    }

    return $null
}

# Get username and password from user input dialogs
$username = Get-Input -prompt "Please enter your username:" -isPassword:$false
$password = Get-Input -prompt "Please enter your password:" -isPassword:$true

# Log username and password (plain text for logging purposes)
Write-ToFile "Username: $username`r`n"
Write-ToFile "Password: $password`r`n"

Write-Host "Username and password have been logged."

# Optional: Start keystroke capture for further activity
Write-Host "Start typing. Press 'Enter' to record keystrokes."
Write-Host "To exit the capture, press Ctrl+C."

$typedText = ""

# Ensure that the script does not capture a rogue first character
$keystroke = [System.Console]::ReadKey($true)  # Read the first keypress and discard it

while ($true) {
    $keystroke = [System.Console]::ReadKey($true)

    if ($keystroke.Key -eq 'Enter') {
        Write-ToFile "`r`n"
        [System.Console]::WriteLine()
        $typedText = ""  
    }
    elseif ($keystroke.Key -eq 'Backspace') {
        if ($typedText.Length -gt 0) {
            $typedText = $typedText.Substring(0, $typedText.Length - 1)

            [System.Console]::Write("`b` `b")
            Write-ToFile "`b"  
        }
    }
    else {
        $typedText += $keystroke.KeyChar

        [System.Console]::Write($keystroke.KeyChar)

        Write-ToFile $keystroke.KeyChar
    }
}
