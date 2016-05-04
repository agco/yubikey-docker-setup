#!/bin/bash

wrong_pin=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-6`
wrong_puk=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-8`

echo "Locking the device before reset..."
yubico-piv-tool -a verify-pin -P $wrong_pin 2>/dev/null
yubico-piv-tool -a verify-pin -P $wrong_pin 2>/dev/null
yubico-piv-tool -a verify-pin -P $wrong_pin 2>/dev/null
yubico-piv-tool -a verify-pin -P $wrong_pin 2>/dev/null
yubico-piv-tool -a change-puk -P $wrong_pin -N $wrong_puk 2>/dev/null
yubico-piv-tool -a change-puk -P $wrong_pin -N $wrong_puk 2>/dev/null
yubico-piv-tool -a change-puk -P $wrong_pin -N $wrong_puk 2>/dev/null
yubico-piv-tool -a change-puk -P $wrong_pin -N $wrong_puk 2>/dev/null

echo "Resetting device..."
yubico-piv-tool -a reset

echo -e "Default keys \n\t pin = 123456, puk = 12345678, admin key = 010203040506070801020304050607080102030405060708"
