

[CmdletBinding()]
param (
    [Parameter()]
    [int]
    $seconds
)

function Get-RedableSize() {
    <#
	.SYNOPSIS

        Get-redableSize.ps1 facilita a leitura do tamanho de arquivos

    .DESCRIPTION

        Converte os tamanhos de Bytes para o formato mais apropriado (KB,MB,GB,etc) para facilitar a leitura.


	.PARAMETER  Bytes

        Entrada de valor em Bytes para conversao

            Uso:
                -Bytes <n>

    .EXAMPLE
        .\Get-RedableSize -Bytes 1234

        Converte o valor 1234 de Bytes para 1,2 KB

    .EXAMPLE
        Get-ChildItem file.txt |Get-RedableSize

        Retorna o tamanho do arquivo em formato que facilita a leitura

    .EXAMPLE
        Get-ChildItem -file *| Sort-Object -Descending -Property Length | Select-Object Name,@{Name="Tamanho";Expression={$($_.Length | Get-RedableSize)}}

        Retorna coluna com nome e tamanho dos arquivos em formato que facilita a leitura

#>
    [cmdletbinding()]
    Param(
        [Parameter(
            ValueFromPipeline,
            Mandatory = $true,
            Helpmessage = 'Enter value to convert'

        )]
        $Bytes

    )
    # Se nulo = 0
    Add-Type -Assembly Microsoft.VisualBasic
    if ( ![Microsoft.VisualBasic.Information]::IsNumeric($Bytes)) { $Bytes = 0 }
    # Se negativo converte para positivo
    if ($Bytes -lt 0) {
        $Bytes = $Bytes * -1
        $negativo = $true
    }

    $bytesuffix = "b/s", "Kb/s", "Mb/s", "Gb/s"
    $index = 0
    while ($Bytes -gt 1kb) {
        $Bytes = $Bytes / 1kb
        $index++
    }
    # Retorna conversao para positivo
    if ($negativo) { $Bytes = $Bytes * -1 }

    "{0,7:N1} {1}" -f $Bytes, $bytesuffix[$index]
} # end function Get-RedableSize() {


$ethName = (Get-NetAdapter -Physical | Where-Object status -eq up).InterfaceDescription
$ethName = $ethName.Replace("(", "[").Replace(")", "]")
$i = 0
do {

    $Counter = Get-Counter -Counter "\Interface de rede($ethName)\*"


    $Total = (($Counter.CounterSamples | Where-Object { $_.Path -match "Total de bytes" }).CookedValue)
    $Send = (($Counter.CounterSamples | Where-Object { $_.Path -match "Bytes enviados" }).CookedValue)
    $Received = (($Counter.CounterSamples | Where-Object { $_.Path -match "Bytes Recebidos" }).CookedValue)
    $Banda = ($Counter.CounterSamples | Where-Object { $_.Path -match "largura de banda" }).CookedValue / 20
    # $Banda = 60*1024*1024

    $Construct = [ordered]@{
        TotalConvert    = Get-RedableSize $($Total * 8 )
        Total = [math]::Round($Total,2)
        TotalPercent = [math]::Truncate($($Total / $banda * 100))
        SendConvert     = Get-RedableSize $($Send * 8)
        Send = [Math]::Round($send,2)
        SendPercent = [math]::Truncate($($Send / $banda * 100))
        ReceivedConvert = Get-RedableSize $($Received * 8)
        Received = [Math]::Round($Received,2)
        ReceivedPercent = [math]::Truncate($($Received / $banda * 100))
        BandaConvert    = Get-RedableSize $($Banda * 8)
        Banda = [math]::Round($Banda,2)


    }

   <#  $Progress = @{
        Activity = "$($env:COMPUTERNAME.ToUpper()) - $ethName - $($Counter.Timestamp)"
        Status   = "Estatisticas:"

    }
    Write-Progress @Progress #>

    $percent = [math]::Truncate($Total / $Banda * 100)
    $Total = Get-RedableSize $($Total * 8)
    if($percent -gt 100){$percent=100}
    $ProgressTotal = @{
        Id              = 1
        Activity        = "$($env:COMPUTERNAME.ToUpper()) - $ethName - $($Counter.Timestamp)"
        Status          = "Total: $percent % - $Total"
        PercentComplete = $percent

    }
    # $Total / $banda * 100
    Write-Progress @ProgressTotal

    $percent = [math]::Truncate($Send / $banda * 100)
    $Send = Get-RedableSize $($Send * 8)
    if($percent -gt 100){$percent=100}
    $ProgressSend = @{
        Id              = 2
        Activity        = " "
        Status          = "Send: $percent % - $Send"
        PercentComplete = $percent

    }
    # $Send / $banda * 100
    Write-Progress @ProgressSend

    $percent = [math]::Truncate($Received / $banda * 100)
    $Received = Get-RedableSize $($Received * 8)
    if($percent -gt 100){$percent=100}
    $ProgressReceived = @{
        Id              = 3
        Activity        = " "
        Status          = "Received: $percent % $Received"
        PercentComplete = $percent

    }
    # $Received / $banda * 100
    Write-Progress @ProgressReceived

    $obj = New-Object -TypeName PSObject -Property $Construct
     Write-Output $obj

    $i++
}while ($i -lt $seconds)