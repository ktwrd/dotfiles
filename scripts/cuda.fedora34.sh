#!/bin/bash
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora34/x86_64/cuda-fedora34.repo
bash install.sh cuda