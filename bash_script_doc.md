# blockchain-health-identity
## Bash Scripting

Bash Scripts are files with .sh extension that execute command line commands programatically. These files are useful to automate execution of commands. The following are useful to configure our network scripts:

1. All bash files start with this line to designate as a shell file
```bash
#!/bin/bash
```
2. chmod - changes file permissions. Useful if you get the error "Permission Denied"
```bash
chmod u+x file.sh
```
3. export - export any variables outside the script to use it in the script. These are called environment variables
```bash
export PATH="$HOME/bin/:$PATH"
```
4. import other .sh scripts just by listing the relative directory
```bash
scripts/utils.sh
```
5. echo - displaying lines of text or string which are passed as arguments on the command line
```bash
echo file.sh
```
6.  $variable - get value of a local variable. Shell variables have no data type, just simply strings. Use letters, numbers, underscore. Case-sensitive. Some reserved variables include PATH, HOME, IFS etc.
```bash
variable = "test"
echo $variable
new_test = "new_${variable}"
echo $new_test
```
7. /dev/null 2>&1 - null space to dump any useless output
```bash
fabric-ca-client version > /dev/null 2>&1
```
8. $1, $2 .... - accessing parameters
```bash
./file.sh param1 param2
```
Within the file, we can do the following:

```bash
var1 = $1 #param1
var2 = $2 #param2
```
9. Conditional Statements - if there is no arguments with the file, print error message. We can check for certain flags

```bash
if [[ ! $1 ]]; then
    echo "Error: missing parameter: container name"
    exit 1
else
    echo "Argument exists"
fi

if [[ -e $filename ]] #File exists
if [[ -d $dirname ]] #directory exists
```

10. Loops - for/while
```bash
#printing out the unsupported versions from a list of non working versions
for UNSUPPORTED_VERSION in $NONWORKING_VERSIONS; do
    infoln "$UNSUPPORTED_VERSION" 
done
#if the directory does not exist, keep sleeping else break out of the loop
while :
    do
      if [ ! -f "organizations/fabric-ca/org1/tls-cert.pem" ;then
        sleep 1
      else
        break
      fi
done
```
15. Call functions within your script
```bash
function deployCC() {
  scripts/deployCC.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE

  if [ $? -ne 0 ]; then
    fatalln "Deploying chaincode failed"
  fi
}
deployCC $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE
```
16. Execute script

```bash
./file.sh arg1 arg2
```
