FROM ubuntu:20.04 as intermediate

# install git
RUN apt-get update
RUN apt-get install -y git

# add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN git clone git@github.com:samchrisinger/thlib-texts-indexer.git
RUN git clone --single-branch --branch py3 git@github.com:samchrisinger/TibetanData.git
RUN git clone git@github.com:thl/thlib-texts-xml.git
RUN git clone git@github.com:samchrisinger/tla-privates.git

FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

COPY --from=intermediate /thlib-texts-indexer /thlib-texts-indexer
COPY --from=intermediate /TibetanData /TibetanData
COPY --from=intermediate /thlib-texts-xml /thlib-texts-xml
COPY --from=intermediate /tla-privates/solr/variables /solr-variables

RUN apt update
RUN DEBIAN_FRONTEND="noninteractive" apt install -y python3-pip wget curl unzip default-jre default-jdk
#RUN wget https://gigenet.dl.sourceforge.net/project/saxon/Saxon-HE/10/Java/SaxonHE10-1J.zip && unzip SaxonHE10-1J.zip

RUN cd thlib-texts-indexer && pip3 install -r requirements.txt
RUN pip3 install /TibetanData/intertexuality
RUN echo "#!/bin/bash" > run.sh
RUN source /solr-variables && echo 'cd thlib-texts-indexer && python3 index.py -ttxd /thlib-texts-xml -solr https://$SOLR_HOST -coll $SOLR_CORE -saxon saxon-8.jar -include lccw,ngb.pt --index_itx --results ./results --solr_auth $SOLR_USER:$SOLR_PASS --tib_data_path /TibetanData "$@"' >> run.sh
RUN cat run.sh
RUN chmod a+x ./run.sh
