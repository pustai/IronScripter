<# #Script Iron Challenge

((1..100) |foreach{if (($_ / 2).GetType().Name -eq "int32"){$_}}) -join " "

((1..100) |foreach {if($_ % 2 -eq 0){$_}}) -join " "

((1..100) |Where-Object {($_ / 2).GetType().Name -eq "int32"}) -join " "

((1..100) |Where-Object {$_ % 2 -eq 0}) -join " " #>

function GetValues() {

    [CmdletBinding()]
    param (

        [Parameter()]
        [int32]
        [ValidateRange(1, 10)]
        $x,

        [Parameter()]
        [ValidateRange(1, 10)]
        [int32]
        $y,

        [Parameter()]
        [int32]
        $multi,

        [parameter()]
        [switch]
        $allMatches
    )

    $Result = (($x..$y) | Where-Object { $_ % $multi -eq 0 })
    $Result  | Measure-Object -sum -average | Select-Object Sum, Average

    if ($allMatches) {
        Write-Output "All the matching number(s): $Result"
    }


}