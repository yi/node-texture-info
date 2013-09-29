#!/usr/bin/env coffee

##
# texture-info
# an image infomation reader tool written in Node.JS
#
# Copyright (c) 2013 yi
# Licensed under the MIT license.
##

fs = require "fs"
p = require "commander"
logger = require "dev-logger"
_ = require "underscore"
texture_info = require "../lib/texture-info"

## settings scarfollding

settings =

## updating args
p.version('0.1.0')
  .option('-f, --input-file <FILE>', 'path to image file to be checked')
  .parse(process.argv)

#logger.setLevel(if settings.VERBOSE then logger.LOG else logger.INFO)
#console.log settings

texture_info.check p.inputFile, (err, info)->
  if err?
    logger.error "[texture-info::check] #{err}"
  else
    console.dir info





