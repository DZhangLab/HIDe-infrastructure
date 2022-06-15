#!/bin/bash

export VERSION=2.4.3
export CA_VERSION=1.5.3
# export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m |sed 's/x86_64/amd64/g')" |sed 's/darwin-arm64/darwin-amd64/g')

echo "===> Downloading platform binaries"
export URL="https://github.com/hyperledger/fabric/releases/download/v${VERSION}/hyperledger-fabric-${ARCH}-${VERSION}.tar.gz"
echo $URL
curl  -L $URL| tar xz

echo "===> Downloading fabric-ca-client binaries"
export URL2="https://github.com/hyperledger/fabric-ca/releases/download/v${CA_VERSION}/hyperledger-fabric-ca-${ARCH}-${CA_VERSION}.tar.gz"
curl -L $URL2| tar xz