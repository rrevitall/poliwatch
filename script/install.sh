# Add a line for each submodule which needs to be installed.
#(cd lib/foo && npm install)

# Install vendor assets with Bower.
./node_modules/bower/bin/bower install

# Manually list dependencies here.
./node_modules/tsd/deploy/tsd install express
