# torch-warp

This repository contains a torch implementation for applying optical flow deformations to pairs of images in order to morph between images. The optical flow calculation and loading code is from [`manuelruder/artistic-videos`](https://github.com/manuelruder/artistic-videos), and is based on [DeepFlow](http://lear.inrialpes.fr/src/deepflow/). Theoretically, you could drop in another optical flow program which outputs `.flo` files in the [Middlebury format](http://vision.middlebury.edu/flow/data/).

## Dependencies

* torch7
* DeepFlow and DeepMatching binaries in the current directory, as `deepflow2-static` and `deepmatching-static`

## Usage

For input, you need two PNG images of the same dimensions named e.g. `filename_0.png` and `filename_1.png`. You can then run `./run-torchwarp.sh filename` to run all the steps and output the morphing animation as `morphed_filename.gif`.

You can also use `./run-stereogranimator.sh ID` with an image ID from [NYPL's Stereogranimator](http://stereo.nypl.org/) to download an animated GIF and run it through the morphing process.

## Docker Usage

I had very little luck getting DeepFlow to work on OS X, so I'm using Docker to run this with the included `Dockerfile`.

* Build the Docker image with `docker build -t torch-warp .`
* Run the build with `docker run -t -i torch-warp /bin/bash`. You may want to [map a host directory as a data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/mount-a-host-directory-as-a-data-volume) as well, in order to transfer images back and forth.
* Use the scripts as described above inside the Docker container's shell.
