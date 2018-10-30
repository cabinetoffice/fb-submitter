dev:
	$(eval export env_stub=dev)
	@true

staging:
	$(eval export env_stub=staging)
	@true

production:
	$(eval export env_stub=production)
	@true

init:
	$(eval export ECR_REPO_NAME_SUFFIXES=base web api)
	$(eval export ECR_REPO_URL_ROOT=926803513772.dkr.ecr.eu-west-1.amazonaws.com/formbuilder-dev)

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

.PHONY := init push build login
