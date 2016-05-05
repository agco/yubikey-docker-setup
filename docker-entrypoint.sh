#!/bin/bash

. /scripts/functions.sh

print_help() {
  echo -e "Usage: "
  echo -e "\thelp\t\t\t\tprint this message"
  echo -e "\treset\t\t\t\treset the driver to factory standards"
  echo -e "\tstatus\t\t\t\tshow the dongle status"
  echo -e "\tsign {file}\t\t\tsing in a file using file digest (SHA) plus private key"
  echo -e "\tverify {file}\t\t\tverify if the signature matches with the file"
  echo -e "\tpkcs12 {password} [key]\t\tupload a PKCS12 certificate to device, if a key is informed it will be used to setup the device, if none it will generate new keys to the device"
  echo -e "\tgenerate {slot} {subject} [pin] [key]\tgenerate a RSA2048 private key and the certificate request on the given slot to the given subject"
  echo -e "\tupload {slot} {key} [filename]\tsave the certificate on the given slot, if no filename is informed it can be pasted on stdin"
  echo -e "\t[command]\t\t\texecutes the [command] on the container"
}

LIBCCID_ifdLogLevel=0x000F pcscd --apdu

case $1 in
  "reset"*)
    command=/scripts/reset-key.sh
    ;;
  "status"*)
    command="yubico-piv-tool -a status"
    ;;
  "sign"*)
    sing_file $2
    ;;
  "verify"*)
    verify_file $2
    ;;
  "pkcs12"*)
    record_certificate $2 $3
    ;;
  "generate"*)
    generate_key $2 $3 $4 $5
    ;;
  "upload"*)
    import_certificate $2 $3 $4
    ;;
  "help"*)
    print_help
    ;;
  *)
    command=$@
    ;;
esac

if [ -n $command ]; then
  exec $command
fi
