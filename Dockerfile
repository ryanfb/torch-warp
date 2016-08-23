FROM teeps/cuda7.5-art-vid
MAINTAINER Ryan Baumann <ryan.baumann@gmail.com>

RUN apt-get install -y bc python-opencv
RUN apt-add-repository ppa:brightbox/ruby-ng && apt-get update && apt-get install -y ruby2.2 ruby2.2-dev
RUN gem install bundler

ADD . /root/torch-warp

RUN cp -v *-static /root/torch-warp/

WORKDIR /root/torch-warp

RUN bundle install
RUN cd consistencyChecker && make
