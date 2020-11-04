#!/bin/bash

# Pick-a-Coin - davenport651
# Get some values from pools and exchanges to automagically pick a coin to mine.


#### Set the miner's hashrate here: ####
EthHashRate='27.9'

### Obtains USD value per day of coins from cruxpool, coinbase, and whattomine api...
ETCperDay=$(echo $(curl -s -X GET "https://www.cruxpool.com/api/etc/estimatedEarnings/$EthHashRate" -H  "accept: application/json" | jq -r '.data.estEarningsPerDay')*$(curl -s -X GET "https://api.pro.coinbase.com/products/ETC-USD/ticker" | jq -r '.price') | bc -l)
ETHperDay=$(echo $(curl -s -X GET "https://www.cruxpool.com/api/eth/estimatedEarnings/$EthHashRate" -H  "accept: application/json" | jq -r '.data.estEarningsPerDay')*$(curl -s -X GET "https://api.pro.coinbase.com/products/ETH-USD/ticker" | jq -r '.price') | bc -l)
Nicehash=$(echo $(curl -s -X GET "https://whattomine.com/coins.json?adapt_q_570=1&adapt_570=true&eth=true&factor%5Beth_hr%5D=27.90&factor%5Beth_p%5D=101.00&factor%5Bcost%5D=0&sort=Profitability24&volume=0&revenue=24h&dataset=&commit=Calculate.json" | jq -r '.coins."Nicehash-Ethash"."btc_revenue24"')*$(curl -s -X GET "https://api.pro.coinbase.com/products/BTC-USD/ticker" | jq -r '.price') | bc -l)


echo ETC Rev = $ETCperDay
echo ETH Rev = $ETHperDay
echo Nicehash Rev = $Nicehash

#### This is a sample of the output ####
#ETC Rev = .76284716431728716668
#ETH Rev = .67489429454213923927
#Nicehash Rev = .748665594
####   ####


convertCompare() {
	# This function helps the next IF statements compare two decimal values 
	printf "%.0f\n" "$(echo "($1-$2)*1000" | bc)"
}


# To find out which variable is largest, we take [ x - n ] && [ x - n1... ] && etc; 
#	if 'x' is the largest, (x - n[all]) will be greater than zero
#	to add another coin (like RVN), add a variable above with the coresponding JSON, then 
#	append something like "&& [ "$(convertCompare x $RVNperDay -gt 0"; then" to each line and
#	add an elif statement like the other lines.

if [ "$(convertCompare $ETCperDay $ETHperDay)" -gt "0" ] && [ "$(convertCompare $ETCperDay $Nicehash)" -gt "0" ]; then
	echo Really starting ETC Miner...
elif [ "$(convertCompare $ETHperDay $ETCperDay)" -gt "0" ] && [ "$(convertCompare $ETHperDay $Nicehash)" -gt "0" ]; then
	echo Really starting ETH Miner...
elif [ "$(convertCompare $Nicehash $ETCperDay)" -gt "0" ] && [ "$(convertCompare $Nicehash $ETHperDay)" -gt "0" ]; then
	echo Really starting Nicehash...
else
	echo Something else went wrong.
fi




# The following commented lines are work-in-progress API calls to get the Nicehash profitability directly from NH

#NicehashDagger=curl -s -X GET "https://api2.Nicehash.com/main/api/v2/legacy?method=simplemultialgo.info" | jq -r '.result.simplemultialgo[] | select(.name == "DaggerHashimoto") | .paying'

#echo $(curl -s -X GET "https://api2.Nicehash.com/main/api/v2/legacy?method=simplemultialgo.info" | jq -r '.result.simplemultialgo[] | select(.name == "DaggerHashimoto") | .paying')*28*$(curl -s -X GET "https://api.pro.coinbase.com/products/BTC-USD/ticker" | jq -r '.price') | bc
