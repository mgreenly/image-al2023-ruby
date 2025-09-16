FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS builder

ARG RUBY_VERSION=3.4.5
ARG RUBY_MAJOR=3.4
ARG RUBYGEMS_VERSION=3.7.2
ARG BUNDLER_VERSION=2.7.2
ARG RUBY_PREFIX=/opt/ruby/${RUBY_MAJOR}
ARG GEM_SOURCE=https://rubygems.org

# Install build dependencies and create user
RUN dnf update -y && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y \
        gcc \
        gcc-c++ \
        make \
        automake \
        autoconf \
        curl-minimal \
        openssl-devel \
        libyaml-devel \
        libffi-devel \
        readline-devel \
        zlib-devel \
        gdbm-devel \
        ncurses-devel \
        tar \
        gzip \
        bzip2 \
        patch \
        file \
        git && \
    dnf clean all && \
    groupadd -g 1000 ruby && \
    useradd -u 1000 -g 1000 -M -s /bin/bash ruby

# Download and compile Ruby
RUN cd /tmp && \
    curl -LO https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.gz && \
    tar -xzf ruby-${RUBY_VERSION}.tar.gz && \
    cd ruby-${RUBY_VERSION} && \
    ./configure \
        --prefix=${RUBY_PREFIX} \
        --enable-shared \
        --disable-install-doc \
        --disable-install-rdoc \
        --disable-install-capi && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/ruby-*

# install specified version of the `gem` command
RUN ${RUBY_PREFIX}/bin/gem update --system ${RUBYGEMS_VERSION} --no-document

# install specified version of the `bundler` command
RUN ${RUBY_PREFIX}/bin/gem install bundler -v ${BUNDLER_VERSION} --no-document

# configure gem sources (remove default and add the specified source)
RUN ${RUBY_PREFIX}/bin/gem sources --clear-all && \
    ${RUBY_PREFIX}/bin/gem sources --add ${GEM_SOURCE}

# any user can navigate the directory structure and read files but only the
# ruby user can modify anything or run executable files in the directory.
RUN chown -R ruby:ruby ${RUBY_PREFIX} && \
    find ${RUBY_PREFIX} -type d -exec chmod 755 {} \; && \
    find ${RUBY_PREFIX} -type f -executable -exec chmod 744 {} \; && \
    find ${RUBY_PREFIX} -type f ! -executable -exec chmod 644 {} \;

###############################################################################
#
# Final stage
#
###############################################################################
FROM public.ecr.aws/amazonlinux/amazonlinux:2023-minimal

ARG RUBY_VERSION=3.4.5
ARG RUBY_MAJOR=3.4
ARG RUBY_PREFIX=/opt/ruby/${RUBY_MAJOR}
ARG WORKDIR=/opt/approot

RUN dnf update -y && \
    dnf install -y \
        openssl \
        libyaml \
        libffi \
        readline \
        zlib \
        gdbm \
        ncurses \
        git \
        tar \
        gzip && \
    dnf clean all && \
    groupadd -g 1000 ruby && \
    useradd -u 1000 -g 1000 -M -s /bin/bash ruby

COPY --from=builder --chown=ruby:ruby ${RUBY_PREFIX} ${RUBY_PREFIX}

# set PATH
ENV PATH=${RUBY_PREFIX}/bin:$PATH

# set working directory
WORKDIR ${WORKDIR}

# switch to ruby user and set environment
USER ruby
ENV HOME=${WORKDIR} \
    GEM_HOME=${RUBY_PREFIX}/lib/ruby/gems/${RUBY_MAJOR}.0

CMD ["/bin/bash"]
