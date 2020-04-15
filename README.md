docker-lisp
===========

[![docker pulls](https://img.shields.io/docker/pulls/rigetti/lisp.svg)](https://hub.docker.com/r/rigetti/lisp)

Docker image that contains the latest version of [Steel Bank Common Lisp](http://www.sbcl.org/),
the most recent distribution of the library manager [Quicklisp](https://www.quicklisp.org/beta/),
and some of the third-party libraries used at Rigetti. It is built on top of Debian Buster.

Running the Docker image
------------------------

The [rigetti/lisp](https://hub.docker.com/r/rigetti/lisp) image is available on DockerHub,
so running `docker run -it rigetti/lisp` will download it and drop you into an SBCL REPL
with Quicklisp available and the libraries preloaded.

Updating the contents of the Docker image
-----------------------------------------

Once updating the source code, you can test your changes locally by running `make`
from the command line. Additionally, when you open a PR with your changes, the CI system
will run `make` and build the Docker image, but will not push it to DockerHub. There are
four things that you might want to change in the Docker image:

1. To update the version of SBCL to use in the Docker build,
simply edit the `VERSION-SBCL.txt` file.

2. To update the version of Quicklisp to use in the Docker build,
simply edit the `VERSION-QUICKLISP.txt` file.

3. To include additional Quicklisp libraries that are used by downstream dependencies,
simply add them to `quicklisp-libraries.txt`

4. Currently, this image only contains SBCL, but it is named `rigetti/lisp` because in the
future one could imagine adding downstream support for additional Lisp implementations
(like ECL or CCL). In order to do so, the `Dockerfile` would need to be updated to install
these other flavors of Lisp.

Pushing a new Docker image
--------------------------

The images on DockerHub are tagged by the version of Quicklisp available in them. Thus,
`rigetti/lisp:2019-07-11` would have the Quicklisp distribution that was released on
July 11th, 2019. The version of SBCL is not represented explicitly in the image tag,
but corresponds to the contents of `VERSION-SBCL.txt` when the image was built. This was
an intentional design decision to reduce upgrade complexity, but can be rethought if necessary.

Once you have selected the version of SBCL and Quicklisp that you would like to build an image for,
commit your changes to `VERSION-SBCL.txt` and `VERSION-QUICKLISP.txt` and open a pull request.
After this PR has been merged into mainline, the CI system will build a new version of the image
tagged with the Quicklisp version, and push it to DockerHub. For example, if `VERSION-SBCL.txt`
contains 1.5.4 and `VERSION-QUICKLISP.txt` contains 2019-07-11, this will trigger a build on
GitLab CI that creates the `rigetti/lisp:2019-07-11` image and pushes it to DockerHub.
Additionally, this will update the `rigetti/lisp:latest` image, which is the default image
if no tag is specified.

Overwriting an existing Docker image
------------------------------------

If you make changes to the source code without incrementing the number in `VERSION-QUICKLISP.txt`,
when these changes hit master, the `rigetti/lisp` image that is tagged by the number in
`VERSION-QUICKLISP.txt` will be overwritten by whatever is built in that master build.
For example, if you update the SBCL version or add new QL libraries, this will overwrite
the most recent non-`latest` tag, as well as update the `latest` tag.

Nightly rebuilds of the Docker image
------------------------------------

In addition to the builds that are triggered by merging changes into master, there is a
scheduled nightly build (at 4:00am PT) that rebuilds the Docker image associated with
the most recent non-`latest` tag, as well as the `latest` tag. This is done so that we
are always picking up the latest Debian security patches, and to avoid other issues that
arise when using a stale distribution.


Downstream dependencies
-----------------------

The following Docker images depend on `rigetti/lisp`:

- [`rigetti/rpcq`](https://hub.docker.com/r/rigetti/rpcq)
- [`rigetti/quilc`](https://hub.docker.com/r/rigetti/quilc)
- [`rigetti/qvm`](https://hub.docker.com/r/rigetti/qvm)

A newly pushed `rigetti/lisp` will **NOT** trigger these downstream dependencies
to rebuild automatically. Thus, once you have released a new version of this image, make
sure to update the tag your downstream images are referencing (if the image tag is specified)
or re-run your downstream builds to pick up the new image (if you are using the `latest` tag).
