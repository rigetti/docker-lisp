SBCL_VERSION = $(shell cat VERSION-SBCL.txt)
QUICKLISP_VERSION = $(shell cat VERSION-QUICKLISP.txt)

.PHONY: docker-lisp
docker-lisp: Dockerfile
	docker build -t rigetti/lisp:$(QUICKLISP_VERSION) \
	--build-arg SBCL_VERSION=$(SBCL_VERSION) \
	--build-arg QUICKLISP_VERSION=$(QUICKLISP_VERSION) .
