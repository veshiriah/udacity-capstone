#!/usr/bin/env bash

## Complete the following steps to get Docker running locally

# Step 1:
# Build image and add a descriptive tag
docker build --tag=kchachowska/udacity-capstone-kc

# Step 2: 
# List docker images
docker image ls

# Step 3: 
# Run nginx docker run --name mynginx1 -p 80:80 -d nginx
docker run -p 80:80 kchachowska/udacity-capstone-kc