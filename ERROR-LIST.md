# blockchain-health-identity

## List of Errors 
Solutions are a W.I.P. Please add your solution if it worked for you.

#### Format
```diff
- Error Message
# What the error means
+ Potential Solution
```

***
#### Resolved Errors
```diff
- “Error: could not assemble transaction, 
- err proposal response was not successful, 
- error code 500, msg error starting container: 
- error starting container: 
- Post "http://unix.sock/containers/create?name=dev-peer0.org2.example.com-mycc-1.0": 
- dial unix /host/var/run/docker.sock: connect: no such file or directory
# The linux system could not connect to docker and therefore can't access any files
+ Make sure docker is up and running by using the app 
+ Running the commands `sudo systemctl start docker`
+ Alternatively, you may need to mount the socket but this is the least likely option
+ Instructions here: https://stackoverflow.com/questions/55173477/hyperledger-fabric-dial-unix-host-var-run-docker-sock-connect-no-such-file-o
```

```diff
- need mac error from katherine
# You have a memory leak somewhere and the docker containers are responding to the commands
# but the containers are not the ones linked to the current batch script
+ Manually delete the docker files by puttind the network down and following the commands here
+ to force stop all containers and force remove all containers
+ https://docs.docker.com/engine/reference/commandline/rm/
+ Follow up by removing any custom network connections
+ docker network prune
+ You should now be able to put the network up, create correctly linked containers, and access them.
```

```diff
- Cloning into 'fabric-samples'...
- error: chmod on /mnt/c/Users/ytan1/fabric-samples/.git/config.lock failed: 
- Operation not permitted
- fatal: could not set 'core.filemode' to 'false'
- fabric-samples v2.4.2 does not exist, defaulting to main. 
- fabric-samples main branch is intended to work with recent versions of fabric.
- fatal: not a git repository (or any parent up to mount point /mnt)
- Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).
# Something went wrong with curling the fabric samples so the installation
# variables and depdendencies need to be checked.
+ Ensure that your dev environment is correctly setup according to section 1
+ of the README.md file with WSL2 enabled on docker if you are on windows
+ Also doublecheck that the file you are cloning into is not a pre-existing 
+ non-empty folder on your remote branch.
```

```diff
- error bash/rc not found or installed
# What the error means
+ The version of npm you currently have may be too old. 
+ Update your linux package lists and upgrade them to the most recent ones.
+ You have to address only the specific npm/nodejs package and the version.
+ Alternatively, you may need to doublecheck that your paths are correct in 
+ your computer's list of environment variables.
```

```diff
- docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. 
- Is the docker daemon running?.
# The linux command prompt is unable to see docker at all.
+ Check that your docker app is up, running, and accessible.
+ If you are on windows, double check that your WSL2 integration is enabled.
```
'
```diff
- - Error: Cannot find module '/home/peitan/go/src/github.com/pei-shan-tan/fabric-samples/asset-transfer-basic/application-gateway-typescript/dist/app.js'
- at Function.Module._resolveFilename (internal/modules/cjs/loader.js:636:15)
- at Function.Module._load (internal/modules/cjs/loader.js:562:25)
- at Function.Module.runMain (internal/modules/cjs/loader.js:831:12)
- at startup (internal/bootstrap/node.js:283:19)
- at bootstrapNodeJSCore (internal/bootstrap/node.js:623:3)
- npm ERR! code ELIFECYCLE
- npm ERR! errno 1
# The pathing is not correct and cannot locate the app.
+ Try using a different ccl to instantiate the chaincode.
```

```diff
- no matching manifest for linux/arm64/v8 in the manifest list entries
# Binaries for the docker images are not supported. I got this error on Macbook Pro 14in running apple silicon
+ For each failed image. Do this (here is an example for one.
+ Error: 2.2.0: Pulling from hyperledger/fabric-peer
+       no matching manifest for linux/arm64/v8 in the manifest list entries
+ Fix: docker pull --platform amd64 hyperledger/fabric-peer:2.2.0
+ Change version if necessary. fabric-ca (certificate authority) should be version 1.4.9
```

```diff
- ERROR: manifest for hyperledger/fabric-tools:latest not found
- unable to install a specific version of the docker image. happnes with latest
# the network is looking for a spefific tag of the docker image and is not able to locate it
+ change the tag with the command (replace fabric-peer with your own image)
+ docker tag hyperledger/fabric-peer:2.2.0 hyperledger/fabric-peer:latest
```

#### Unresolved Errors

```
Error: endorsement failure during invoke. response: status:500 message:"a client from Org2MSP cannot update the description of an asset owned by Org1MSP"
```

```
"Error response from daemon: mkdir C:\Program Files\Git\var: Access is denied."
```

```
Error: chaincode install failed with status: 500 - failed to invoke backing implementation of 'InstallChaincode': could not build chaincode: docker build failed: docker image build failed: docker build failed: Error returned from build: 1 "go: inconsistent vendoring in /chaincode/input/src:
        github.com/golang/protobuf@v1.3.2: is explicitly required in go.mod, but not marked as explicit in vendor/modules.txt
```

```
WARNING: The DOCKER_SOCK variable is not set. Defaulting to a blank string.
WARNING: Some networks were defined but are not used by any service: test
Creating network "docker_default" with the default driver
Creating peer0.org3.example.com ... error

ERROR: for peer0.org3.example.com  Cannot create container for service peer0.org3.example.com: create .: volume name is too short, names should be at least two alphanumeric characters

ERROR: for peer0.org3.example.com  Cannot create container for service peer0.org3.example.com: create .: volume name is too short, names should be at least two alphanumeric characters
ERROR: Encountered errors while bringing up the project.
```

```
EndorseError: 10 ABORTED: failed to endorse transaction, see attached details for more info
    at ... {
  code: 10,
  details: [
    {
      address: 'peer0.org1.example.com:7051',
      message: 'error in simulation: transaction returned with failure: Error: The asset asset70 does not exist',
      mspId: 'Org1MSP'
    }
  ],
  cause: Error: 10 ABORTED: failed to endorse transaction, see attached details for more info
      at ... {
    code: 10,
    details: 'failed to endorse transaction, see attached details for more info',
    metadata: Metadata { internalRepr: [Map], options: {} }
  },
  transactionId: 'a92980d41eef1d6492d63acd5fbb6ef1db0f53252330ad28e548fedfdb9167fe'
}
```

```
tar: bin/cryptogen: Cannot utime: Operation not permitted
tar: bin: Cannot utime: Operation not permitted
tar: bin: Cannot change mode to rwxr-xr-x: Operation not permitted
tar: config/orderer.yaml: Cannot utime: Operation not permitted
tar: config/core.yaml: Cannot utime: Operation not permitted
tar: config/configtx.yaml: Cannot utime: Operation not permitted
tar: config: Cannot utime: Operation not permitted
tar: config: Cannot change mode to rwxr-xr-x: Operation not permitted
tar: Exiting with failure status due to previous errors
==> There was an error downloading the binary file.
```
