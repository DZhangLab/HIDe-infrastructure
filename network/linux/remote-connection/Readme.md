# Connecting Remotely to Hyperledger Fabric
Following the steps will help you connect with Hyper Ledger Fabric running on EC2 instance on AWS from your local machine
## Update the connection profile and EC2 instance endpoints
a. Locate the connection profile (connection.json) in the directory (e.g fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/).
b. Replace the "localhost" address in the connection.json file with the public IP or DNS of your Amazon EC2 instance for all the peers, orderers, and certificate authorities.
c. Save the changes.

### Set up the EC2 instance and security group:
a. Launch an Amazon EC2 instance with an appropriate Linux AMI.
b. Configure the security group to allow incoming traffic on required ports (typically 7050, 7051, 7053, 7054, and 22 for SSH).

| Port Number | Service | Container |
| --- | --- | --- |
| 22 | SSH (Secure Shell) | EC2 Instance |
| 7050 | Orderer service communication | orderer.example.com |
| 7051 | Peer service communication (Org1) | peer0.org1.example.com |
| 7053 | Orderer service communication (alternate) | orderer.example.com |
| 7054 | Fabric CA server (Org1) | ca_org1 |
| 8054 | Fabric CA server (Org2) | ca_org2 |
| 9051 | Peer service communication (Org2) | peer0.org2.example.com |
| 9443 | Orderer service communication (TLS) | orderer.example.com |
| 9444 | Peer service communication (Org1, TLS) | peer0.org1.example.com |
| 9445 | Peer service communication (Org2, TLS) | peer0.org2.example.com |
| 17054 | Fabric CA server (Org1, operations service) | ca_org1 |
| 18054 | Fabric CA server (Org2, operations service) | ca_org2 |

These port numbers correspond to the communication channels used by the different components of Hyperledger Fabric network.

### Open the security group associated with the EC2 instance. 
Make sure it has inbound rules that allow connections to the required ports (e.g., 7051 for the peer service). You can edit the security group settings in the AWS Management Console by navigating to the EC2 Dashboard, selecting "Security Groups" in the left menu, and editing the inbound rules for the security group associated with your instance.

Example:
```
Type: Custom TCP Rule
Protocol: TCP
Port Range: 7051
Source: 0.0.0.0/0 (or specify your local machine's IP address for better security)
```
## Assigning Elastic IP
If your EC2 instance's public IP address changes frequently (because of powering on and off), there are two options to avoid hardcoding the IP address in the connection-org1.json and connection-org2.json files:

### Assign an Elastic IP to the EC2 instance:

An Elastic IP is a static public IPv4 address that you can associate with your EC2 instance. It remains fixed even when you restart the instance. This way, you can use the Elastic IP address in your connection profiles and not worry about it changing.

To allocate and associate an Elastic IP to your EC2 instance:

Go to the AWS Management Console and navigate to the EC2 Dashboard.
In the left menu, click on "Elastic IPs" under "Network & Security."
Click "Allocate new address" and follow the instructions to create a new Elastic IP.
Once the Elastic IP is created, select it in the list, click "Actions," and choose "Associate Elastic IP address."

Select the EC2 instance from the list and associate the Elastic IP with it.
After you've associated the Elastic IP with your EC2 instance, update your connection profiles with the new Elastic IP address.

### Use a Dynamic DNS service:

A Dynamic DNS service allows you to assign a domain name to your EC2 instance that automatically updates its IP address when it changes. You can use this domain name in your connection profiles instead of the IP address. There are several Dynamic DNS providers available, such as No-IP, Dyn, and DuckDNS.

To use a Dynamic DNS service, follow these steps:

Sign up for a Dynamic DNS service and create a hostname that points to your EC2 instance's current public IP address. Install and configure a Dynamic DNS client on your EC2 instance. The client periodically checks your instance's public IP address and updates the DNS record with the new IP address if it changes. Update your connection profiles with the Dynamic DNS hostname instead of the IP address. Note that depending on your use case and the Dynamic DNS provider, there might be additional costs or limitations. Make sure to check the provider's documentation and pricing before proceeding with this option.

Choose the option that best suits your needs and update your connection profiles accordingly. This way, you won't need to hardcode the IP address in the connection-org1.json and connection-org2.json files.

# Checking connection without a client application

Test connection using telnet:

To test the connection using telnet, open a terminal on your local machine and run the following command (replace [EC2_INSTANCE_EXTERNAL_IP] with the external IP address of your EC2 instance, and [PORT_NUMBER] with the port number you want to test):
```
telnet [EC2_INSTANCE_EXTERNAL_IP] [PORT_NUMBER]
```

For example, to test the connection to the peer service:
```
telnet [EC2_INSTANCE_EXTERNAL_IP] 7051
```
If the connection is successful, you will see an output like this:
```
Trying [EC2_INSTANCE_EXTERNAL_IP]... Connected to [EC2_INSTANCE_EXTERNAL_IP]. Escape character is '^]'. Press Ctrl + ] and then type quit followed by Enter to close the telnet session.
```
You can check it out right now:
```
telnet 44.213.44.2 7051
```
#Testing the connection without a client application:

If you don't have a client application yet, you can use the fabric-samples repository to test the connection from your local machine to the EC2 instance:

Clone the fabric-samples repository:

```
git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
``` 

Install the prerequisites and binaries: Follow the instructions in the fabric-samples repository to install the required prerequisites and binaries: [https://github.com/hyperledger/fabric-samples#install-prerequisites](https://github.com/hyperledger/fabric-samples#install-prerequisites)

Copy the updated connection profile from your EC2 instance to your local machine. Place the file in the fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/ directory.

Use the peer CLI tool to test the connection. In this example, we will query the installed chaincodes on the peer:

```export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=[EC2_INSTANCE_EXTERNAL_IP]:7051

peer lifecycle chaincode queryinstalled 
```

Replace [EC2_INSTANCE_EXTERNAL_IP] with the external IP address of your EC2 instance. If the connection is successful, you should see the installed chaincodes on the peer. If there are no chaincodes installed, the output should be an empty list.

