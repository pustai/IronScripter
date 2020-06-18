<#
TEXT ME – A POWERSHELL DIALER CHALLENGE
https://ironscripter.us/text-me-a-powershell-dialer-challenge/
#>

[CmdletBinding()]
param (

    [Parameter(
        ValueFromPipeline = $true,
        HelpMessage = 'Enter a text to convert'
    )]# end:[Parameter(
    [ValidateLength(1, 5)]
    [string]
    $String

) # end: param (

$Dialer = @{
    2 = 'a', 'b', 'c'
    3 = 'd', 'e', 'f'
    4 = 'g', 'h', 'i'
    5 = 'j', 'k', 'l'
    6 = 'm', 'n', 'o'
    7 = 'p', 'q', 'r', 's'
    8 = 't', 'u', 'v'
    9 = 'w', 'x', 'y', 'z'
} # end:$Dialer = @{

function Get-NumericToText() {

    foreach ($digit in ($String -split '')) {

        [string[]]$Text += ($Dialer.GetEnumerator() | Where-Object { $_.Name -eq $digit }).Value | Select-Object -First 1

    } #end: foreach ($digit in ($String -split '')) {
    Write-Output ($Text -join '')

} # end: function Get-NumericToText() {

function Get-TextToNumeric() {

    foreach ($letter in ($String -split '')) {

        [string[]]$numeric += ($Dialer.GetEnumerator() | Where-Object { $_.Value -eq $letter }).Name

    }# end: foreach ($letter in ($String -split '')) {
    Write-Output ($numeric -join '')

} # end: function Get-TextToNumeric() {

if ($String -match "\d") {
    Get-NumericToText
} # end: if ($String -match "\d") {
Else {
    Get-TextToNumeric
} # end: Else {
