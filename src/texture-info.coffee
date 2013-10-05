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

    # verify sgf file signature
    signature = bytearray.readUTFBytes(buf, SGF_FILE_SIGNATURE.length, buf.length - SGF_FILE_SIGNATURE.length)
    logger.log "[texture-info::readAniInfoFromSGFFormat] signature:#{signature}"

    unless signature is SGF_FILE_SIGNATURE
      err = "verification failed"
      logger.log "[texture-info::readAniInfoFromSGFFormat] #{err}"
      callback()
      # NOTE:
      #   当文件中不包含sgf 签名的适合，不被认为是异常
      # ty 2013-09-29
      return

    # calc the read starting position
    buf.position = buf.position - 4 - SGF_FILE_SIGNATURE.length
    amfLen = bytearray.readUnsignedInt(buf)
    buf.position = buf.position - 4 - amfLen

    # 开始读取具体数据
    canvasWidth = bytearray.readUnsignedShort(buf)
    canvasHeight= bytearray.readUnsignedShort(buf)

    # 美术编辑时设定的 坐标点 */
    regPointX = bytearray.readShort buf
    regPointY = bytearray.readShort buf
    assetFrameNum = bytearray.readUnsignedShort buf

    logger.log "[texture-info::readAniInfoFromSGFFormat] amfLen:#{amfLen}, canvasWidth:#{canvasWidth}, canvasHeight:#{canvasHeight}, regPointX:#{regPointX}, regPointY:#{regPointY}"

    # 每帧动画在png压缩画布上的 x,y,w,h
    assetRects = []

    # 每帧动画在原尺寸画布上的 x,y,w,h
    originalRects = []

    yScroll = 0
    for i in [0...assetFrameNum] by 1
      left = bytearray.readShort buf
      top = bytearray.readShort  buf
      width = bytearray.readShort buf
      height = bytearray.readShort buf

      originalRects.push
        left : left
        top : top
        width : width
        height : height

      assetRects.push
        left : 0
        top : yScroll
        width : width
        height : height

      yScroll += height

    result =
      canvasWidth : canvasWidth
      canvasHeight : canvasHeight
      regPointX : regPointX
      regPointY : regPointY
      assetFrameNum : assetFrameNum
      assetRects : assetRects
      originalRects : originalRects

    callback null, result
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
              if sgfInfo?
                sgfInfo["sourceImage"] = imgInfo
                sgfInfo["format"] = "SGF ANIMATION"
                callback null, sgfInfo
              else
                callback imgInfo
        else
          callback imgInfo
          return

  return
