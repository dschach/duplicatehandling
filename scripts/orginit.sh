#!/bin/bash

echo "Cleaning previous scratch org..."
sf org delete scratch --no-prompt --target-org DuplicatesHandler

echo "Creating new scratch org"
sf org create scratch --definition-file config/project-scratch-def.json --duration-days 10 --alias DuplicatesHandler --no-namespace --set-default

echo "Pushing metadata"
sf project deploy start --source-dir force-app

echo "Assigning Permissions"
sf org assign permset --name Duplicates_Handler

echo "Opening org"
sf org open

echo "Org is set up"