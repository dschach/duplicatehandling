#!/bin/bash

sfdx update
npm install
npm update
npm install --save-dev eslint-plugin-prettier
npm install --save-dev prettier prettier-plugin-apex
npm install --save-dev eslint-config-prettier

# upgrade all packages to latest versions
npm update
npm ci