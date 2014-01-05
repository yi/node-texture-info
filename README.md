# texture-info

An image infomation reader tool for a set of custom image formats

## Install
```bash
sudo npm install coffee-script -g
# 这个项目已经被切换成私有项目，因此请从目录本地安装
sudo npm install . -g
```

## Usage

Use in command line

```bash

Usage: texture-info.coffee [options]

Options:

  -h, --help                   output usage information
  -V, --version                output the version number
  -o, --output [VALUE]         output directory
  -i, --input [VALUE]          input file
  -c, --forceRegPointToCenter  only work with -i switcher, when this switcher is turned on, the output image will use forced register point at the middle of the canvas

```

Use in JavaScript/CoffeeScript
```coffee
texture_info.check pathToFile, (err, info)->
  if err?
    logger.error "[texture-info::check] #{err}"
  else
    console.dir info
```

## License
Copyright (c) 2013 yi
Licensed under the MIT license.
