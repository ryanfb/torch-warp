FROM teeps/cuda7.5-art-vid
MAINTAINER Ryan Baumann <ryan.baumann@gmail.com>

RUN apt-get install -y bc

ADD . /root/torch-warp

RUN cp -v *-static /root/torch-warp/

WORKDIR /root/torch-warp

RUN cd consistencyChecker && make
