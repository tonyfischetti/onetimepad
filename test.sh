#!/bin/bash

# set -e

# some systems use this
# TIME="time"
# MD5="md5sum"

# other systems use this
TIME="gtime"
MD5="md5"


mkdir -p ./tmp/
rm -rf ./tmp/
mkdir -p ./tmp/


echo

GETHASH (){
    # for some computers, use this
    # $MD5 $1 | perl -pe 's/^(.+?)\s+.*/$1/g'
    # other systems use this
    $MD5 $1 | perl -pe 's/.+= //g'
}


# -------------------------------------------------- #
######          krs with nofx
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/krs-one-ny.mp3 | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(GETHASH ./test-files/krs-one-ny.mp3)"
TIMETOOK="$($TIME -f '%e' ./onetime --encrypt ./test-files/krs-one-ny.mp3 ./test-files/thedecline.mp3 --output ./tmp/myciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(GETHASH ./tmp/myciphertext)"
./onetime --decrypt ./tmp/myciphertext ./test-files/thedecline.mp3 -o ./tmp/original.mp3
DECRYPTEDMD5="$(GETHASH ./tmp/original.mp3)"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "KRS-One test passed"
    echo "krs ($THESIZE) took $TIMETOOK seconds"
else
    echo "KRS-One test failed" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
#####          nofx with krs
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/thedecline.mp3 | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(GETHASH ./test-files/thedecline.mp3)"
TIMETOOK="$($TIME -f '%e' ./onetime ./test-files/thedecline.mp3 ./test-files/krs-one-ny.mp3 2>&1 > /dev/null)"
mv ./thedecline.mp3.pad ./tmp/
CHANGEDMD5="$(GETHASH ./tmp/thedecline.mp3.pad)"
./onetime -d ./tmp/thedecline.mp3.pad ./test-files/krs-one-ny.mp3 2>&1 > /dev/null
mv ./thedecline.mp3 ./tmp/
DECRYPTEDMD5="$(GETHASH ./tmp/thedecline.mp3)"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "NOFX test passed"
    echo "nofx ($THESIZE) took $TIMETOOK seconds"
else
    echo "NOFX test failed" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######    madame bovary with tale of two cities
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/madame-bovary.txt | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(GETHASH ./test-files/madame-bovary.txt)"
TIMETOOK="$($TIME -f '%e' ./onetime --encrypt ./test-files/madame-bovary.txt ./test-files/tale-of-two-cities.txt --output ./tmp/ciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(GETHASH ./tmp/ciphertext)"
./onetime --decrypt ./tmp/ciphertext ./test-files/tale-of-two-cities.txt 2>&1 > /dev/null
mv ./decryptedfile ./tmp/
DECRYPTEDMD5="$(GETHASH ./tmp/decryptedfile)"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "Madame Bovary test passed"
    echo "madame bovary ($THESIZE) took $TIMETOOK seconds"
else
    echo "Madame Bovary test failed" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######    tale of two cities with madame bovary
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/tale-of-two-cities.txt | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(GETHASH ./test-files/tale-of-two-cities.txt)"
TIMETOOK="$($TIME -f '%e' ./onetime -e ./test-files/tale-of-two-cities.txt ./test-files/madame-bovary.txt -o ./tmp/ciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(GETHASH ./tmp/ciphertext)"
./onetime -d ./tmp/ciphertext ./test-files/madame-bovary.txt -o ./tmp/original.txt 2>&1 > /dev/null
DECRYPTEDMD5="$(GETHASH ./tmp/original.txt)"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "Tale of Two Cities test passed"
    echo "tale of two cities ($THESIZE) took $TIMETOOK seconds"
else
    echo "Tale of Two Cities test failed" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######   linux kernel with itself
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/linux-4.13.8.tar.xz | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(GETHASH ./test-files/linux-4.13.8.tar.xz)"
TIMETOOK="$($TIME -f '%e' ./onetime -e ./test-files/linux-4.13.8.tar.xz ./test-files/linux-4.13.8.tar.xz --output ./tmp/ciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(GETHASH ./tmp/ciphertext)"
./onetime -d ./tmp/ciphertext ./test-files/linux-4.13.8.tar.xz -o ./tmp/original.tar.xz 2>&1 > /dev/null
DECRYPTEDMD5="$(GETHASH ./tmp/original.tar.xz)"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "Linux Kernel Archine test passed"
    echo "kernel archive ($THESIZE) took $TIMETOOK seconds"
else
    echo "Linux Kernel Archive test failed" 1>&2;
    exit 1
fi
echo
echo
rm -rf ./tmp/
mkdir -p ./tmp/

echo "---"
echo "now testing files with unicode characters"
echo "---"
echo

# -------------------------------------------------- #
######          krs with nofx unicode 1
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/krs-💯💯💯.mp3 | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(GETHASH ./test-files/krs-💯💯💯.mp3)"
TIMETOOK="$($TIME -f '%e' ./onetime -e ./test-files/krs-💯💯💯.mp3 ./test-files/thedecline.mp3 --output ./tmp/myciphertext 2>&1 > /dev/null)"
CHANGEDMD5="$(GETHASH ./tmp/myciphertext)"
./onetime --decrypt ./tmp/myciphertext ./test-files/thedecline.mp3 -o ./tmp/original.mp3
DECRYPTEDMD5="$(GETHASH ./tmp/original.mp3)"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "KRS-One Unicode 1 test passed"
    echo "krs ($THESIZE) took $TIMETOOK seconds"
