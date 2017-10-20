#!/bin/bash
set -e

mkdir -p ./tmp/

# -------------------------------------------------- #
######          krs with nofx
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/krs-one-ny.mp3 | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(md5 ./test-files/krs-one-ny.mp3 | perl -pe 's/.+= //g')"
TIMETOOK="$(gtime -f '%e' ./onetime -e ./test-files/krs-one-ny.mp3 ./test-files/thedecline.mp3 --output ./tmp/myciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(md5 ./tmp/myciphertext | perl -pe 's/.+= //g')"
./onetime --decrypt ./tmp/myciphertext ./test-files/thedecline.mp3 -o ./tmp/original.mp3
DECRYPTEDMD5="$(md5 ./tmp/original.mp3 | perl -pe 's/.+= //g')"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "KRS-One test passed"
    echo "krs ($THESIZE) took $TIMETOOK seconds"
else
    echo "KRS-One test failed" 1>&2;
    exit 1
fi
echo

# -------------------------------------------------- #
#####          nofx with krs
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/thedecline.mp3 | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(md5 ./test-files/thedecline.mp3 | perl -pe 's/.+= //g')"
TIMETOOK="$(gtime -f '%e' ./onetime ./test-files/thedecline.mp3 ./test-files/krs-one-ny.mp3 2>&1 > /dev/null)"
mv thedecline.mp3.pad ./tmp/
CHANGEDMD5="$(md5 ./tmp/thedecline.mp3.pad | perl -pe 's/.+= //g')"
./onetime -d ./tmp/thedecline.mp3.pad ./test-files/krs-one-ny.mp3 2>&1 > /dev/null
mv ./original ./tmp/original
DECRYPTEDMD5="$(md5 ./tmp/original | perl -pe 's/.+= //g')"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "NOFX test passed"
    echo "nofx ($THESIZE) took $TIMETOOK seconds"
else
    echo "NOFX test failed" 1>&2;
    exit 1
fi
echo


# -------------------------------------------------- #
######    madame bovary with tale of two cities
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/madame-bovary.txt | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(md5 ./test-files/madame-bovary.txt | perl -pe 's/.+= //g')"
TIMETOOK="$(gtime -f '%e' ./onetime --encrypt ./test-files/madame-bovary.txt ./test-files/tale-of-two-cities.txt --output ./tmp/ciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(md5 ./tmp/ciphertext | perl -pe 's/.+= //g')"
./onetime -d ./tmp/ciphertext ./test-files/tale-of-two-cities.txt -o ./tmp/original.txt 2>&1 > /dev/null
DECRYPTEDMD5="$(md5 ./tmp/original.txt | perl -pe 's/.+= //g')"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "Madame Bovary test passed"
    echo "madame bovary ($THESIZE) took $TIMETOOK seconds"
else
    echo "Madame Bovary test failed" 1>&2;
    exit 1
fi
echo


# -------------------------------------------------- #
######    tale of two cities with madame bovary
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/tale-of-two-cities.txt | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(md5 ./test-files/tale-of-two-cities.txt | perl -pe 's/.+= //g')"
TIMETOOK="$(gtime -f '%e' ./onetime -e ./test-files/tale-of-two-cities.txt ./test-files/madame-bovary.txt -o ./tmp/ciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(md5 ./tmp/ciphertext | perl -pe 's/.+= //g')"
./onetime -d ./tmp/ciphertext ./test-files/madame-bovary.txt -o ./tmp/original.txt 2>&1 > /dev/null
DECRYPTEDMD5="$(md5 ./tmp/original.txt | perl -pe 's/.+= //g')"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "Tale of Two Cities test passed"
    echo "tale of two cities ($THESIZE) took $TIMETOOK seconds"
else
    echo "Tale of Two Cities test failed" 1>&2;
    exit 1
fi
echo


# -------------------------------------------------- #
######   linux kernel with itself
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/linux-4.13.8.tar.xz | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(md5 ./test-files/linux-4.13.8.tar.xz | perl -pe 's/.+= //g')"
TIMETOOK="$(gtime -f '%e' ./onetime -e ./test-files/linux-4.13.8.tar.xz ./test-files/linux-4.13.8.tar.xz -o ./tmp/ciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(md5 ./tmp/ciphertext | perl -pe 's/.+= //g')"
./onetime -d ./tmp/ciphertext ./test-files/linux-4.13.8.tar.xz -o ./tmp/original.tar.xz 2>&1 > /dev/null
DECRYPTEDMD5="$(md5 ./tmp/original.tar.xz | perl -pe 's/.+= //g')"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "Linux Kernel Archine test passed"
    echo "kernel archive ($THESIZE) took $TIMETOOK seconds"
else
    echo "Linux Kernel Archive test failed" 1>&2;
    exit 1
fi
echo

rm -rf ./tmp/
exit 0
