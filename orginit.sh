#!/bin/bash

sfdx force:org:create -f config/project-scratch-def.json --durationdays 10 -a DuplicatesHandler -s

sfdx force:source:push

sfdx force:user:permset:assign -n Duplicates_Handler

sfdx force:org:open

echo "Org is set up"

#Version Increase Comment


#Deploy to ActionPlans Dev/Packaging Org: Use -c to check only first
#
#sfdx force:source:deploy -u ActionPlansPackagingOrg -w 100 -p force-app/main/default