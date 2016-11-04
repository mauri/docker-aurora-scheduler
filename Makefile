BASE_REPO=docker.m8s.io/medallia
AURORA_VERSION=0.13.0
AURORA_RELEASE=$(AURORA_VERSION)-medallia-2
# can be used to customize the release name (e.g. pre-release)
GITHUB_AURORA_RELEASE=$(AURORA_RELEASE)
AURORA_SNAPSHOT=https://github.com/medallia/aurora/archive/rel/$(AURORA_RELEASE).tar.gz
AURORA_PACKAGE_BRANCH=0.13.x

define fetch_aurora
	cd scratch && \
  	curl -L -o "snap.tar.gz" $(AURORA_SNAPSHOT) && \
  	tar -xvzf snap.tar.gz && \
  	mv aurora-rel-$(AURORA_VERSION)-medallia apache-aurora-$(AURORA_VERSION) && \
  	tar -czvf snap.tar.gz apache-aurora-$(AURORA_VERSION) && \
	rm -rf apache-aurora-$(AURORA_VERSION)
endef

define fetch_aurora_packaging 
	if [ ! -d scratch/aurora-packaging ]; then \
		git clone https://github.com/apache/aurora-packaging.git scratch/aurora-packaging; \
	fi
	
	cd scratch/aurora-packaging && \
	git fetch origin "$(AURORA_PACKAGE_BRANCH)" && \
    	git checkout "$(AURORA_PACKAGE_BRANCH)"
endef

## Create .debs and .rpms using aurora-packaging
## .rpms are renamed so they follow the standard AURORA_RELEASE convention naming 
define build_artifacts
	cd scratch/aurora-packaging && \
    	-./build-artifact.sh ../snap.tar.gz $(AURORA_RELEASE) 
	-mkdir scratch/artifacts
	find . \( -path \*ubuntu\*.deb -o -path \*centos\*.rpm \) -exec cp {} scratch/artifacts \;  && \
		for f in scratch/artifacts/*.rpm; do mv "$$f" "$${f/$(subst -,_,$(AURORA_RELEASE))/$(AURORA_RELEASE)}"; done 
endef

define get_upload_url
	if [ -z $(GITHUB_TOKEN) ]; then \
		echo "Missing GITHUB_TOKEN environment variable"; \
		exit 1; \
	fi
	
	$(eval UPLOAD_URL:=$(shell curl -s -H 'Authorization: token $(GITHUB_TOKEN)' https://api.github.com/repos/medallia/aurora/releases/tags/$(GITHUB_AURORA_RELEASE) | grep upload_url | awk '{print $$2}' | awk -F'{' '{sub(/\"/, "", $$1); print $$1}' ))

	if [ -z $(UPLOAD_URL) ]; then \
  		echo "Could not find release with name $(GITHUB_AURORA_RELEASE)"; \
  		echo "Check release or credentials"; \
 	 	exit 1; \
	fi
endef

define upload_artifact
	if [ ! -f $(1) ]; then \
    		echo "Cannot find package $(1)"; \
    		exit 1; \
  	fi

	echo "Uploading artifact $(1)"
  	
	RES=$(shell curl -# -XPOST -H "Authorization:token $(GITHUB_TOKEN)" -H "Content-Type:application/octet-stream" --data-binary @$(1) $(UPLOAD_URL)?name=$(notdir $(1))); \
	echo $$RES; \
	if [ -z $(shell echo "$$RES" | grep -o "\"state\":Th\"[a-z]*") ]; then \
    		echo "Upload failed for $(1)"; \
    		echo "Is the package already uploaded ? Delete first"; \
    		echo "$(RES)" | grep -o 'message\":\"[A-Za-z ]*'\"; \
    		exit 1; \
	fi
endef

define build_docker
	echo $(1)
	cd $(1); \
	TAG=$(shell cat $(1)/TAG); \
	docker build -t "medallia/aurora-scheduler:$$TAG" \
		 -f Dockerfile --build-arg "GITHUB_AURORA_RELEASE=$(GITHUB_AURORA_RELEASE)" \
		 --build-arg "AURORA_RELEASE=$(AURORA_RELEASE)" . ; \
	docker tag medallia/aurora-scheduler:$$TAG $(BASE_REPO)/aurora-scheduler:$$TAG
endef

define publish_docker
	TAG=$(shell cat $(1)/TAG); \
	docker push $(BASE_REPO)/aurora-scheduler:$$TAG
endef

build-artifacts:
	@echo "AURORA-PACKAGING-BRANCH $(AURORA_PACKAGE_BRANCH)"
	@echo "RELEASE $(AURORA_RELEASE)"
	@echo "SNAPSHOT $(AURORA_SNAPSHOT)"

	-mkdir -p scratch
	$(call fetch_aurora)
	$(call fetch_aurora_packaging)
	$(call build_artifacts)

publish-artifacts:
	@echo "Uploading artifacts for $(AURORA_RELEASE) to $(GITHUB_AURORA_RELEASE)"
	$(call get_upload_url)
	$(foreach artifact,$(sort $(wildcard $(PWD)/scratch/artifacts/*)),$(call upload_artifact,$(artifact));)

build-images:
	@echo "Building Docker images dor $(AURORA_RELEASE)"
	$(foreach dir,$(sort $(dir $(wildcard dockerfile-templates/*/))),$(call build_docker,$(dir));)

publish-images:
	@echo "Publishing Docker images for Mesos"
	$(foreach dir,$(sort $(dir $(wildcard dockerfile-templates/*/))),$(call publish_docker,$(dir));)

clean:
	@rm -rf scratch

.PHONY: build-artifacts plublish-artifacts build-image clean
