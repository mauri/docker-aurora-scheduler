AURORA_IMAGE_VERSION=v2.2.0
AURORA_VERSION=0.13.0
AURORA_RELEASE=$(AURORA_VERSION)-medallia-2
AURORA_SNAPSHOT=https://github.com/medallia/aurora/archive/rel/$(AURORA_RELEASE).tar.gz
AURORA_PACKAGE_BRANCH=0.13.x

GITHUB_AURORA_RELEASE=$(AURORA_VERSION)-medallia-2-full

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

define build_artifacts
	cd scratch/aurora-packaging && \
    	./build-artifact.sh ../snap.tar.gz $(AURORA_RELEASE)  
	@mkdir scratch/artifacts
	find . \( -path \*ubuntu\*.deb -o -path \*centos\*.rpm \) -exec cp {} scratch/artifacts
endef

define def_upload_url
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

define build_docker_image
	cd $(1) && \
	docker build -t "medallia/aurora-scheduler:$(AURORA_IMAGE_VERSION)-$(AURORA_RELEASE)-$(shell basename $(1))" \
		 -f Dockerfile --build-arg "AURORA_RELEASE=$(AURORA_RELEASE)" .
endef

build-artifacts:
	@echo "AURORA-PACKAGING-BRANCH $(AURORA_PACKAGE_BRANCH)"
	@echo "RELEASE $(AURORA_RELEASE)"
	@echo "SNAPSHOT $(AURORA_SNAPSHOT)"

	@mkdir -p scratch
	$(call fetch_aurora)
	$(call fetch_aurora_packaging)
	$(call build_artifacts)

publish-artifacts:
	@echo "Uploading artifacts for $(AURORA_RELEASE) to $(GITHUB_AURORA_RELEASE)"
	$(call def_upload_url)
	$(foreach artifact,$(sort $(wildcard $(PWD)/scratch/artifacts/*)),$(call upload_artifact,$(artifact));)

build-images:
	@echo "Building Docker image $(AURORA_RELEASE)"
	$(foreach dir,$(sort $(dir $(wildcard $(PWD)/dockerfiles/*/))),$(call build_docker_image,$(dir),$(shell basename $(dir)));)

clean:
	@rm -rf scratch

.PHONY: build-artifacts plublish-artifacts build-image clean

