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
  res.send('<form method="post" enctype="multipart/form-data"><p></p><p>Image: <input type="file" name="image" /></p><p><input type="submit" value="Upload" /></p></form>')

app.post '/', (req, res, next)->

  console.dir req.files

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

    else
      res.send
        'success' : true
        'info' : info
      #res.send(format('%j', info))

  #res.send(format('\n lalal uploaded %s (%d Kb) to %s as %s' , req.files.image.name , req.files.image.size / 1024 | 0 , req.files.image.path , req.body.title))



#app.get "/", (req, res)->
  #res.send "web service for sgf texture-info, please post to /exame"

#app.post "/exame", (req, res)->
  #res.send "web service for sgf texture-info"

app.listen 3030
console.log "[http_service] service start at 3030"




