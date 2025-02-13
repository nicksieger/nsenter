FROM debian:bookworm as builder

# intall gcc and supporting packages
RUN apt-get update && apt-get install -yq make gcc gettext autopoint bison libtool automake pkg-config

WORKDIR /code

# download util-linux sources
ARG UTIL_LINUX_VER=2.39.2
ADD https://github.com/util-linux/util-linux/archive/refs/tags/v${UTIL_LINUX_VER}.tar.gz .
RUN tar -xf v${UTIL_LINUX_VER}.tar.gz && mv util-linux-${UTIL_LINUX_VER} util-linux

# make static version
WORKDIR /code/util-linux
RUN ./autogen.sh && ./configure
RUN make LDFLAGS="--static" nsenter

# Final image
FROM scratch

COPY --from=builder /code/util-linux/nsenter /

ENTRYPOINT ["/nsenter"]
