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
p = require "commander"
_ = require "underscore"
texture_info = require "../lib/texture-info"
async = require "async"
child_process = require 'child_process'

## 更新外部配置
p.version('0.0.1')
  .option('-o, --output [VALUE]', 'output directory')
  .option('-i, --input [VALUE]', 'input file')
  .parse(process.argv)


# 将 rect 转换为 gm 所接受的 geometry 格式字符串
rectToGeom = (rect)->
  left = rect.left
  if left >= 0 then left = "+#{left}"
  top = rect.top
  if top >= 0 then top = "+#{top}"
  "#{rect.width}x#{rect.height}#{left}#{top}"

unless _.isString(p.input) and p.input.length > 0
  console.log "Usage: texture_info -i path_to_image_file [-o output directory]"
  process.exit()

console.log "input file : #{p.input}"

texture_info.check p.input, (err, info)->
  if err?
    console.error "[texture-info::check] #{err}"
    return

  console.log "image detailed information:"
  console.dir info

  process.exit() unless p.output

  unless info.format is 'SGF ANIMATION'
    console.error "ERROR: input file is not a composit animation png file"
    process.exit()
    return

  try
    stat = fs.statSync p.output
  catch err
    console.error "ERROR: path:#{p.output} is not a directory"
    process.exit()
    return

  unless stat.isDirectory()
    console.error "ERROR: path:#{p.output} is not a directory"
    process.exit()
    return

  originalRects = info.originalRects
  assetRects = info.assetRects

  basename = path.basename(p.input, (path.extname(p.input)))

  pathToSgfFile = path.relative p.output, p.input

  async.eachSeries assetRects, (assetRect, callback)->
    index = assetRects.indexOf assetRect
    originalRect = originalRects[index]
    index = "0#{index}" if index < 10

    # 将 sgf 文件切成一帧一个小文件
    command = "cd #{p.output} && "
    command += " gm convert -gravity NorthWest -crop #{rectToGeom(assetRect)}  #{pathToSgfFile} #{basename}-#{index}.tmp.png && "


    command += " gm convert -background transparent "
    command += " -compose Copy -page +#{originalRect.left}+#{originalRect.top}  #{basename}-#{index}.tmp.png  "
    command += " -mosaic #{basename}-#{index}.png  && "

    # 将画布放大到GPU贴图尺寸
    command += "gm convert #{basename}-#{index}.png  -background transparent -extent #{info.canvasWidth}x#{info.canvasHeight}  #{basename}-#{index}.png && "

    # 移除零时文件
    command += "rm -f *.tmp.png "


    console.log "decompile #{basename}-#{index}.png  "

    envObj = cwd : p.output
    # 将png动画序列根据 MaxRects 的数据拼合成大贴图png
    child_process.exec command, envObj, (err, stdout, stderr)->
      if err?
        callback "fail to gm convert image, error:#{err}"
        return

      callback()
      return

  ,(err)->
    if err?
      console.error "ERROR: #{err}"

