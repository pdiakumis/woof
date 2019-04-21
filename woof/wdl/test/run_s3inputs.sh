#!/usr/bin/env bash

curl \
  -H "accept: application/json" \
  -X POST "http://localhost:8000/api/workflows/v1" \
  -F "workflowSource=@3a-s3inputs.wdl" \
  -F "workflowInputs=@3b-s3inputs.json"
