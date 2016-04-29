Build the image `docker build -t yubikey-setup .` or use the `docker pull tiagodeoliveira/yubikey-setup`.

And execute sharing your usb bus with the container:
```
docker run  --privileged -v /dev/bus/usb:/dev/bus/usb -it tiagodeoliveira/yubikey-setup
```
