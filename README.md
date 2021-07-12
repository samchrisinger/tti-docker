# tti-docker

This docker script is designed to facilitate indexing the XML files from [thlib-texts-xml](https://github.com/thl/thlib-texts-xml),
as well as running and indexing the results of intertextual analysis. It is a companion to [thlib-texts-indexer](https://github.com/thl/thlib-texts-indexer)
and to the Linode StackScript [here](https://cloud.linode.com/stackscripts/863226).

The suggested workflow is:
1) Spin up a new Linode using the Stackscript linked above. You will need a GitHib [personal access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the scopes `admin:org, admin:public_key, repo`
2) SSH onto that machine
3) Spin up the docker container with `docker run -it tti`
4) Run either indexing or analysis commands, e.g.:
```bash
cd /thlib-texts-indexer
# activate the virtualenv
source .venv/bin/activate
./examples/index-all-texts.sh
```

## Running Intertextual Analysis

Currently there are two different strategies for running intertextual analyis in use. Steps for running each are below:

### TibetanData (Zach and Chonyi's work)

The following will run the analysis and index the results:

```bash
cd /thlib-texts/indexer
# activate the virtualenv
source .venv/bin/activate
set -o allexport; source /solr-variables; set +o allexport
python index.py -ttxd ../thlib-texts-xml -solr https://$SOLR_HOST -coll $SOLR_CORE -saxon ~/Downloads/saxon-8.jar --solr_auth $SOLR_USER:$SOLR_PASS\
-include ngb.pt,lccw --index_itx --tib_data_path ../TibetanData --itx_type itx
```

### tibetan-text-reuse (Tennom's work)

Analysis and indexing happen in two distinct steps:

```bash
cd /tibetan-text-reuse
# activate the virtualenv
source .venv/bin/activate
python bo_reuse/text_reuse.py  -c ../tti-texts/texts/lccw-raw.txt ../tti-texts/texts/ngb.pt-raw.txt -d . -o result.txt
```

The above script will take several hours to run. Once it is finished:

```bash
cd /thlib-texts-indexer
# activate the virtualenv
source .venv/bin/activate
set -o allexport; source /solr-variables; set +o allexport
python index.py -ttxd ../thlib-texts-xml -solr https://$SOLR_HOST -coll $SOLR_CORE -saxon ./saxon-8.jar --solr_auth $SOLR_USER:$SOLR_PASS\
--results_file ../tibetan-text-reuse/result.txt --text_file_1 ../tti-texts/texts/lccw.txt --text_file_2 ../tti-texts/texts/ngb.pt.txt --itx_type itx2
```
