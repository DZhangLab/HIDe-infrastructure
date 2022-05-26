
#!/bin/bash
docker rmi -f `docker images bc* -aq`
