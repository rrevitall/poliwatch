/**
 *  class TypeScriptEngine
 *
 *  Engine for the TypeScript compiler. You will need `node-typescript` Node
 *  module installed in order to use [[Mincer]] with `*.ts` files:
 *
 *      npm install node-typescript
 *
 *
 *  ##### SUBCLASS OF
 *
 *  [[Template]]
 **/


'use strict';


// stdlib
var extname = require("path").extname;


// 3rd-party
var _ = require('underscore');
var tsc; // initialized later
var path = require('path');

// internal
var Template  = require('mincer').Template;

var prop = function (obj, name, value, options) {
  var descriptor = _.extend({}, options, {value: value});
  Object.defineProperty(obj, name, descriptor);
};

////////////////////////////////////////////////////////////////////////////////


// Class constructor
var TypeScriptEngine = module.exports = function TypeScriptEngine() {
  Template.apply(this, arguments);
};


require('util').inherits(TypeScriptEngine, Template);


// Check whenever coffee-script module is loaded
TypeScriptEngine.prototype.isInitialized = function () {
  return !!tsc;
};


// Autoload coffee-script library
TypeScriptEngine.prototype.initializeEngine = function () {
  tsc = this.require('node-typescript/lib/compiler');
};


// Internal (private) options storage
var options = {bare: true};


/**
 *  TypeScriptEngine.setOptions(value) -> Void
 *  - value (Object):
 *
 *  Allows to set CoffeeScript compilation options.
 *  Default: `{bare: true}`.
 *
 *  ##### Example
 *
 *      CoffeeScript.setOptions({bare: true});
 **/
TypeScriptEngine.setOptions = function (value) {
  options = _.clone(value);
};


// Render data
TypeScriptEngine.prototype.evaluate = function (context, locals, callback) {
  try {
    var compiler = tsc.compiler
    tsc.initDefault()
    compiler.setErrorCallback(function (start, len, message, block) {
      var err = ['[typescript] (', start, ':', len + ') compilation error: ', message].join('')
      callback(err)
    });
    var filename = this.file
    var destFilename = filename.slice(0, -3) + '.js'
    tsc.resolve(filename, this.data, compiler)
    compiler.typeCheck()
    var stdout = new tsc.EmitterIOHost
    compiler.emit(stdout)
    callback(null, stdout.fileCollection[destFilename].lines.join('\n'))
  } catch (err) {
    callback(err);
  }
};


// Expose default MimeType of an engine
prop(TypeScriptEngine, 'defaultMimeType', 'application/javascript');
