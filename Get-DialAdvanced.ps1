<#
TEXT ME – A POWERSHELL DIALER CHALLENGE
https://ironscripter.us/text-me-a-powershell-dialer-challenge/
#>

[CmdletBinding()]
param (

    [Parameter(
        ValueFromPipeline = $true,
        HelpMessage = 'Enter a text to convert'
    )]
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
    $i=0
    foreach ($digit in ($String -split '')) {

        if ($digit -eq $a){
            $i++
        }elseif($a) {
            [string[]]$Text += ($Dialer.GetEnumerator() | Where-Object {$_.Name -eq $a}).Value[$i]
            $i=0
        }
        $a = $digit

    }
    Write-Output ($Text -join '')

}

function Get-TextToNumeric() {

    foreach ($letter in ($String -split '')) {

        $letterIndex = 0
        ($Dialer.GetEnumerator() | Where-Object { $_.Value -eq $letter }).Value | ForEach-Object {

            $letterIndex++
            $countIndex = 1
            $num = ($Dialer.GetEnumerator() | Where-Object { $_.Value -eq $letter }).Name
            if ($_ -eq $letter) {

                do {
                    [string[]]$numeric += $num
                    $countIndex++
                }while ($countIndex -le $letterIndex)

            }# end: if ($_ -eq $letter) {

        } # end:($Dialer.GetEnumerator() | Where-Object { $_.Value -eq $letter }).Value | ForEach-Object {

    } # end foreach ($letter in ($String -split '')) {
    Write-Output ($numeric -join '')

}

if ($String -match "\d") {
    Get-NumericToText
}
Else {
    Get-TextToNumeric
}