#!/bin/bash
dnf clean all
dnf -y module install nvidia-driver:latest-dkms
dnf -y install cuda