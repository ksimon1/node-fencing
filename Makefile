# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(REGISTRY),)
	REGISTRY = nodefencing/
endif

ifeq ($(VERSION),)
	VERSION = latest
endif

IMAGE_CONTROLLER = $(REGISTRY)standalone-fence-controller:$(VERSION)
CONTROLLER_PATH = standalone-controller/
IMAGE_AGENT = $(REGISTRY)agent-image:$(VERSION)
AGENT_PATH = agent-job-image/

.PHONY: all controller clean test

all: controller

agent:
	go build -o agent-job-image/plugged-fence-agents/fetch_passwd cmd/fetch-password.go
	docker build -t $(IMAGE_AGENT) $(AGENT_PATH)
	sudo docker push $(IMAGE_AGENT)

controller: agent
	go build -i -o standalone-controller/_output/bin/node-fencing-controller cmd/node-fencing-controller.go
	docker build -t $(IMAGE_CONTROLLER) $(CONTROLLER_PATH)
	sudo docker push $(IMAGE_CONTROLLER)

clean:
	-rm -rf _output

test:
	go test `go list ./... | grep -v 'vendor'`
