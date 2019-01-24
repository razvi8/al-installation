param (
    [string]$prov_key
)
Set-ExecutionPolicy -ExecutionPolicy  ByPass
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ((get-service | where {$_.name -eq 'al_agent'}))
{
    Write-Host "AL Service found - no reinstallation or reconfiguration.  Starting agent..."
    # the service is installed, lets make sure it can start
    Set-Service -Name al_agent -StartupType Automatic
    Start-Service al_agent
    return $?
}

Write-Host "Installing AL agent..."

$client = new-object System.Net.WebClient
$url = "https://scc.alertlogic.net/software/al_agent-LATEST.msi"
$output = "C:\al_agent-LATEST.msi"

$client.DownloadFile($url, $output)

Start-Process "msiexec.exe" -ArgumentList "/i $output prov_key=$prov_key install_only=1 /q" -Wait -NoNewWindow


Set-Service -Name al_agent -StartupType Automatic
Start-Service al_agent

Start-Sleep -s 5
Write-Host "Verify that agents have been installed successfully by checking host specific pem files..."
ls 'C:\Program Files (x86)\Common Files\AlertLogic\host_crt.pem'
ls 'C:\Program Files (x86)\Common Files\AlertLogic\host_key.pem'

return $?
