#!/bin/sh

curl -L "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js" -o "doc-assets/highlight.js"
echo >> "doc-assets/highlight.js"
curl -L "https://cdn.jsdelivr.net/npm/highlightjs-apex@1/dist/apex.min.js" >> "doc-assets/highlight.js"

curl -L "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11/build/highlight.min.js" -o "docs/assets/highlight.js"
echo >> "docs/assets/highlight.js"
curl -L "https://cdn.jsdelivr.net/npm/highlightjs-apex@1/dist/apex.min.js" >> "docs/assets/highlight.js"