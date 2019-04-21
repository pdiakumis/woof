#!/usr/bin/env bash

curl \
  -H "accept: application/json" \
  -X POST "http://localhost:8000/api/workflows/v1" \
  -F "workflowSource=@2a-hello-aws.wdl" \
  -F "workflowInputs=@2b-hello-aws.json"
