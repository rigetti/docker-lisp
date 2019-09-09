FROM debian:buster

# build variables
ARG SBCL_VERSION
ARG SBCL_URL=https://prdownloads.sourceforge.net/sbcl/sbcl-${SBCL_VERSION}-source.tar.bz2
ARG QUICKLISP_VERSION
ARG QUICKLISP_URL=http://beta.quicklisp.org/dist/quicklisp/${QUICKLISP_VERSION}/distinfo.txt

# install required debian packages
RUN apt-get update -y && \
    apt-get install -y \
    # used to install sbcl and quicklisp
    build-essential \
    curl \
    # used in downstream images (rpcq, quilc, qvm)
    clang-7 \
    git \
    libblas-dev \
    libffi-dev \
    liblapack-dev \
    libz-dev \
    libzmq3-dev \
    # used in the Dockerfile CMD
    rlwrap \
    # used to install sbcl and quicklisp
    sbcl && \
    apt-get clean

# install sbcl (requirements: build-essential, curl, libz-dev, sbcl)
WORKDIR /src
RUN curl -LO ${SBCL_URL} && \
    tar -xf sbcl-${SBCL_VERSION}-source.tar.bz2 && \
    rm /src/sbcl-${SBCL_VERSION}-source.tar.bz2 && \
    cd /src/sbcl-${SBCL_VERSION} && \
    bash make.sh --fancy --with-sb-dynamic-core --with-sb-linkable-runtime && \
    (cd src/runtime && make libsbcl.a) && \
    bash install.sh && \
    cd -

# install quicklisp (requirements: curl, sbcl)
RUN curl -o /tmp/quicklisp.lisp 'https://beta.quicklisp.org/quicklisp.lisp' && \
    sbcl --noinform --non-interactive --load /tmp/quicklisp.lisp --eval \
        "(quicklisp-quickstart:install :dist-url \"${QUICKLISP_URL}\")" && \
    sbcl --noinform --non-interactive --load ~/quicklisp/setup.lisp --eval \
        '(ql-util:without-prompting (ql:add-to-init-file))' && \
    echo '#+quicklisp(push "/src" ql:*local-project-directories*)' >> ~/.sbclrc && \
    rm -f /tmp/quicklisp.lisp

# quickload libraries
ADD . /src/docker-lisp
WORKDIR /src/docker-lisp
RUN sbcl --eval '(ql:quickload (uiop:read-file-lines "quicklisp-libraries.txt"))' --quit

# enter into an SBCL REPL (requirements: rlwrap, sbcl)
CMD sleep 0.05; rlwrap sbcl
