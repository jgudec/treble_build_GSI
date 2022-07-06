# Pixel Experience GSI

## Build
To get started with building Pixel Experience GSI, you'll need to get familiar with [Git and Repo](https://source.android.com/source/using-repo.html) as well as [How to build a GSI](https://github.com/phhusson/treble_experimentations/wiki/How-to-build-a-GSI%3F).
- Create a new working directory for your Pixel Experience build and navigate to it:
    ```
    mkdir pixel; cd pixel
    ```
- Clone this repo:
    ```
    git clone https://github.com/jgudec/treble_build_pe -b twelve
    ```
- Finally, start the build script:
    ```
    bash treble_build_pe/build.sh twelve
    ```

- If you do get any error about the repo possibly not being able to initialize (or similar), you can try manually doing what the script should have (but in my case, it didn't, so here I am mentioning these steps):
	```
	repo init -u https://github.com/PixelExperience/manifest -b twelve
	```
	```
	mkdir -p .repo/local_manifests
	```
	```
    cp treble_build_pe/manifest.xml .repo/local_manifests/pixel.xml
	```
## Credits
These people have helped this project in some way or another, so they should be the ones who receive all the credit:
- [Pixel Experience Team](https://download.pixelexperience.org/about)
- [phhusson](https://github.com/phhusson)
- [AndyYan](https://github.com/AndyCGYan)
- [eremitein](https://github.com/eremitein)
- [kdrag0n](https://github.com/kdrag0n)
