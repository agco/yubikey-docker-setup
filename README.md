## Setup

Build the image `docker build -t yubikey-setup .` or use the `docker pull tiagodeoliveira/yubikey-setup`.

And execute sharing your usb bus with the container:
```
docker run  --privileged -v /dev/bus/usb:/dev/bus/usb -it tiagodeoliveira/yubikey-setup
```

## Operation

#### To see what is on the dongle:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -it tiagodeoliveira/yubikey-setup status
```

#### To reset the dongle:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -it tiagodeoliveira/yubikey-setup reset
```

#### To setup the upload a PKCS12 certificate + private key file, it will change PIN/PUK/Key to a random value if using default, if management key is informed it will not change:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -v `pwd`:/data -it tiagodeoliveira/yubikey-setup pkcs12 {the pfx file password}
```

#### To sign a file using SHA1 digest + private key:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -v `pwd`:/data -it tiagodeoliveira/yubikey-setup sign {the file I want to sign}
```

#### And to verify if the signature matches:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -v `pwd`:/data -it tiagodeoliveira/yubikey-setup verify {the file I want to verify}
```

#### To generate a new private key + a certificate signature request:
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/Downloads:/data -it tiagodeoliveira/yubikey-setup generate 9c '/CN=foo/OU=test/O=example.com/ [[pin] [key] if not the default values]
```

#### To upload a signed certificate to device (if no filename is informed, the certificate content can be pasted on stdin):
```
docker run --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/Downloads:/data -it tiagodeoliveira/yubikey-setup upload 9c {management key} [optional file name]
```

The script uses the `/data` directory as base path, so the docker volume has to be mounted in there.

```
Usage:
	help								print this message
	[command]						executes the [command] on the container
	reset								reset the driver to factory standards
	status							show the dongle status
	sign {file}							sing in a file using file digest (SHA) plus private key
	verify {file}							verify if the signature matches with the file
	pkcs12 {password} [key]					upload a PKCS12 certificate to device, if a key is informed it will be used to setup the device, if none it will generate new keys to the device
	generate {slot} {subject} [pin] [key]	generate a RSA2048 private key and the certificate request on the given slot to the given subject
	upload {slot} {key} [filename]			save the certificate on the given slot, if no filename is informed it can be pasted on stdin
```
