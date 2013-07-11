require('source-map-support').install();
require('typescript-require')();
require('iced-coffee-script');
# Ensure require(x.coffee) always uses Iced Coffee Script.
Object.defineProperty require.extensions, '.coffee',
  writable: false
require('main/app').start();
