
#!/bin/bash
# export ORDERER_CA=/opt/ws/crypto-config/ordererOrganizations/orderer.net/msp/tlscacerts/tlsca.orderer.net-cert.pem
export ORDERER_CA=/crypto-config/ordererOrganizations/orderer.net/msp/tlscacerts/tlsca.orderer.net-cert.pem

#For fabric 2.2.x extra environment variables

# export BUYER_PEER0_CA=/opt/ws/crypto-config/peerOrganizations/superbuyer.com/peers/peer0.superbuyer.com/tls/ca.crt
export BUYER_PEER0_CA=/crypto-config/peerOrganizations/superbuyer.com/peers/peer0.superbuyer.com/tls/ca.crt

# export SELLER_PEER0_CA=/opt/ws/crypto-config/peerOrganizations/rapidseller.net/peers/peer0.rapidseller.net/tls/ca.crt
export SELLER_PEER0_CA=/crypto-config/peerOrganizations/rapidseller.net/peers/peer0.rapidseller.net/tls/ca.crt



if [ $# -lt 2 ];then
	echo "Usage : . setpeer.sh Buyer|Seller| <peerid>"
fi
export peerId=$2

if [[ $1 = "Buyer" ]];then
	echo "Setting to organization Buyer peer "$peerId
	export CORE_PEER_ADDRESS=$peerId.superbuyer.com:7051
	export CORE_PEER_LOCALMSPID=BuyerMSP
	# export CORE_PEER_TLS_CERT_FILE=/opt/ws/crypto-config/peerOrganizations/superbuyer.com/peers/$peerId.superbuyer.com/tls/server.crt
	export CORE_PEER_TLS_CERT_FILE=${PWD}/crypto-config/peerOrganizations/superbuyer.com/peers/$peerId.superbuyer.com/tls/server.crt

	# export CORE_PEER_TLS_KEY_FILE=/opt/ws/crypto-config/peerOrganizations/superbuyer.com/peers/$peerId.superbuyer.com/tls/server.key
	export CORE_PEER_TLS_KEY_FILE=${PWD}/crypto-config/peerOrganizations/superbuyer.com/peers/$peerId.superbuyer.com/tls/server.key

	# export CORE_PEER_TLS_ROOTCERT_FILE=/opt/ws/crypto-config/peerOrganizations/superbuyer.com/peers/$peerId.superbuyer.com/tls/ca.crt
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto-config/peerOrganizations/superbuyer.com/peers/$peerId.superbuyer.com/tls/ca.crt

	# export CORE_PEER_MSPCONFIGPATH=/opt/ws/crypto-config/peerOrganizations/superbuyer.com/users/Admin@superbuyer.com/msp
	export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/superbuyer.com/users/Admin@superbuyer.com/msp

fi

if [[ $1 = "Seller" ]];then
	echo "Setting to organization Seller peer "$peerId
	export CORE_PEER_ADDRESS=$peerId.rapidseller.net:7051
	export CORE_PEER_LOCALMSPID=SellerMSP
	# export CORE_PEER_TLS_CERT_FILE=/opt/ws/crypto-config/peerOrganizations/rapidseller.net/peers/$peerId.rapidseller.net/tls/server.crt
	# export CORE_PEER_TLS_KEY_FILE=/opt/ws/crypto-config/peerOrganizations/rapidseller.net/peers/$peerId.rapidseller.net/tls/server.key
	# export CORE_PEER_TLS_ROOTCERT_FILE=/opt/ws/crypto-config/peerOrganizations/rapidseller.net/peers/$peerId.rapidseller.net/tls/ca.crt
	# export CORE_PEER_MSPCONFIGPATH=/opt/ws/crypto-config/peerOrganizations/rapidseller.net/users/Admin@rapidseller.net/msp

	export CORE_PEER_TLS_CERT_FILE=${PWD}/crypto-config/peerOrganizations/rapidseller.net/peers/$peerId.rapidseller.net/tls/server.crt
	export CORE_PEER_TLS_KEY_FILE=${PWD}/crypto-config/peerOrganizations/rapidseller.net/peers/$peerId.rapidseller.net/tls/server.key
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto-config/peerOrganizations/rapidseller.net/peers/$peerId.rapidseller.net/tls/ca.crt
	export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/rapidseller.net/users/Admin@rapidseller.net/msp
fi

	