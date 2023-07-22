# Run Hyperledger Fabric locally via Kubernetes

## Create Kubernetes cluster 
You will need a Kubernetes cluster to work with. For this walkthrough we'll use [KIND](https://kind.sigs.k8s.io/docs/user/quick-start/)


## Stand up Hyperledger Fabric on your Kubernetes Cluster

### Via Script

You can run this script to run all the steps:

1. Copy the script `start` which is in this directory to the `test-network-k8s` directory where you cloned the [Fabric Samples repository](https://github.com/hyperledger/fabric-samples). 

1. Change directories into the `test-network-k8s` directory.

2. Run the script: 
    ```
    mv start.txt start
    chmod +x start
    ./start
    ```

### Via Steps
#### Clone 

1. git clone git@github.com:hyperledger/fabric-samples.git
1. go into the cloned directory, in the test-network-k8s directory 
    - cd ~/fabric-samples/test-network-k8s 

#### Install kind test-network support
    ./network kind 

#### Initialize Kubernetes components needed to run Hyperledger 
    ./network cluster init

#### Check the components were created

    kubectl get namespaces

Note the cert-manager and ingress-nginx namespaces were created 

#### Start up the Hyperledger Fabric network
    ./network up 

#### Check that the network components came up 
    kubectl get namespaces
    kubectl get all -n test-network

#### Create a channel (as usual)
    ./network create 

## Set anchor peer
    ./network anchor peer2

## Deploy chaincode 
    ./network chaincode deploy asset-transfer-basic ../asset-transfer-basic/chaincode-go 

