## Installation steps Unzip and place the contents generated in a directory. 
The directory is referred as <network>.  
All the commands must be executed from  <network> directory.  
## First time setup instructions ( START) 
## First time setup. Run the following commands 
 1. Download the binaries 
```sh 
 . ./downloadbin.sh 
``` 

 2. To Generate the cryto config and other configurations
 ```sh 
 . ./generateartifacts.sh 

``` 

 3. Create the chain code directiory.
```sh 

  export NETWORKDIR=`pwd` 
  mkdir -p chaincode/github.com/rdis 
  cd chaincode/github.com/rdis 
 # Copy the chain code source files here 

  go mod vendor
  cd $NETWORKDIR 

``` 

 4. Start the netowrk  

```sh 
  . setenv.sh 
  docker-compose up -d 
``` 

 5. Run organization affiliation script for add organization for each orgs
```sh 
  docker exec -it ca.<org domain name> bash -e add_affiliation_<org_name>.sh 
``` 

 6. Build and join channel. Make sure that network is running 

```sh 
   docker exec -it cli bash -e ./buildandjoinchannel.sh 

``` 

 7. Install and intantiate the chain codes 
```sh 
  docker exec -it cli bash -e  ./rdis_install.sh
``` 
##  First time setup instructions ( END) 


 ## When chain code is modified ( START) 
 To update the chain code , first update the chain code source files in the above mentioned directory.
Then run the following commands as appropriate

```sh 
  docker exec -it cli bash -e  ./rdis_update.sh <version>
``` 
## When chain code is modified ( END) 


## To bring up an existing network ( START) 
``` 
  . setenv.sh 
  docker-compose up -d 
``` 
## To bring up an existing network ( END) 


##To destory  an existing network ( START) 
``` 
  . setenv.sh 
  docker-compose down 
``` 
 If you are stoping a network using the above commands , 
 to start the network again , you have to execute steps 2,5,6,7 of the first time setup.
 

## To destory  an existing network ( END) 
