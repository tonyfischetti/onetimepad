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
# TIMETOOK="$($TIME -f '%e' ./onetime --encrypt ./test-files/krs-one-ny.mp3 ./test-files/thedecline.mp3 --output ./tmp/myciphertext)"
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



rm -rf ./tmp/
exit 0
