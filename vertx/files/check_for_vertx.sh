#!/bin/bash

$(which vertx)

if [ $? == 1 ]; then

  echo -e \n
  echo "changed=yes comment='Vertx not found.. installing.'"

else

  echo -e \n
  echo "changed=no comment='Vertx is already installed.'"

fi
