#!/bin/bash

# Pick-a-Coin - davenport651
# Get some values from pools and exchanges to automagically pick a coin to mine.

EthHashRate='27.9'

#Obtains USD value per day of coins from cruxpool, coinbase, and whattomine api...
#This also strips out the leading zero and the trailing characters because bash can only compare integers.
ETCperDay=$(echo $(curl -s -X GET "https://www.cruxpool.com/api/etc/estimatedEarnings/$EthHashRate" -H  "accept: application/json" | jq -r '.data.estEarningsPerDay')*$(curl -s -X GET "https://api.pro.coinbase.com/products/ETC-USD/ticker" | jq -r '.price') | bc -l | cut -c2- | head -c 9)
ETHperDay=$(echo $(curl -s -X GET "https://www.cruxpool.com/api/eth/estimatedEarnings/$EthHashRate" -H  "accept: application/json" | jq -r '.data.estEarningsPerDay')*$(curl -s -X GET "https://api.pro.coinbase.com/products/ETH-USD/ticker" | jq -r '.price') | bc -l | cut -c2- | head -c 9)
NiceHash=$(echo $(curl -s -X GET "https://whattomine.com/coins.json?adapt_q_570=1&adapt_570=true&eth=true&factor%5Beth_hr%5D=27.90&factor%5Beth_p%5D=101.00&factor%5Bcost%5D=0&sort=Profitability24&volume=0&revenue=24h&dataset=&commit=Calculate.json" | jq -r '.coins."Nicehash-Ethash"."btc_revenue24"')*$(curl -s -X GET "https://api.pro.coinbase.com/products/BTC-USD/ticker" | jq -r '.price') | bc -l | cut -c2- | head -c 9)

echo ETC Rev = .$ETCperDay
echo ETH Rev = .$ETHperDay
echo Nicehash Rev = .$NiceHash

#This 100% won't work with any decimal places
if [ "$ETCperDay" -ge "$ETHperDay" ] && [ "$ETCperDay" -ge "$NiceHash" ] ; then
	echo Starting Eth Classic Miner...
elif [ $ETHperDay -ge $ETCperDay ] && [ "$ETHperDay" -ge "$NiceHash" ] ; then
	echo Starting Ethereum Miner...
elif [ "$NiceHash" -ge "$ETCperDay" ] && [ "$NiceHash" -ge "$ETHperDay" ] ; then
	echo Starting Nicehash...
else
	echo Something went wrong.
fi


#API's directly from nicehash that I'm trying to make work to replace whattomine...
#NiceHashDagger=curl -s -X GET "https://api2.nicehash.com/main/api/v2/legacy?method=simplemultialgo.info" | jq -r '.result.simplemultialgo[] | select(.name == "DaggerHashimoto") | .paying'

#echo $(curl -s -X GET "https://api2.nicehash.com/main/api/v2/legacy?method=simplemultialgo.info" | jq -r '.result.simplemultialgo[] | select(.name == "DaggerHashimoto") | .paying')*28*$(curl -s -X GET "https://api.pro.coinbase.com/products/BTC-USD/ticker" | jq -r '.price') | bc
