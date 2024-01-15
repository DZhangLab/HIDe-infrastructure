# Run Hyperledger Fabric locally via Kubernetes

## 1. Stand up Hyperledger Fabric on your Kubernetes Cluster

This uses a tool call Kind which allows it to be set up without VMs in a very lightweight way. Kubernetes automates much of the process of standing up a network. These steps are based off of HLF's [fabric-samples Kubernetes example](https://github.com/hyperledger/fabric-samples/tree/main/test-network-k8s). 

Install [KIND](https://kind.sigs.k8s.io/docs/user/quick-start/). 

## 2. Install Hyperledger Fabric onto your Kubernetes

### Clone fabric-samples

1. git clone git@github.com:hyperledger/fabric-samples.git
1. go into the cloned directory, in the test-network-k8s directory 
    - cd ~/fabric-samples/test-network-k8s 

### Install kind test-network support
    ./network kind 

### Initialize Kubernetes components needed to run Hyperledger 
    ./network cluster init

### Check the components were created

    kubectl get namespaces

Note the cert-manager and ingress-nginx namespaces were created 

### Start up the Hyperledger Fabric network
    # add location of fabric binaries to PATH first
    export PATH="$PATH_TO_FABRIC_BIN:$PATH"
    
    ./network up 

### Check that the network components came up 
    kubectl get namespaces
    kubectl get all -n test-network

### Create a channel (as usual)
    ./network create 

### Set anchor peer
    ./network anchor peer2


## 3. Deploy a chaincode 
    ./network chaincode deploy asset-transfer-basic ../asset-transfer-basic/chaincode-go 

### Invoke chaincode
    ./network chaincode invoke asset-transfer-basic '{"Args":["InitLedger"]}'
    ./network chaincode query  asset-transfer-basic '{"Args":["ReadAsset","asset1"]}'

## 4. Use the REST API server to talk to the chaincode

    ./network rest-easy

Add an asset:
```
curl --include --header "Content-Type: application/json" --header "X-Api-Key: ${SAMPLE_APIKEY}" --request POST --data '{"ID":"asset7","Color":"red","Size":42,"Owner":"Jean","AppraisedValue":101}' http://fabric-rest-sample.localho.st/api/assets
```

Get a job ID back, and query this endpoint:
```
curl --header "X-Api-Key: ${SAMPLE_APIKEY}" http://fabric-rest-sample.localho.st/api/jobs/__job_id__
```

Get a transaction ID back and query this endpoint to see its status:
```
curl --header "X-Api-Key: ${SAMPLE_APIKEY}" http://fabric-rest-sample.localho.s/api/transactions/__transaction_id___
```

Query the asset to see it exists now:
```
curl -s --header "X-Api-Key: ${SAMPLE_APIKEY}" http://fabric-rest-sample.localho.st/api/assets/__asset_id__
```


*NOTE, you can execute the following script to run all the above steps:*

1. Copy the script `start` which is in this directory to the `test-network-k8s` directory where you cloned the [Fabric Samples repository](https://github.com/hyperledger/fabric-samples). Change the PATH_TO_FABRIC_BIN on second line to a path on your local machine that represent the bin folder in your fabric-samples directory.

1. Change directories into the `test-network-k8s` directory.

2. Run the script: 
    ```
    ./start
