[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ComputerName = $env:ComputerName
)

# Funtion return ProcessName and idChain to format output
# idChain is a trace from the process to its top parent
function Get-Chain() {
    $AllProcess = Get-WmiObject win32_process -ComputerName $ComputerName | Select-Object Name, ProcessID, ParentProcessID,
    @{Name = 'Age'; expression = { ((Get-date) - (Get-Date ($_.ConvertToDateTime($_.CreationDate)))) } }

    foreach ($process in $AllProcess) {

        $idChain = new-object 'System.Collections.Generic.List[int]'
        $auxProcess = $process

        $continue = $true
        do {

            # $auxprocess is empty when reach the parent of the process
            # if it´s not empty it´s not the top parent yet
            if (!$auxProcess) {
                $idchain.Add($process.ProcessID)
                $property = @{
                    Name      = $process.Name
                    idChain   = $idChain
                    ProcessID = $process.ProcessID
                    Age       = $process.Age
                } # end: $property = @{
                $obj = New-Object -TypeName PSObject -Property $property
                Write-Output $obj
                $continue = $false
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
# Add the topmost level as computer name.
$property = [ordered]@{
    ProcessID = $null
    Age       = $null
    Tree      = "+-$ComputerName"
} # end: $property = @{
$obj = New-Object -TypeName PSObject -Property $property
Write-Output $obj

# write result
$Process | Sort-Object idchain | ForEach-Object {

    # prepare identation with tab (`t)
    $start = "|`t " * ($_.idchain.count - 1)

    $property = [ordered]@{
        ProcessID = $_.ProcessID
        Age    = $_.Age
        Tree      = ("{0}+-{1}" -f $start, $_.Name)
    } # end: $property = @{
    $obj = New-Object -TypeName PSObject -Property $property
    Write-Output $obj

} # end: Get-Chain | Sort-Object idchain | ForEach-Object {

