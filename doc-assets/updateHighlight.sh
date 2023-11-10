#!/bin/sh

FILE=node_modules/@highlightjs/cdn-assets/highlight.min.js
if test -f $FILE; then
	echo "module installed"
	cat node_modules/@highlightjs/cdn-assets/highlight.min.js > doc-assets/highlight.js
	echo "\n" >> doc-assets/highlight.js
	cat node_modules/highlightjs-apex/dist/apex.min.js >> doc-assets/highlight.js
else
	curl -L "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/highlight.min.js" -o "doc-assets/highlight.js"
	echo >> "assets/highlight.js"
	curl -L "https://cdn.jsdelivr.net/npm/highlightjs-apex/dist/apex.min.js" >> "doc-assets/highlight.js"
fi

cp doc-assets/highlight.js docs/assets/highlight.js