#!/usr/bin/env coffee

##
# texture-info
# an image infomation reader tool written in Node.JS
#
# Copyright (c) 2013 yi
# Licensed under the MIT license.
##

path = require "path"
fs = require "fs"
#p = require "commander"
_ = require "underscore"
texture_info = require "../lib/texture-info"

pathToFile = process.argv[2]

unless _.isString(pathToFile) and pathToFile.length > 0
  console.log "Usage: texture_info path_to_image_file"
  process.exit()

console.log "input file : #{pathToFile}"

texture_info.check pathToFile, (err, info)->
  if err?
    console.error "[texture-info::check] #{err}"
  else
    console.dir info
  process.exit()