else
    echo "KRS-One Unicode 1 test failed" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######          krs with krs unicode 2
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/krs-💯💯💯.mp3 | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(GETHASH ./test-files/krs-💯💯💯.mp3)"
TIMETOOK="$($TIME -f '%e' ./onetime -e ./test-files/krs-💯💯💯.mp3 ./test-files/krs-💯💯💯.mp3 2>&1 > /dev/null)"
mv krs-💯💯💯.mp3.pad ./tmp/
CHANGEDMD5="$(GETHASH ./tmp/krs-💯💯💯.mp3.pad)"
./onetime --decrypt ./tmp/krs-💯💯💯.mp3.pad ./test-files/krs-💯💯💯.mp3
mv ./krs-💯💯💯.mp3 ./tmp/
DECRYPTEDMD5="$(GETHASH ./tmp/krs-💯💯💯.mp3)"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "KRS-One Unicode 2 test passed"
    echo "krs ($THESIZE) took $TIMETOOK seconds"
else
    echo "KRS-One Unicode 2 test failed" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######          shakira with shakira unicode 3
# -------------------------------------------------- #
THESIZE="$(du -h ./test-files/shakira-letra.txt | perl -pe 's/^\s*(.+?)\s+.*/$1/g')"
ORIGINALMD5="$(GETHASH ./test-files/shakira-letra.txt)"
TIMETOOK="$($TIME -f '%e' ./onetime -e ./test-files/shakira-letra.txt ./test-files/shakira-letra.txt 2>&1 > /dev/null)"
mv shakira-letra.txt.pad ./tmp/
CHANGEDMD5="$(GETHASH ./tmp/shakira-letra.txt.pad)"
./onetime --decrypt ./tmp/shakira-letra.txt.pad ./test-files/shakira-letra.txt
mv shakira-letra.txt ./tmp/
DECRYPTEDMD5="$(GETHASH ./tmp/shakira-letra.txt)"

if [ "$ORIGINALMD5" == "$DECRYPTEDMD5" ]
then
    echo "Shakira Unicode 3 test passed"
    echo "Shakira ($THESIZE) took $TIMETOOK seconds"
else
    echo "Shakira Unicode 3 test failed" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


echo
echo "---"
echo "now testing warnings and errors"
echo "---"
echo

# -------------------------------------------------- #
######   warning pad smaller test
# -------------------------------------------------- #
MESSAGE="$(./onetime -e ./test-files/thedecline.mp3 ./test-files/krs-one-ny.mp3 --output ./tmp/ciphertext)"

if [ "$MESSAGE" == "Warning: one time pad is smaller than input file. Will recycle" ]
then
    echo "Passed: Warning Pad Smaller test"
else
    echo "Failure: Warning pad Smaller test" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######   error pad too small test
# -------------------------------------------------- #
MESSAGE="$(./onetime -e ./test-files/thedecline.mp3 ./test-files/sml 2>&1)"

if [ "$MESSAGE" == "fatal error: one time pad is too small" ] && [ ! -e ./thedecline.mp3.pad ]
then
    echo "Passed: Error pad too small test"
else
    echo "Failure: Error pad too small test" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######   error non existent input test
# -------------------------------------------------- #
MESSAGE="$(./onetime ./nonexistent ./test-files/shakira-letra.txt -o ./tmp/this 2>&1)"

if [ "$MESSAGE" == "error: couldn't open input file (does it exist?)" ] && [ ! -e ./tmp/this ]
then
    echo "Passed: Error non existent input test"
else
    echo "Failure: Error non existent input" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######   error non existent pad test
# -------------------------------------------------- #
MESSAGE="$(./onetime ./test-files/shakira-letra.txt ./nonexistent -o ./tmp/this 2>&1)"

if [ "$MESSAGE" == "error: couldn't open one-time pad file (does it exist?)" ] && [ ! -e ./tmp/this ]
then
    echo "Passed: Error non existent pad test"
else
    echo "Failure: Error non existent pad" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######   error already existent output test
# -------------------------------------------------- #
touch ./tmp/estoyaexiste
MESSAGE="$(./onetime ./test-files/shakira-letra.txt ./test-files/shakira-letra.txt -o ./tmp/estoyaexiste 2>&1)"

if [ "$MESSAGE" == "error: output file already exists" ] && [ -e ./tmp/estoyaexiste ]
then
    echo "Passed: Error already existent output test"
else
    echo "Failure: Error already existent output test" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/


# -------------------------------------------------- #
######   error can't write output file test
# -------------------------------------------------- #
MESSAGE="$(./onetime ./test-files/shakira-letra.txt ./test-files/shakira-letra.txt -o ./nope/tmp 2>&1)"

if [ "$MESSAGE" == "error: can't write to output file (is there a directory that doesn't exist?)" ] && [ ! -e ./nope.tmp ]
then
    echo "Passed: Error can't write to output file test"
else
    echo "Failure: Error can't write to output file test" 1>&2;
    exit 1
fi
echo
rm -rf ./tmp/
mkdir -p ./tmp/

GREEN='\033[0;32m'
printf "${GREEN}All tests passed\n"

rm -rf ./tmp/
exit 0
