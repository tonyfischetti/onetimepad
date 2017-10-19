#!/bin/bash

## krs
ORIGINALMD5 = `md5 ./test-files/krs-one-ny.mpg`
./onetime -e ./test-files/krs-one-ny.mpg ./test-files/thedecline.mp3 -o ./tmp/ciphertext
echo $ORIGINALMD5

