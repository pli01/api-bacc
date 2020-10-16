### wrapper around docker-compose

# default variables
include Makefile.mk
export

check-dc-config-dev:
	${DC} -f $(DC_DEV) config -q

up-dev: check-dc-config-dev
	${DC} -f ${DC_DEV} up ${DC_RUN_ARGS}
down-dev: check-dc-config-dev
	${DC} -f ${DC_DEV} down

check-dc-config-prod:
	${DC} -f $(DC_PROD) config -q
build: check-dc-config-prod
	${DC} -f ${DC_PROD} build ${DC_BUILD_ARGS}
up: check-dc-config-prod
	${DC} -f ${DC_PROD} up ${DC_RUN_ARGS}
down: check-dc-config-prod
	${DC} -f ${DC_PROD} down

test: wait-db test-up-db test-up-api

wait-db: ## wait db container up and running
	time bash -x tests/wait-db.sh
test-up-db: ## test db container up and running
	time bash -x tests/test-up-db.sh

test-up-api: ## test api container up and running
	time bash -x tests/test-up-api.sh


# import
import: clean-data get-data convert-data import-data-via-api

clean-data:
	rm -rf data/caracteristique*.csv data/caracteristique*.json || true

get-data:
	( cd data ; bash ../scripts/get-datasets.sh )

convert-data:
	${DC} -f ${DC_IMPORT} up
	${DC} -f ${DC_IMPORT} down

convert-data-to-mongoimport:
	( cd data ; bash ../scripts/convert-data-to-mongoimport.sh )

import-data-via-mongoimport:
	bash scripts/mongoimport-json.sh

import-data-via-api:
	( cd data ; bash ../scripts/import-datasets.sh )
