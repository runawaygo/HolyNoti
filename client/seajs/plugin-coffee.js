
/**
 * @fileoverview The CoffeeScript plugin.
 */

define('plugin-coffee', ['plugin-base', 'coffee'], function(require) {

  var plugin = require('plugin-base');
  var CoffeeScript = window.CoffeeScript;


  plugin.add({
    name: 'coffee',

    ext: ['.coffee'],

    load: function(url, callback) {
      CoffeeScript.load(url, callback);
    }
  });

});
