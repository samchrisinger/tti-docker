FROM ubuntu:20.04 as intermediate

RUN mkdir /etc/cloud
RUN touch /etc/cloud/cloud-init.disabled
RUN apt-get update
RUN apt-get install -y git git-lfs

ARG GH_TOKEN
ARG GH_USERNAME
ARG PRIVATES_BRANCH

RUN git clone https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/thlib-texts-indexer
RUN git clone --single-branch --branch py3 https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/TibetanData
RUN git clone https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/thlib-texts-xml
RUN git clone --branch ${PRIVATES_BRANCH:-develop} https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/tla-privates
RUN git clone https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/tibetan-text-reuse

FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

COPY --from=intermediate /thlib-texts-indexer /thlib-texts-indexer
COPY --from=intermediate /TibetanData /TibetanData
COPY --from=intermediate /thlib-texts-xml /thlib-texts-xml
COPY --from=intermediate /tla-privates/solr/variables /solr-variables
COPY --from=intermediate /tibetan-text-reuse /tibetan-text-reuse

RUN apt update
RUN DEBIAN_FRONTEND="noninteractive" apt install -y python3-pip wget curl unzip default-jre default-jdk python3-numpy python3-venv tmux

RUN wget -c https://www.dropbox.com/s/hd3fwwumaxxllt4/texts.tar.gz\?dl\=0 -O - | tar -xz

RUN cd thlib-texts-indexer && python3 -m venv .venv && source ./.venv/bin/activate && pip3 install -r requirements.txt

RUN cd tibetan-text-reuse && python3 -m venv .venv && source ./.venv/bin/activate && pip3 install -e .
