#!/bin/bash

print_help() {
  echo -e "Usage: "
  echo -e "\t help \t\t\t print this message"
  echo -e "\t reset \t\t\t reset the driver to factory standards"
  echo -e "\t setup {password}\t generates new secrets and upload a PKCS12 certificate to device"
  echo -e "\t sign {type} {file}"
  echo -e "\t\t types \n\t\t\t dgst \t\t sign using digest, generate the md5 and sign over that\n\t\t\t verify \t checks if the digest matches"
  echo -e "\t [command] \t\t executes the [command] on the container"
}

case $1 in
  "reset"*)
    command=/scripts/reset-key.sh
    ;;
  "sign"*)
    command=/scripts/sign-file.sh
    export sign_type=$2
    export file_to_sign=$3
    ;;
  "setup"*)
    command=/scripts/setup-key.sh
    export pkcs12_pass=$2
    ;;
  "help"*)
    print_help
    ;;
  *)
    command=$@
    ;;
esac

if [ -n $command ]; then
  LIBCCID_ifdLogLevel=0x000F pcscd --apdu
  exec $command
fi
