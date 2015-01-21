PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean-docs clean build watch test dist publish

init:
	npm install

docs:
	docco src/*.coffee

clean-docs:
	rm -rf docs/

clean: clean-docs
	rm -rf lib/ test/*.js

build:
	coffee -o lib/ -c src/ && coffee -c test/*.coffee

watch:
	coffee -o lib/ -w src/

test:
	nodeunit test/*.js

dist: clean init docs build test

publish: dist
	npm publish
