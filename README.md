# torch-warp

This repository contains a torch implementation for automatically applying optical flow deformations to pairs of images in order to morph between images. The optical flow calculation and loading code is from [`manuelruder/artistic-videos`](https://github.com/manuelruder/artistic-videos), and is based on [DeepFlow](http://lear.inrialpes.fr/src/deepflow/). Theoretically, you could drop in another optical flow program which outputs `.flo` files in the [Middlebury format](http://vision.middlebury.edu/flow/data/).

This process is inspired by Patrick Feaster's post on [Animating Historical Photographs With Image Morphing](https://griffonagedotcom.wordpress.com/2014/08/18/animating-historical-photographs-with-image-morphing/).

My blog post about this process: [Animating Stereograms with Optical Flow Morphing](http://ryanfb.github.io/etc/2016/08/17/animating_stereograms_with_optical_flow_morphing.html)

## Examples

![New York Skyline](http://i.imgur.com/oRcYrWf.gif) ![Historical Photo](http://i.imgur.com/z1N5tL5.gif) ![Cat and Child](http://i.imgur.com/0ugTCvk.gif)

## Dependencies

* torch7
* DeepFlow and DeepMatching binaries in the current directory, as `deepflow2-static` and `deepmatching-static`

## Usage

For input, you need two PNG images of the same dimensions named e.g. `filename_0.png` and `filename_1.png`. You can then run `./run-torchwarp.sh filename` to run all the steps and output the morphing animation as `morphed_filename.gif`.

You can also use `./run-stereogranimator.sh ID` with an image ID from [NYPL's Stereogranimator](http://stereo.nypl.org/) to download an animated GIF at low resolution and run it through the morphing process.

If you sign up for [the NYPL Digital Collections API](http://api.repo.nypl.org/), you can use your API token with the included scripts to work with high-resolution original images. The `nypl_recrop.rb` script takes a Stereogranimator image ID as an argument and reads the API token from the `NYPL_API_TOKEN` environment variable, and attempts to apply the Stereogranimator's crop values to the original image. The `run-stereogranimator-hi-res.sh` script uses this process and passes the high-resolution cropped images to `run-torchwarp.sh`. You can also pass the `NYPL_API_TOKEN` environment variable [in your `docker run` command](https://docs.docker.com/engine/reference/run/#/env-environment-variables).

## Docker Usage

I had very little luck getting DeepFlow to work on OS X, so I'm using Docker to run this with the included `Dockerfile`.

* Build the Docker image with `docker build -t torch-warp .`
* Run the build with `docker run -t -i torch-warp /bin/bash`. You may want to [map a host directory as a data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/mount-a-host-directory-as-a-data-volume) as well, in order to transfer images back and forth.
* Use the scripts as described above inside the Docker container's shell.

I've also made this repository an automated build on Docker Hub: [`ryanfb/torch-warp`](https://hub.docker.com/r/ryanfb/torch-warp/)
