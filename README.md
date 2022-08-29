# Shale
Another software renderer, written in [Crystal](https://crystal-lang.org/)!

Following `thebennybox`'s series: [https://www.youtube.com/playlist?list=PLEETnX-uPtBUbVOok816vTl1K9vV1GgH5](https://www.youtube.com/playlist?list=PLEETnX-uPtBUbVOok816vTl1K9vV1GgH5)

This is a project for learning about general computer graphics and how it works without GPU acceleration. As well, learning to code in Crystal and how to use X11. In the future, would also be a good test bed to port over to Windows and MacOS and learn how to integrate into their display servers.

## Dependencies

* Crystal `>=1.5.0`
* [TamasSzekeres/x11-cr](https://github.com/TamasSzekeres/x11-cr) Docs: [https://tamasszekeres.github.io/x11-cr/index.html](https://tamasszekeres.github.io/x11-cr/index.html)
	Though currently using own fork at this stage.

### System Packages

Debain-base systems:

	sudo apt install libx11-dev

## Run

With using the `shards` cmd, the `Shale` target will need to be specified. As well the `XUTIL_DEFINE_FUNCTIONS` will need to be included for the build:

	shards run Shale --define=XUTIL_DEFINE_FUNCTIONS

## License

Distributed under the Mozilla Public License v2.0 (MPL-2.0). See [LICENSE](./LICENSE) for more information.

## Resources

Here's a list of materials I've used along the way to learning more about the tech needed:

* https://github.com/tsoding/x11-double-buffering & https://www.youtube.com/watch?v=osnd75j7Wco

Some misc resources discovered that are not in reference for the project, but still useful to keep track of:

* https://www.talisman.org/~erlkonig/misc/x11-composite-tutorial/
