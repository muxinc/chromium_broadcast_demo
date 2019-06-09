FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:jonathonf/ffmpeg-4 && \
    apt-get update && \
    apt-get install -y ffmpeg chromium-browser alsa-utils pulseaudio xvfb python3 python3-pip

RUN pip3 install Flask Flask-Sockets
RUN echo "pcm.default pulse\nctl.default pulse" > .asoundrc

ADD static static
ADD serve.py serve.py
ADD entrypoint.sh entrypoint.sh

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
