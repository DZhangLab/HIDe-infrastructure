
#!/bin/bash
fabric-ca-client enroll  -u https://admin:adminpw@ca.rapidseller.net:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.rapidseller.net-cert.pem 
fabric-ca-client affiliation add seller  -u https://admin:adminpw@ca.rapidseller.net:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.rapidseller.net-cert.pem 
