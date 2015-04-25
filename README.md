## Summary

This project demonstrates how to generate a video file using AVFoundation.  The project draws each frame of the video using Core Graphics (Quartz).

The resulting video [looks like this](expected-output.m4v).

## To use this in your own project

Copy `DqdGeneratedVideo.h`, `DqdGeneratedVideo.m`, and `DqdFrameGenerator.h` to your own project.

Add the `.m` files to your target.

Create a class that implements the `DqdFrameGenerator` protocol.

## No copyright

The contents of this repository are dedicated to the public domain, in accordance with the [CC0 1.0 Universal Public Domain Dedication](http://creativecommons.org/publicdomain/zero/1.0/), which is reproduced in the file `COPYRIGHT`.

Author: Rob Mayoff
2015-04-25
