BUILD_FOLDER=.
LAST_COMMIT= $(shell git rev-parse HEAD)
IMAGE = $(APP):$(LAST_COMMIT)
IMAGE_REMOTE = $(REMOTE)/$(REGISTRY_PREFIX)/$(IMAGE)

deploy: build-image upload-acr

build-image:
	cd $(BUILD_FOLDER) && docker build -t $(IMAGE) .

upload-acr:
	docker tag $(IMAGE) $(IMAGE_REMOTE)
	docker push $(IMAGE_REMOTE)

.PHONY: deploy