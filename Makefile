test:
	$(eval export env_stub=test)
	@true

integration:
	$(eval export env_stub=integration)
	@true

live:
	$(eval export env_stub=live)
	@true

init:
	$(eval export ECR_REPO_NAME_SUFFIXES=base web api)
	$(eval export ECR_REPO_URL_ROOT=926803513772.dkr.ecr.eu-west-1.amazonaws.com/formbuilder)

# install aws cli w/o sudo
install_build_dependencies: init
	docker --version
	pip install --user awscli
	$(eval export PATH=${PATH}:${HOME}/.local/bin/)


# Needs ECR_REPO_NAME & ECR_REPO_URL env vars
build: install_build_dependencies
	TAG="latest-${env_stub}" REPO_SCOPE=${ECR_REPO_URL_ROOT} ./scripts/build_all.sh

push: init
	TAG="latest-${env_stub}" REPO_SCOPE=${ECR_REPO_URL_ROOT} ./scripts/push_all.sh

build_and_push: install_build_dependencies
	TAG="latest-${env_stub}" REPO_SCOPE=${ECR_REPO_URL_ROOT} ./scripts/build_and_push_all.sh

.PHONY := init push build login
