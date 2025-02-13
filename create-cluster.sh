#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2022 Buoyant Inc.
# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2022 Buoyant Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.  You may obtain
# a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

clear

# Create a K3d cluster to run the Faces application.
CLUSTER=${CLUSTER:-gateway-api-workshop}
# echo "CLUSTER is $CLUSTER"

# Ditch any old cluster...
k3d cluster delete $CLUSTER &>/dev/null

#@SHOW

# Expose ports 80 and 443 to the local host, so that our ingress can work.
# Don't install traefik - we'll use Istio or Envoy Gateway with Linkerd instead.
k3d cluster create $CLUSTER \
	-p "80:80@loadbalancer" -p "443:443@loadbalancer" \
	--k3s-arg '--disable=traefik@server:*;agents:*'

# Import cached images from local registry, if present.
for image in \
  docker.io/istio/proxyv2:1.20.3 \
  docker.io/istio/pilot:1.20.3 \
  ghcr.io/buoyantio/faces-workload:1.1.0 \
  ghcr.io/buoyantio/faces-gui:1.1.0 \
  cr.l5d.io/linkerd/policy-controller:edge-24.3.3 \
  cr.l5d.io/linkerd/controller:edge-24.3.3 \
  cr.l5d.io/linkerd/proxy:edge-24.3.3 \
  cr.l5d.io/linkerd/proxy-init:v2.2.4 \
  envoyproxy/envoy:distroless-v1.29.2 \
  envoyproxy/gateway-dev:72c0cc7 \
  docker.io/envoyproxy/gateway:v1.0.0 \
  ; do \
  c=$(docker images --format '{{ .Repository }}:{{ .Tag }}' | grep -c "$image") ;\
  if [ $c -gt 0 ]; then \
    echo "Loading $image from local cache" ;\
    k3d image import -c $CLUSTER "$image" ;\
  fi ;\
done

#@wait
#@HIDE

# if [ -f images.tar ]; then k3d image import -c ${CLUSTER} images.tar; fi
# #@wait
