#PickaCoin.ps1 - davenport651
#Simple Powershell script to find the estimated earning per coin for given hashrate and then launch proper miner.

####Set up the parameters of your rig and pool here:
$EthHashRate = '27.9'
$ETHminer = 'C:\miners\phoenix-eth\PhoenixMiner.exe'
$ETHargs = '-pool us.cruxpool.com:5555 -wal 0xd80580E2C6a30d83aD7aDc9eD04d6c71aCe6718C -worker GIT -gt 35'
$ETCargs = '-pool us.cruxpool.com:7777 -wal 0x3A07C7bc41936EF70B0ecDDefa355A6b8734B9C2 -worker GIT -gt 35'
####

$ETCperDay = (Invoke-WebRequest https://www.cruxpool.com/api/etc/estimatedEarnings/$EthHashRate | ConvertFrom-Json | Select -expand data | Select estEarningsPerDay)[0].estEarningsPerDay * (Invoke-WebRequest https://api.pro.coinbase.com/products/ETC-USD/ticker | ConvertFrom-Json | Select -expand price)
$ETHperDay = (Invoke-WebRequest https://www.cruxpool.com/api/eth/estimatedEarnings/$EthHashRate | ConvertFrom-Json | Select -expand data | Select estEarningsPerDay)[0].estEarningsPerDay * (Invoke-WebRequest https://api.pro.coinbase.com/products/ETH-USD/ticker | ConvertFrom-Json | Select -expand price)
$NiceHash = (Invoke-WebRequest 'https://whattomine.com/coins.json?adapt_q_570=1&adapt_570=true&eth=true&factor%5Beth_hr%5D=27.90&factor%5Beth_p%5D=101.00&factor%5Bcost%5D=0&sort=Profitability24&volume=0&revenue=24h&dataset=&commit=Calculate.json' | ConvertFrom-Json | Select -expand coins | Select -expand "Nicehash-Ethash")[0]."btc_revenue24"
$Nicehash = [convert]::ToDecimal($NiceHash) * [convert]::ToDecimal((Invoke-WebRequest https://api.pro.coinbase.com/products/BTC-USD/ticker | ConvertFrom-Json | Select -expand price))

echo (Get-Date)
echo "ETC Rev: $"$ETCperDay
echo "ETH Rev: $"$ETHperDay
echo "Nicehash Rev $"$NiceHash

IF ($ETCperDay -gt $ETHperDay -and $ETCperDay -gt $Nicehash) {
    echo "Starting ETC Miner..."
    start microsoft-edge:"https://www.cruxpool.com/etc/miner/0x3A07C7bc41936EF70B0ecDDefa355A6b8734B9C2"
    #This pays out to Coinbase ETC wallet
        #Start-Process -filepath $ETHminer -argumentlist $ETCargs
    #PhoenixMiner.exe -pool us.cruxpool.com:7777 -wal 0x3A07C7bc41936EF70B0ecDDefa355A6b8734B9C2 -worker GIT
    
    #temporary workaround to ETC stale-shares bug after Nov2020 fork:
    start-process -filepath "C:\miners\lolminer\lolMiner.exe" -argumentlist "--algo ETCHASH --pool us.cruxpool.com:7777 --user 0x3A07C7bc41936EF70B0ecDDefa355A6b8734B9C2"
    }
    ElseIf ($ETHperDay -gt $ETCperDay -and $ETHperDay -gt $NiceHash) {
    echo "Starting ETH Miner..."
    start microsoft-edge:"https://www.cruxpool.com/eth/miner/0xd80580E2C6a30d83aD7aDc9eD04d6c71aCe6718C"
    #This pays out to Uphold LTC wallet via ethereum
    Start-Process -filepath $ETHminer -argumentlist $ETHargs
    #PhoenixMiner.exe -pool us.cruxpool.com:5555 -wal 0xd80580E2C6a30d83aD7aDc9eD04d6c71aCe6718C -worker GIT
    }
    ElseIf ($NiceHash -gt $ETCperDay -and $NiceHash -gt $ETHperDay) {
    echo "Starting Nicehash..."
    Start-Process -filepath "C:\Users\$env:USERNAME\AppData\Local\Programs\NiceHash Miner\NiceHashMiner.exe"
    }
    Else {
    echo "Something went wrong."
    }


pause
