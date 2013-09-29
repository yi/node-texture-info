##
# texture-info
# https://github.com/yi/node-texture-info
#
# Copyright (c) 2013 yi
# Licensed under the MIT license.
##

fs = require 'fs'
gm = require 'gm'
bytearray = require "bytearray"
logger = require 'dev-logger'
_ = require "underscore"


# 存储帧队列位图数据的 PNG 文件末端的签名。SGF-asset
SGF_FILE_SIGNATURE = "SGF-asset"

# 串行化成二进制流时的数据签名
SGF_SERIALISED_BA_SIGNATURE = 50807718

readAniInfoFromSGFFormat = (pathToImgFile, callback)->
  fs.readFile pathToImgFile, (err, buf)->
    if err?
      err = "fail to read file, error:#{err}"
      callback(err)
      return

    signature = bytearray.readUTFBytes(buf, SGF_FILE_SIGNATURE.length, buf.length - SGF_FILE_SIGNATURE.length)
    logger.log "[texture-info::readAniInfoFromSGFFormat] signature:#{signature}"

    unless signature is SGF_FILE_SIGNATURE
      err = "verification failed"
      logger.error "[texture-info::readAniInfoFromSGFFormat] #{err}"
      callback(err)
      return


# check the given image
# @param {String} pathToImgFile
# @param {Funcation} callback signature: callback(err, infoData)->
exports.check = (pathToImgFile, callback)->
  unless fs.existsSync pathToImgFile
    throw new Error "missing file at #{pathToImgFile}"

  unless _.isFunction callback
    throw new Error "missing file callback"

  # TODO:
  #   check atf header
  # ty 2013-09-29

  gm(pathToImgFile).identify (err, imgInfo)->
    if err?
      err = "fail to identify image, error:#{err}"
      callback(err)
      return
    else
      console.dir imgInfo
      switch imgInfo.format
        when 'PNG'
          readAniInfoFromSGFFormat pathToImgFile, (err, sgfInfo)->
            if err?
              err = "fail to read sgf info, error:#{err}"
              callback(err)
            else
              sgfInfo["sourceImage"] = imgInfo if sgfInfo?
              callback null, if sgfInfo? then sgfInfo else imgInfo
        else
          return imgInfo

  return
