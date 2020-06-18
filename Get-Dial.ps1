[CmdletBinding()]
param (
    [Parameter(
        ValueFromPipeline = $true,
        HelpMessage = 'Enter a text to convert'
    )]
    [ValidateLength(1, 5)]
    [string]
    $String

)

$Dialer = @{
    2 = 'a', 'b', 'c'
    3 = 'd', 'e', 'f'
    4 = 'g', 'h', 'i'
    5 = 'j', 'k', 'l'
    6 = 'm', 'n', 'o'
    7 = 'p', 'q', 'r', 's'
    8 = 't', 'u', 'v'
    9 = 'w', 'x', 'y', 'z'
}

function Get-NumericToText() {

    foreach ($digit in ($String -split '')) {

        [string[]]$Text += ($Dialer.GetEnumerator() | Where-Object { $_.Name -eq $digit }).Value | Select-Object -First 1

    } #end: foreach ($digit in ($String -split '')) {
    Write-Output ($Text -join '')

}

function Get-TextToNumeric() {

    foreach ($leter in ($String -split '')) {

        [string[]]$numeric += ($Dialer.GetEnumerator() | Where-Object { $_.Value -eq $leter }).Name

    }
    Write-Output ($numeric -join '')

}

if ($String -match "\d") {
    Get-NumericToText
}
Else {
    Get-TextToNumeric
}
