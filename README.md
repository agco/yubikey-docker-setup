## Setup

Build the image `docker build -t yubikey-setup .` or use the `docker pull tiagodeoliveira/yubikey-setup`.

And execute sharing your usb bus with the container:
```
docker run  --privileged -v /dev/bus/usb:/dev/bus/usb -it tiagodeoliveira/yubikey-setup
```

## Operation

#### To reset the dongle:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -it tiagodeoliveira/yubikey-setup reset
```

#### To setup the dongle, it will change the default PIN/PUK/Key and write a certificate + private key on the slot 9c of the device:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -v `pwd`:/certs -it tiagodeoliveira/yubikey-setup setup {the pfx file password}       
```

#### To sign a file using SHA1 digest + private key:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -v `pwd`:/sign -it tiagodeoliveira/yubikey-setup sign {the file I want to sign} [key management]
```

#### And to verify if the signature matches:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -v `pwd`:/sign -it tiagodeoliveira/yubikey-setup verify {the file I want to verify}
```

The script relies that, when setting the device up the directory `/certs` will be present on the image with a pfx file inside, and when signing/verifying the dir `/sign` will be present with the file that is intended to be signed and the .dgst file when is the case.

```
Usage:
	 help 			 print this message
	 reset 			 reset the driver to factory standards
	 setup {password}	 generates new secrets and upload a PKCS12 certificate to device
	 sign {type} {file}
		 types
			 dgst 		 sign using digest, generate the md5 and sign over that
			 verify 	 checks if the digest matches
	 [command] 		 executes the [command] on the container
```
