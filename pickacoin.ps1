#PickaCoin.ps1 - davenport651
#Simple Powershell script to find the estimated earning per coin for given hashrate and then launch proper miner.

$EthHashRate = '27.9'


$ETCperDay = (Invoke-WebRequest https://www.cruxpool.com/api/etc/estimatedEarnings/$EthHashRate | ConvertFrom-Json | Select -expand data | Select estEarningsPerDay)[0].estEarningsPerDay * (Invoke-WebRequest https://api.pro.coinbase.com/products/ETC-USD/ticker | ConvertFrom-Json | Select -expand price)
$ETHperDay = (Invoke-WebRequest https://www.cruxpool.com/api/eth/estimatedEarnings/$EthHashRate | ConvertFrom-Json | Select -expand data | Select estEarningsPerDay)[0].estEarningsPerDay * (Invoke-WebRequest https://api.pro.coinbase.com/products/ETH-USD/ticker | ConvertFrom-Json | Select -expand price)
$NiceHash = (Invoke-WebRequest 'https://whattomine.com/coins.json?adapt_q_570=1&adapt_570=true&eth=true&factor%5Beth_hr%5D=27.90&factor%5Beth_p%5D=101.00&factor%5Bcost%5D=0&sort=Profitability24&volume=0&revenue=24h&dataset=&commit=Calculate.json' | ConvertFrom-Json | Select -expand coins | Select -expand "Nicehash-Ethash")[0]."btc_revenue24"
$Nicehash = [convert]::ToDecimal($NiceHash) * [convert]::ToDecimal((Invoke-WebRequest https://api.pro.coinbase.com/products/BTC-USD/ticker | ConvertFrom-Json | Select -expand price))

echo $ETCperDay
echo $ETHperDay
echo $NiceHash
