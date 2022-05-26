
#!/bin/bash
fabric-ca-client enroll  -u https://admin:adminpw@ca.clinicOrg.com:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.clinicOrg.com-cert.pem 
fabric-ca-client affiliation add clinicorg  -u https://admin:adminpw@ca.clinicOrg.com:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.clinicOrg.com-cert.pem 
