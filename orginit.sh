#!/bin/bash

sfdx force:org:create -f config/project-scratch-def.json --durationdays 10 -a DuplicatesHandler -s

sfdx force:source:push

sfdx force:user:permset:assign -n Duplicates_Handler

sfdx force:org:open

echo "Org is set up"