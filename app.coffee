fs = require 'fs'
child_process = require 'child_process'
express = require 'express'
app = express()
WebSocketServer = require('ws').Server
wss = new WebSocketServer(port: 7001)
broadcast = (msg) -> client.send(msg) for client in wss.clients

startServer = ->
	#also theoretically wss should start here...
	app.listen 7000
	console.log '''
	Open http://localhost:7000 in Chrome
	Press Ctrl+C to exit
	'''

[lineStart, lineEnd] = ['<div>', '</div>']

class TerminalToHTML
  constructor: (@yield=(->), @textcolor='', @background='', @buffer='') ->
  write: (data) =>
    @buffer += data
    lines = @buffer.split('\n')
    @buffer = lines.pop()

    for line in lines
      @yield lineStart
      @yield line
      @yield lineEnd

app.get '/', (req, res) ->
	res.sendfile 'client.html'


app.get '/command', (req, res) ->
  res.send(400) if not command = req.query.q
  res.writeHead(200)
  writer = new TerminalToHTML (html) -> res.write html

  gcc = child_process.spawn('bash', ['-c', command])
  gcc.stdout.on 'data', writer.write
  gcc.stderr.on 'data', writer.write
  gcc.on 'close', -> res.end()

fs.watch 'samples/', interval: 500, ->
  broadcast 'reload'

startServer()