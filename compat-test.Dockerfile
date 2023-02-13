FROM centos:7

# This is the minimal CentOS 7 image to run krunner.
RUN yum install -y \
        ca-certificates \
        tzdata \
    ;
