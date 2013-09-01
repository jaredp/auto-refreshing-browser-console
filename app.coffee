fs = require 'fs'
child_process = require 'child_process'
express = require 'express'
app = express()
app.use('/public', express.static(__dirname + '/public'));
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

class TerminalToHTML
  [lineStart, lineEnd] = ['<div>', '</div>']

  constructor: (@yield=(->), @textcolor='', @background='', @buffer='') ->
  write: (data) =>
    @buffer += data.toString()
    lines = @buffer.split('\n')
    @buffer = lines.pop()

    for line in lines
      @yield lineStart
      @yield line
      @yield lineEnd

app.get '/', (req, res) ->
	res.sendfile(__dirname + '/public/client.html')

rootDir = process.argv[2] ? '.'

app.get '/command', (req, res) ->
  return res.send(400) if not command = req.query.q
  
  res.writeHead(200)
  rewriter = new TerminalToHTML (html) -> res.write html

  gcc = child_process.spawn('bash', ['-c', command], cwd: rootDir)
  gcc.stdout.on 'data', rewriter.write
  gcc.stderr.on 'data', rewriter.write
  gcc.on 'close', -> res.end()
  gcc.stdin.end()

fs.watch rootDir, interval: 500, ->
  broadcast 'reload'

startServer()

