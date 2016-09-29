    param
    (
        [IPAddress]$IPAddress,
        [int]$TimeOut = 2000
    )

    $ntpData = New-Object byte[] 48
    $ntpData[0] = 27

    $socket = New-Object Net.Sockets.Socket('InterNetwork','Dgram','Udp')
    $socket.SendTimeout = $TimeOut
    $socket.ReceiveTimeout = $TimeOut

    $epochTime = Get-Date -Year 1900 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0

    trap
    {
        Write-Error $Error[0].Exception.Message
        return
    }

    $socket.Connect($IPAddress,123)

    $t1 = Get-Date

    $socket.Send($ntpData) > $null
    $socket.Receive($ntpData) > $null

    $t4 = Get-Date

    $socket.Dispose()

    $intPart = [BitConverter]::ToUInt32($ntpData[43..40],0)
    $fracPart = [BitConverter]::ToUInt32($ntpData[47..44],0)
    $t3 = $intPart + ($fracPart / 0x100000000)

    $intPart = [BitConverter]::ToUInt32($ntpData[35..32],0)
    $fracPart = [BitConverter]::ToUInt32($ntpData[39..36],0)
    $t2 = $intPart + ($fracPart / 0x100000000)

    $t1 = ($t1.ToUniversalTime() - $epochTime).TotalSeconds
    $t4 = ($t4.ToUniversalTime() - $epochTime).TotalSeconds

    return (($t2 - $t1) + ($t3-$t4))/2
