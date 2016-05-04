#!/bin/bash

to_sign="/sign/$file_to_sign"

if [ -f "$to_sign" ]; then
  case $sign_type in
    "dgst"*)
      openssl dgst -ecdsa-with-SHA1 -sign 01:02 -keyform ENGINE -engine pkcs11 $to_sign > $to_sign.dgst
      ;;
    "verify"*)
      openssl dgst -ecdsa-with-SHA1 -verify 01:02 -keyform ENGINE -engine pkcs11 -signature $to_sign.dgst $to_sign
      ;;
    *)
      openssl rsautl -sign -keyform ENGINE -engine pkcs11 -inkey 01:02 -in $to_sign -out $to_sign.enc
      ;;
  esac
else
  echo "Need to inform the file to be signed!"
fi
