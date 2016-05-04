#!/bin/bash

pkcs12_file=`ls -1 /certs/*.pfx 2> /dev/null | head -1`

function change_device_keys() {
  key=`dd if=/dev/random bs=1 count=24 2>/dev/null | hexdump -v -e '/1 "%02X"'`
  yubico-piv-tool -a set-mgm-key -n $key 2> /dev/null

  pin=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-6`
  yubico-piv-tool -a change-pin -P 123456 -N $pin 2> /dev/null

  puk=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-8`
  yubico-piv-tool -a change-puk -P 12345678 -N $puk 2> /dev/null

  if [ "$?" -eq 0 ]; then
    echo -e "New keys (ATTENTION: if you lost the generated keys, you'll need to reset the device) \n\t pin = $pin, puk = $puk, admin key = $key"
    return 0
  else
    echo "Impossible to set the keys, try to reset your dongle."
    return 1
  fi
}

if [ -f "$pkcs12_file" ] && [ -n "$pkcs12_pass" ]; then
  if change_device_keys; then
    echo "Recording certificate file [$pkcs12_file] on device"
    yubico-piv-tool -s 9c -i "$pkcs12_file" -p "$pkcs12_pass" -a import-key -a import-cert -K PKCS12 --key=$key
  else
    echo "Impossible to record certificates, not using default keys."
    echo "Either reset your dongle or record it manually informing the correct admin key."
    echo -e "\t yubico-piv-tool -s 9c -i $pkcs12_file -p $pkcs12_pass -a import-key -a import-cert -K PKCS12 --key={admin key}"
  fi
else
  echo "You need to have a pfx file on the /certs dir and inform the password."
fi
