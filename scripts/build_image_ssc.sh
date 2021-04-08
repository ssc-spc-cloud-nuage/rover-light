#!/bin/bash

set -e
./scripts/pre_requisites.sh


case "$1" in 
    "github")
        tag=$(date +"%g%m.%d%H%M")
        rover="sscspccloudnuage/rover-light:${tag}"
        ;;
    "dev")
        tag=$(date +"%g%m.%d%H%M")
        rover="sscspccloudnuage/roverdev-light:${tag}"
        ;;
    *)
        tag=$(date +"%g%m.%d%H%M")
        rover="sscspccloudnuage/roverdev-light:${tag}"
        ;;
esac

echo "Creating version ${rover}"

# Build the rover base image
docker-compose build --build-arg versionRover=${rover}

case "$1" in 
    "github")
        docker tag workspace_rover ${rover}
        docker tag workspace_rover sscspccloudnuage/rover-light:latest

        docker push sscspccloudnuage/rover-light:${tag}
        docker push sscspccloudnuage/rover-light:latest

        echo "Version sscspccloudnuage/rover-light:${tag} created."
        echo "Version sscspccloudnuage/rover-light:latest created."
        ;;
    "dev")
        docker tag workspace_rover sscspccloudnuage/roverdev-light:${tag}
        docker tag workspace_rover sscspccloudnuage/roverdev-light:latest

        docker push sscspccloudnuage/roverdev-light:${tag}
        docker push sscspccloudnuage/roverdev-light:latest
        echo "Version sscspccloudnuage/roverdev-light:${tag} created."
        echo "Version sscspccloudnuage/roverdev-light:latest created."
        ;;
    *)    
        docker tag workspace_rover sscspccloudnuage/roverdev-light:${tag}
        docker tag workspace_rover sscspccloudnuage/roverdev-light:latest
        echo "Local version created"
        echo "Version sscspccloudnuage/roverdev-light:${tag} created."
        echo "Version sscspccloudnuage/roverdev-light:latest created."
        ;;
esac
