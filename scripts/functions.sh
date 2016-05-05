#!/bin/bash

function sing_file() {
  if [ -n "$1" ]; then
    to_sign="/data/$1"
    openssl dgst -ecdsa-with-SHA1 -sign 01:02 -keyform ENGINE -engine pkcs11 $to_sign > $to_sign.dgst
  else
    echo "Need to inform the file name"
  fi
}

function verify_file() {
  to_verify="/data/$1"
  openssl dgst -ecdsa-with-SHA1 -verify 01:02 -keyform ENGINE -engine pkcs11 -signature $to_verify.dgst $to_verify
}

function change_secrets() {
  export generated_key=`dd if=/dev/random bs=1 count=24 2>/dev/null | hexdump -v -e '/1 "%02X"'`
  yubico-piv-tool -a set-mgm-key -n $generated_key 2> /dev/null

  export generated_pin=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-6`
  yubico-piv-tool -a change-pin -P 123456 -N $generated_pin 2> /dev/null

  export generated_puk=`dd if=/dev/random bs=1 count=6 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-8`
  yubico-piv-tool -a change-puk -P 12345678 -N $generated_puk 2> /dev/null

  if [ "$?" -eq 0 ]; then
    echo -e "New keys (ATTENTION: if you lost the generated keys, you'll need to reset the device) \n\t pin = $generated_pin, puk = $generated_puk, admin key = $generated_key"
    return 0
  else
    echo "Impossible to set the keys, try to reset your dongle."
    return 1
  fi
}

function record_certificate() {
  pkcs12_file=`ls -1 /data/*.pfx 2> /dev/null | head -1`
  pkcs12_pass=$1
  admin_key=$2

  if [ -f "$pkcs12_file" ] && [ -n "$pkcs12_pass" ]; then
    if [ -z "$admin_key" ] && change_secrets; then
      admin_key=$generated_key
    fi

    if [ -n "$admin_key" ]; then
      echo "Recording certificate file [$pkcs12_file] on device"
      yubico-piv-tool -s 9c -i "$pkcs12_file" -p "$pkcs12_pass" -a import-key -a import-cert -K PKCS12 --key=$admin_key
    else
      echo "Impossible to record certificates, wrong key."
      echo "Either reset your dongle or inform the correct admin key."
      echo -e "\t yubico-piv-tool -s 9c -i $pkcs12_file -p $pkcs12_pass -a import-key -a import-cert -K PKCS12 --key={admin key}"
    fi
  else
    echo "You need to have a pfx file on the /certs dir and inform the password."
  fi
}

function generate_key() {
  choosen_slot=$1
  certificate_subject=$2
  pin=$3
  admin_key=$4

  if [ -z "$pin" ] && change_secrets; then
    pin=$generated_pin
    admin_key=$generated_key
  fi

  if [ -n "$pin" ] && [ -n "$admin_key" ]; then
    echo "Generating key and CSR, wait..."
    yubico-piv-tool -s $choosen_slot -a generate --key=$admin_key | tee /data/public_key.pem
    yubico-piv-tool -s $choosen_slot -S $certificate_subject -P $pin -a verify -a request -i /data/public_key.pem | tee /data/signin_request.pem
    echo "Files saved: /data/public_key.pem /data/signin_request.pem"
  else
    echo "Need to inform a PIN and key or reset your device!"
  fi
}

function import_certificate() {
  choosen_slot=$1
  admin_key=$2
  filename=$3

  if [ -n "$choosen_slot" ] || [ -n "$admin_key" ]; then
    if [ -n "$filename" ]; then
      input_param="-i $filename"
    fi

    yubico-piv-tool -s $choosen_slot -a import-certificate $input_param --key=$admin_key
  else
    echo "Need to inform the slot and the admin key"
  fi
}
