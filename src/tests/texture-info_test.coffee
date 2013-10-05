require 'mocha'
should = require('chai').should()
texture_info = require "../texture-info"
path = require "path"


describe "texture-info", ()->
  describe "isSGFAnimation()", ()->

    it "should work correctly on sgf animation file", (done)->
      texture_info.isSGFAnimation  path.join(__dirname, "../../fixtures/38d4218a452.sgf"), (err, result)->
        should.not.exist err
        result.should.be.true
        done()

    it "should work correctly on non-sgf animation file", (done)->
      texture_info.isSGFAnimation  path.join(__dirname, "../../fixtures/4f1a9820b8b.sgf"), (err, result)->
        should.not.exist err
        result.should.not.be.true
        done()

