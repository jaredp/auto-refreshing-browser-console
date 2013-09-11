fs = require 'fs'
child_process = require 'child_process'
express = require 'express'
app = express()
app.use('/public', express.static(__dirname + '/public'));
WebSocketServer = require('ws').Server

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


class SourceWatcher
  constructor: (@dir, @onchange, @pauseCount = 0) -> @watch()
  watch: -> @watcher = fs.watch @dir, @onchange
  stop: -> @watcher?.close(); @watcher = null
  pause: -> @stop() if @pauseCount++ == 0
  unpause: -> @watch() if --@pauseCount == 0

{p: port, d: rootDir} = require('optimist')
  .default(p: 7000, d: '.')
  .argv

watcher = new SourceWatcher rootDir, -> broadcast 'reload'
app.listen port
wss = new WebSocketServer(port: port + 1)
console.log """
Open http://localhost:#{port}/ in Chrome
Press Ctrl+C to exit
"""


broadcast = (msg) -> client.send(msg) for client in wss.clients

app.get '/', (req, res) ->
  res.sendfile(__dirname + '/public/client.html')

app.get '/command', (req, res) ->
  return res.send(400) if not command = req.query.q
  
  res.writeHead(200)
  rewriter = new TerminalToHTML (html) -> res.write html
  watcher.pause()

  gcc = child_process.spawn('bash', ['-c', command], cwd: rootDir)
  gcc.stdout.on 'data', rewriter.write
  gcc.stderr.on 'data', rewriter.write
  gcc.on 'close', ->
    res.end()

    # without setTimeout, sometimes infinite loops
    setTimeout (-> watcher.unpause()), 0
    
  gcc.stdin.end()

