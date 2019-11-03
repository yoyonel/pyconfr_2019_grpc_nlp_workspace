# https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: clean clean-build clean-pyc help
# https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
.DEFAULT_GOAL := help

#
PACKAGE_NAME=$(shell python setup.py --name)
PACKAGE_FULLNAME=$(shell python setup.py --fullname)
PACKAGE_VERSION:=$(shell python setup.py --version | tr + _)
#
PROJECT_NAME?=$(PACKAGE_NAME)
#
DOCKER_USER?=yoyonel
DOCKER_TAG?=$(DOCKER_USER)/$(PROJECT_NAME):${PACKAGE_VERSION}
#
PYPI_SERVER?=https://test.pypi.org/simple/
PYPI_SERVER_FOR_UPLOAD?=pypitest
PYPI_CONFIG_FILE?=${HOME}/.pypirc
PYPI_REGISTER?=
# https://stackoverflow.com/questions/2019989/how-to-assign-the-output-of-a-command-to-a-makefile-variable
PYPI_SERVER_HOST=$(shell echo $(PYPI_SERVER) | sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/")
PYTEST_OPTIONS?=-v
#
# SDIST_PACKAGE=dist/${shell python setup.py --fullname}.tar.gz
# SOURCES=$(shell find src/ -type f -name '*.py') setup.py MANIFEST.in

MONGODB_USER?=user
MONGODB_PASSWORD?=password
MONGODB_DBNAME?=pyconfr_2019_grpc_nlp
MONGODB_ADMIN_PASSWORD?=password

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: docker

pip-install:
	@pip install \
		-r requirements_dev.txt \
		--trusted-host $(PYPI_SERVER_HOST) \
		--extra-index-url $(PYPI_SERVER) \
		--upgrade

up:	## launch services from docker-compose project
	# https://stackoverflow.com/questions/30233105/docker-compose-up-for-only-certain-containers
	MONGODB_USER=${MONGODB_USER} \
	MONGODB_PASSWORD=${MONGODB_PASSWORD} \
	MONGODB_DBNAME=${MONGODB_DBNAME} \
	MONGODB_ADMIN_PASSWORD=${MONGODB_ADMIN_PASSWORD} \
	docker-compose \
		-f docker/docker-compose.yml \
		up ${DOCKERCOMPOSE_UP_OPTIONS}

up_mongodb:	## launch MongoDB service from docker-compose project
	# https://stackoverflow.com/questions/30233105/docker-compose-up-for-only-certain-containers
	MONGODB_USER=${MONGODB_USER} \
	MONGODB_PASSWORD=${MONGODB_PASSWORD} \
	MONGODB_DBNAME=${MONGODB_DBNAME} \
	MONGODB_ADMIN_PASSWORD=${MONGODB_ADMIN_PASSWORD} \
	docker-compose \
		-f docker/docker-compose.yml \
		up ${DOCKERCOMPOSE_UP_OPTIONS} \
			mongodb

up_mongodb_detach:	## launch MongoDB service from docker-compose project (in detach mode)
	DOCKERCOMPOSE_UP_OPTIONS="-d" make up_mongodb

up_storage_server:
	MONGODB_USER=${MONGODB_USER} \
	MONGODB_PASSWORD=${MONGODB_PASSWORD} \
	MONGODB_DBNAME=${MONGODB_DBNAME} \
	MONGODB_ADMIN_PASSWORD=${MONGODB_ADMIN_PASSWORD} \
	docker-compose \
		-f docker/docker-compose.yml \
		up ${DOCKERCOMPOSE_UP_OPTIONS} pyconfr_2019_grpc_nlp_server_storage
	

clean: clean-build ## remove all build, coverage and Python artifacts

clean-build: ## remove build artifacts
