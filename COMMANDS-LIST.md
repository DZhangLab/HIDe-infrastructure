# blockchain-health-identity

### Notes

- Commands are known to work for Windows 11 
!! TODO Katherine add Mac commands

### List of Commands

- list all running docker containers

```
docker ps -a
```

- brings the network up
```
./network.sh up
```

- Clean up any previously run containers 
```
./network.sh down
```

- Create a channel 
```
./network.sh createChannel
```

- Create a channel when the network goes up
```
./network.sh up createChannel -c mychannel
```

- Create a channel with certificates when the network goes up
```
./network.sh up createChannel -c mychannel -ca
```

- Deploys chaincode 
```
./network.sh deployCC 
```

- Returns the information about the channelname
```
peer channel getinfo -c channelname
```

- Updates the channel
```
peer channel update
```

- Fetches the information about the channelname
```
peer channel fetch
```

- Joins the channel
```
peer channel join -b
```

- Invokes chaincode on the channel
```
peer chaincode invoke -o
```

- Query chaincode
```
peer chaincode query -o
```

- List the versions of wsl installed and running
```
wsl -l -v
```

-  Configuring dev environment, should return false
```
git config --global core.autocrlf
```

- Connfiguring paths, should return true

```
git config --global core.longpaths
```

- Set the linux version to ubuntu

```
wsl -s Ubuntu
```

- Get HF images
```
curl -sSL https://bit.ly/2ysbOFE | bash -s
```

