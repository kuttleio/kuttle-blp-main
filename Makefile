.EXPORT_ALL_VARIABLES:
TF_S3_PATH := $(shell git rev-parse --show-prefix)
TF_BUCKET_REGION := eu-central-1
DIR := $(shell pwd)

ifndef TOPDIR
	TOPDIR := $(shell git rev-parse --show-toplevel)
endif

.PHONY: all

include $(TOPDIR)/terraform/_makefile
