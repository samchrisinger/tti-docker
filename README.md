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
