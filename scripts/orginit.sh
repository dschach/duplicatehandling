#!/bin/bash

echo "Cleaning previous scratch org..."
sfdx force:org:delete -p -u DuplicatesHandler

echo "Creating new scratch org"
sfdx force:org:create -f config/project-scratch-def.json --durationdays 10 -a DuplicatesHandler -s

echo "Pushing metadata"
sfdx force:source:push

echo "Assigning Permissions"
sfdx force:user:permset:assign -n Duplicates_Handler

echo "Opening org"
sfdx force:org:open

echo "Org is set up"