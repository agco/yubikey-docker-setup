#!/bin/bash

LIBCCID_ifdLogLevel=0x000F pcscd --apdu

echo "-------------------------------------------------------------------------"
echo "Execute: yubico-piv-tool --help to get info on how to manage the dongle."
echo "Execute: yubico-piv-tool -a list-readers to show your smart card devices."
echo "-------------------------------------------------------------------------"

exec $@
