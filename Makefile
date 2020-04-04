
# Release tag for the action
VERSION := v0.1

# GitHub Actions bogus variables
GITHUB_REF ?= refs/heads/null
GITHUB_SHA ?= aabbccddeeff

# Other variables and constants
CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
GITHUB_SHORT_SHA := $(shell echo $(GITHUB_SHA) | cut -c1-7)
RELEASE_BRANCH := master
DOCKER_USER_ID := christophshyper
DOCKER_IMAGE := action-tflint
DOCKER_NAME := $(DOCKER_USER_ID)/$(DOCKER_IMAGE)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Some cosmetics
SHELL := bash
define NL


endef
TXT_RED := $(shell tput setaf 1)
TXT_GREEN := $(shell tput setaf 2)
TXT_YELLOW := $(shell tput setaf 3)
TXT_RESET := $(shell tput sgr0)

build:
	$(info $(NL)$(TXT_GREEN) == STARTING BUILD ==$(TXT_RESET))
	$(info $(TXT_GREEN)Release tag:$(TXT_YELLOW)        $(VERSION)$(TXT_RESET))
	$(info $(TXT_GREEN)Current branch:$(TXT_YELLOW)     $(CURRENT_BRANCH)$(TXT_RESET))
	$(info $(TXT_GREEN)Commit hash:$(TXT_YELLOW)        $(GITHUB_SHORT_SHA)$(TXT_RESET))
	$(info $(TXT_GREEN)Build date:$(TXT_YELLOW)         $(BUILD_DATE)$(TXT_RESET))
	$(info $(NL)$(TXT_GREEN)Building Docker image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION)$(TXT_RESET))
	@docker build \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(GITHUB_SHORT_SHA) \
		--build-arg VERSION=$(VERSION) \
		--file=Dockerfile \
		--tag=$(DOCKER_NAME):$(VERSION) .
ifeq ($(CURRENT_BRANCH),$(RELEASE_BRANCH))
	$(info $(NL)$(TXT_GREEN) == STARTING DEPLOYMENT == $(TXT_RESET))
	$(info $(NL)$(TXT_GREEN)Logging to DockerHub$(TXT_RESET))
	@echo $(DOCKER_TOKEN) | docker login -u $(DOCKER_USER_ID) --password-stdin
	$(info $(NL)$(TXT_GREEN)Pushing image:$(TXT_YELLOW) $(DOCKER_NAME):$(VERSION)$(TXT_RESET))
	@docker tag $(DOCKER_NAME):$(VERSION) $(DOCKER_NAME):latest
	@docker push $(DOCKER_NAME):$(VERSION)
	@docker push $(DOCKER_NAME):latest
endif
