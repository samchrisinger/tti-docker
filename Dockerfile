FROM ubuntu:20.04 as intermediate

RUN mkdir /etc/cloud
RUN touch /etc/cloud/cloud-init.disabled
RUN apt-get update
RUN apt-get install -y git

ARG GH_TOKEN
ARG GH_USERNAME

RUN git clone https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/thlib-texts-indexer
RUN git clone --single-branch --branch py3 https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/TibetanData
RUN git clone https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/thlib-texts-xml
RUN git clone https://${GH_USERNAME}:${GH_TOKEN}@github.com/thl/tla-privates

FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

COPY --from=intermediate /thlib-texts-indexer /thlib-texts-indexer
COPY --from=intermediate /TibetanData /TibetanData
COPY --from=intermediate /thlib-texts-xml /thlib-texts-xml
COPY --from=intermediate /tla-privates/solr/variables /solr-variables

RUN apt update
RUN DEBIAN_FRONTEND="noninteractive" apt install -y python3-pip wget curl unzip default-jre default-jdk python3-numpy

RUN cd thlib-texts-indexer && pip3 install -r requirements.txt
RUN pip3 install /TibetanData/intertexuality
RUN echo "#!/bin/bash" > run.sh

# RUN source /solr-variables && echo 'cd thlib-texts-indexer && python3 index.py -ttxd /thlib-texts-xml -solr https://$SOLR_HOST -coll $SOLR_CORE -saxon saxon-8.jar -include lccw,ngb.pt --index_itx --results ./results --solr_auth $SOLR_USER:$SOLR_PASS --tib_data_path /TibetanData "$@"' >> run.sh
# RUN cat run.sh
# RUN chmod a+x ./run.sh
