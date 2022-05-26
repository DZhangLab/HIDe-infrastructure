
#!/bin/bash
fabric-ca-client enroll  -u https://admin:adminpw@ca.hospitalOrg.com:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.hospitalOrg.com-cert.pem 
fabric-ca-client affiliation add hospitalorg  -u https://admin:adminpw@ca.hospitalOrg.com:7054 --tls.certfiles /etc/hyperledger/fabric-ca-server-config/ca.hospitalOrg.com-cert.pem 
