# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# alpine-based image for building a cawk application container
# authors: cedric llorens, florian heitz
# cawk docker version: 1.0
# ------------------------------------------------------------

# Alpine Linux base image
FROM alpine:latest

# -------------------------------------------------------------------------
# ARG provided during the build and used for proxy usage in the 
# ENV section
# -------------------------------------------------------------------------
ARG http_proxy
ARG https_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY

# -------------------------------------------------------------------------
# ENV used for proxy usage which will belong to the image/container
# -------------------------------------------------------------------------
ENV TZ=Europe/Paris
ENV PATH="/app/cawk:$PATH"
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY

# -------------------------------------------------------------------------
# Install required packages
# -------------------------------------------------------------------------
RUN apk update && apk upgrade && \
    apk add --no-cache \
    bash \
    tar \
    diffutils \
    m4 \
    gawk \
    tzdata \
    findutils \
    procps \
    curl \
    vim \
    make \
    grep \
    coreutils \
    shadow

# ----
# Configure timezone && application directory
# ----
RUN cp /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    echo "Europe/Paris" > /etc/timezone && \
    mkdir -p /app/cawk /app/cawk/checkdiff /app/cawk/common /app/cawk/m4 /app/cawk/system /app/cawk/support /app/cawk/database.repo /app/cawk/tmp

# ----
# Copy non-persistent data locally
# ----
COPY Authors /app/cawk
COPY ChangeLog /app/cawk
COPY checkdiff /app/cawk/checkdiff
COPY common /app/cawk/common
COPY m4 /app/cawk/m4
COPY system /app/cawk/system
COPY support /app/cawk/support
COPY README /app/cawk
COPY PR.howto /app/cawk
COPY Makefile.support.mk /app/cawk
COPY Makefile /app/cawk
COPY LICENSE /app/cawk
COPY Dockerfile /app/cawk
COPY cawk_docker_run.sh /app/cawk
COPY database.repo /app/cawk/database.repo

# ----
# Copy <persistent> data in tmp directory, cawk_docker_run.sh program will link all these data
# to the cawk persistent volume <cawk-persistent-volume>
# ----
COPY backup /app/cawk/tmp/backup
COPY database /app/cawk/tmp/database
COPY confs /app/cawk/tmp/confs
COPY exceptions /app/cawk/tmp/exceptions
COPY tests /app/cawk/tmp/tests
COPY logs /app/cawk/tmp/logs
COPY reports /app/cawk/tmp/reports

# ----
# Create non-root user for security
# ----
RUN addgroup -g 1001 appuser && \
    adduser -u 1001 -G appuser -D -h /home/appuser appuser

# ----
# Create persistent volume directory structure with correct permissions
# ----
RUN mkdir -p /app/cawk/cawk-persistent-volume && \
    chown -R appuser:appuser /app/cawk/cawk-persistent-volume

# ----
# Set ownership and permissions before switching user
# ----
RUN chown -R appuser:appuser /app 2>/dev/null || true && \
    find /app/cawk -type d -exec chmod 755 {} \; 2>/dev/null || true && \
    find /app/cawk -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true && \
    chmod +x /app/cawk/cawk_docker_run.sh 2>/dev/null || true

# ----
# Switch to non-root user
# ----
USER appuser

# -------------------------------------------------------------------------
# Entrypoint to update latest updates and remain still alive
# -------------------------------------------------------------------------
ENTRYPOINT ["/app/cawk/cawk_docker_run.sh"]
