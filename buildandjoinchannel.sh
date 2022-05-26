#!/bin/bash

echo "Building channel for rdis" 
export CHANNEL_NAME="rdis"



#Register the channel with orderer

. setpeer.sh HospitalOrg peer0
peer channel create -o orderer0.ordererOrg.net:7050 -c $CHANNEL_NAME -f ./rdis.tx --tls true --cafile $ORDERER_CA -t 1000s

# Joining rdis for org peers of HospitalOrg


. setpeer.sh HospitalOrg peer0
peer channel join -b $CHANNEL_NAME.block


. setpeer.sh HospitalOrg peer1
peer channel join -b $CHANNEL_NAME.block


. setpeer.sh HospitalOrg peer2
peer channel join -b $CHANNEL_NAME.block


#Update the anchor peers for org HospitalOrg
. setpeer.sh HospitalOrg peer0
peer channel update -o  orderer0.ordererOrg.net:7050 -c $CHANNEL_NAME -f ./rdisHospitalOrgMSPAnchor.tx --tls --cafile $ORDERER_CA 

# Joining rdis for org peers of ClinicOrg


. setpeer.sh ClinicOrg peer0
peer channel join -b $CHANNEL_NAME.block


. setpeer.sh ClinicOrg peer1
peer channel join -b $CHANNEL_NAME.block


#Update the anchor peers for org ClinicOrg
. setpeer.sh ClinicOrg peer0
peer channel update -o  orderer0.ordererOrg.net:7050 -c $CHANNEL_NAME -f ./rdisClinicOrgMSPAnchor.tx --tls --cafile $ORDERER_CA 
