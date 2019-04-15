#!/usr/bin/env bash

curl \
  -H "accept: application/json" \
  -X POST "http://localhost:8000/api/workflows/v1" \
  -F "workflowSource=@simple-hello.wdl"
