debug:

	nodemon --watch app --watch lib --watch app.js --debug app.js

run:

	nodemon --watch app --watch lib --watch app.js app.js

compile:

	node app.js

prod:

	NODE_ENV=production node app.js

debug-inspector:

	node-inspector &

debug1:

	node --debug app

debug-brk:

	node --debug-brk app

test:

	@NODE_ENV=test ./node_modules/.bin/mocha $(arg)

testw:

	@NODE_ENV=test ./node_modules/.bin/mocha \
		--growl \
		--watch

testc:

	open http://localhost:3030/test

.PHONY: test testw testc run debug prod debug-inspector debug1 debug-brk compile
