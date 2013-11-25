express = require "express"
path = require "path"
format = require('util').format
texture_info = require "./texture-info"

app = express()
app.use(express.logger('dev'))
app.use(express.bodyParser())
#app.use(express.bodyParser(path.join(__dirname, "../temp/")))
app.use(express.static(path.join(__dirname, "../public")))



app.get '/', (req, res)->
  res.send '<form method="post" enctype="multipart/form-data">
    <p>SGF Image File(id: image): <input type="file" name="image" /></p>
    <p>Title(id: title):  <input type="text" name="title"></p>
    <p>Thumbnail0(id: thumb0): <input type="file" name="thumb0" /></p>
    <p>Thumbnail1(id: thumb1): <input type="file" name="thumb1" /></p>
    <p>Thumbnail2(id: thumb2): <input type="file" name="thumb2" /></p>
    <p><input type="submit" value="Upload" /></p>
    </form>'

app.post '/', (req, res, next)->

  console.log "[http_service::post] req.files"
  console.dir req

  try
    pathToFile = req.files.image.path
  catch err
    res.send
      'success' : false
      'msg' : "ERROR: fail to read upload file path. error:#{err}"
    return

  texture_info.check pathToFile, (err, info)->
    if err?
      res.send
        'success' : false
        'msg' : "ERROR: #{err}"
      return

    console.log "[http_service::post] texture-info:"
    console.dir info

    title = req.body.title || req.files.image.originalFilename

    res.send
      'success' : true
      'info' : info
      'title' : title
      'thumbs' : [
        req.files.thumb0.path,
        req.files.thumb1.path,
        req.files.thumb2.path,
      ]

app.listen 3030
console.log "[http_service] service start at 3030"




