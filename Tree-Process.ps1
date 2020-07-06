[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ComputerName = $env:ComputerName
)

# Verify if administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Verbose 'Running with elevations rigths'
    $isAdministrator = $true
}# end:if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
else {
    $isAdministrator = $false
    Write-Verbose 'Running without elevations rigths'
    Write-Verbose 'Won´t show username information'
} # end: else {

# Funtion return ProcessName and idChain to format output
# idChain is a trace from the process to its top parent
function Get-Chain() {
    Write-Verbose 'Obtaining process list'
    $AllProcess = Get-CimInstance -ClassName win32_process -ComputerName $ComputerName | Select-Object Name, ProcessID, ParentProcessID,
    @{Name = 'Age'; expression = { ((Get-date) - (Get-Date $_.CreationDate)) } }
    Write-Verbose "$($allProcess.Count) process were found"
    Write-Verbose "ProcessName: idChain"
    foreach ($process in $AllProcess) {

        $idChain = new-object 'System.Collections.Generic.List[int]'
        $auxProcess = $process
        if ($isAdministrator) {
            $userName = (Get-Process -IncludeUserName -id $process.ProcessID).UserName
        } # end: if ($isAdministrator) {
        else {
            $userName = '?'
        } # end: else {

        $continue = $true
        do {

            # $auxprocess is empty when reach the parent of the process
            # if it´s not empty it´s not the top parent yet
            if (!$auxProcess) {
                $idchain.Add($process.ProcessID)
                $property = @{
                    Name        = $process.Name
                    idChain     = $idChain
                    ProcessID   = $process.ProcessID
                    Age         = $process.Age
                    UserName    = $userName
                } # end: $property = @{
                $obj = New-Object -TypeName PSObject -Property $property
                Write-Output $obj
                $continue = $false
                Write-Verbose "$($process.Name): $($idChain)"
            } # end: if (!$auxProcess) {

            # build an idChain.
            # when the process is the toppest parent $auxProcess will be $null
            # unless it´s System Idle Process witch have ProcessID 0 and ParentProcessID 0
            else {
                $idchain.Insert(0, $auxProcess.ParentProcessID)
                if ($auxProcess.ParentProcessID -ne 0) {
                    $auxProcess = $allProcess | Where-Object { $_.ProcessID -eq $auxProcess.ParentProcessID }
                }# end: if ($auxProcess.ParentProcessID -ne 0) {
                else {
                    $auxProcess = $null
                } # end: else {
            } # end: else - if (!$auxProcess) {

        }while ($continue)
    } # end: foreach ($process in $AllProcess) {
} # end: function Get-Chain() {

$Process = Get-Chain

# Format Output
Write-Verbose 'Formatting output..'
# Add the topmost level as computer name.
$property = [ordered]@{
    ProcessID   = $null
    Age         = $null
    UserName    = $null
    Tree        = "+-$ComputerName"
} # end: $property = @{
$obj = New-Object -TypeName PSObject -Property $property
Write-Output $obj

# write result
$Process | Sort-Object idchain | ForEach-Object {

    # prepare identation with tab (`t)
    $start = "|`t" * ($_.idchain.count - 1)

    $property = [ordered]@{
        ProcessID = $_.ProcessID
        Age       = $_.Age
        UserName  = $_.UserName
        Tree      = ("{0}+-{1}" -f $start, $_.Name)
    } # end: $property = @{
    $obj = New-Object -TypeName PSObject -Property $property
    Write-Output $obj

} # end: Get-Chain | Sort-Object idchain | ForEach-Object {
