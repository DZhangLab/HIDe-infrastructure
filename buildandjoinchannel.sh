#!/bin/bash

echo "Building channel for sales" 
export CHANNEL_NAME="sales"



#Register the channel with orderer

. setpeer.sh Buyer peer0
peer channel create -o orderer0.orderer.net:7050 -c $CHANNEL_NAME -f ./sales.tx --tls true --cafile $ORDERER_CA -t 1000s

# Joining sales for org peers of Buyer


. setpeer.sh Buyer peer0
peer channel join -b $CHANNEL_NAME.block


. setpeer.sh Buyer peer1
peer channel join -b $CHANNEL_NAME.block


#Update the anchor peers for org Buyer
. setpeer.sh Buyer peer0
peer channel update -o  orderer0.orderer.net:7050 -c $CHANNEL_NAME -f ./salesBuyerMSPAnchor.tx --tls --cafile $ORDERER_CA 

# Joining sales for org peers of Seller


. setpeer.sh Seller peer0
peer channel join -b $CHANNEL_NAME.block


. setpeer.sh Seller peer1
peer channel join -b $CHANNEL_NAME.block


#Update the anchor peers for org Seller
. setpeer.sh Seller peer0
peer channel update -o  orderer0.orderer.net:7050 -c $CHANNEL_NAME -f ./salesSellerMSPAnchor.tx --tls --cafile $ORDERER_CA 
