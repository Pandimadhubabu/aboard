express = require 'express'
app = do express
app.configure -> app.use express.static __dirname + '/public'
app.listen Number process.env.PORT or 5000