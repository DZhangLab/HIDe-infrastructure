
#!/bin/bash
export ORDERER_CA=/opt/ws/crypto-config/ordererOrganizations/ordererOrg.net/msp/tlscacerts/tlsca.ordererOrg.net-cert.pem

#For fabric 2.2.x extra environment variables

export HOSPITALORG_PEER0_CA=/opt/ws/crypto-config/peerOrganizations/hospitalOrg.com/peers/peer0.hospitalOrg.com/tls/ca.crt

export CLINICORG_PEER0_CA=/opt/ws/crypto-config/peerOrganizations/clinicOrg.com/peers/peer0.clinicOrg.com/tls/ca.crt



if [ $# -lt 2 ];then
	echo "Usage : . setpeer.sh HospitalOrg|ClinicOrg| <peerid>"
fi
export peerId=$2

if [[ $1 = "HospitalOrg" ]];then
	echo "Setting to organization HospitalOrg peer "$peerId
	export CORE_PEER_ADDRESS=$peerId.hospitalOrg.com:7051
	export CORE_PEER_LOCALMSPID=HospitalOrgMSP
	export CORE_PEER_TLS_CERT_FILE=/opt/ws/crypto-config/peerOrganizations/hospitalOrg.com/peers/$peerId.hospitalOrg.com/tls/server.crt
	export CORE_PEER_TLS_KEY_FILE=/opt/ws/crypto-config/peerOrganizations/hospitalOrg.com/peers/$peerId.hospitalOrg.com/tls/server.key
	export CORE_PEER_TLS_ROOTCERT_FILE=/opt/ws/crypto-config/peerOrganizations/hospitalOrg.com/peers/$peerId.hospitalOrg.com/tls/ca.crt
	export CORE_PEER_MSPCONFIGPATH=/opt/ws/crypto-config/peerOrganizations/hospitalOrg.com/users/Admin@hospitalOrg.com/msp
fi

if [[ $1 = "ClinicOrg" ]];then
	echo "Setting to organization ClinicOrg peer "$peerId
	export CORE_PEER_ADDRESS=$peerId.clinicOrg.com:7051
	export CORE_PEER_LOCALMSPID=ClinicOrgMSP
	export CORE_PEER_TLS_CERT_FILE=/opt/ws/crypto-config/peerOrganizations/clinicOrg.com/peers/$peerId.clinicOrg.com/tls/server.crt
	export CORE_PEER_TLS_KEY_FILE=/opt/ws/crypto-config/peerOrganizations/clinicOrg.com/peers/$peerId.clinicOrg.com/tls/server.key
	export CORE_PEER_TLS_ROOTCERT_FILE=/opt/ws/crypto-config/peerOrganizations/clinicOrg.com/peers/$peerId.clinicOrg.com/tls/ca.crt
	export CORE_PEER_MSPCONFIGPATH=/opt/ws/crypto-config/peerOrganizations/clinicOrg.com/users/Admin@clinicOrg.com/msp
fi

	