fs = require 'fs'
events = require 'events'
path = require 'path'

CoffeeScript = require 'coffee-script'
UglifyJS = require 'uglify-js'
sourceMap = require 'source-map'

FilesInDirectory = require './glob'

###
Compile multile coffee scriptfile,
concat and uglify,
with sourceMap
###
class CoffeeUglifySinglefile extends events.EventEmitter
  ###
  initialize
  ###
  constructor: (options) ->
    @options = options
    @sources = []
    @files = []
    @_isCompiling = false
    @filesInDirectory = new FilesInDirectory(options.dir)
    @initializeEvents()

  ###
  initialize events
  ###
  initializeEvents: () ->
    @filesInDirectory.on 'finish', @onFileListed.bind(@)

  ###
  build script
  ###
  build: () ->
    throw new Error('is compiling') if @_isCompiling == true
    @_isCompiling = true
    @ast = null
    @sources = []
    @files = []
    @jsCode = null
    @sourceMap = null
    @filesInDirectory.glob()

  ###
  file list fetched
  ###
  onFileListed: () ->
    files = @filesInDirectory.fileList()
    files = files.filter (file) ->
      isCoffee = (path.extname(file) == '.coffee')
      return isCoffee
    @files = files
    @readAllFiles()

  ###
  ###
  readAllFiles: () ->
    @totalFiles = @files.length
    @files.forEach (item) ->
      fs.readFile item, 'UTF-8', (err, data) =>
        if err
          throw err
          return
        @onFileRead(item, data)
    , @


  onFileRead: (file, data) ->
    @totalFiles -= 1
    @compileCoffeeScript(file, data)

    if @totalFiles <= 0
      @uglify()

  ###
  compile coffee script
  ###
  compileCoffeeScript: (file, data) ->
    coffeeOptions =
      bare: true
      inline: true
      sourceMap: true
      sourceFiles: [file]
      generatedFile: file.replace(/\.coffee$/, '.js')

    compiled = CoffeeScript.compile(data, coffeeOptions)

    idx = @files.indexOf(file)
    @sources[idx] = 
      file: file
      compiledCoffee: compiled

  ###
  uglify all files
  ###
  uglifyAllFiles: () ->
    @sources.forEach (source) =>
      file = source.file
      code = source.compiledCoffee.js
      @ast = UglifyJS.parse(code, { filename: file.replace(/\.coffee$/,'.js'), toplevel: @ast })

    # compress
    @ast.figure_out_scope()
    compressorOptions =
      sequences: false
    compressor = UglifyJS.Compressor(compressorOptions)
    @ast = @ast.transform compressor

    # mangle
    @ast.figure_out_scope()
    @ast.compute_char_frequency()
    @ast.mangle_names()


    # sourceMap
    uglifyJsSourceMap = UglifyJS.SourceMap(
      file: @options.sourceMap.file
    )

    generateOptions =
      comments: /@preserve/
      source_map: uglifyJsSourceMap
    # generate
    code = @ast.print_to_string(generateOptions)

    # combine sourcemaps 
    jsMapConsumer = new sourceMap.SourceMapConsumer(JSON.parse(uglifyJsSourceMap))
    map = sourceMap.SourceMapGenerator.fromSourceMap(jsMapConsumer)
    @sources.forEach (source) ->
      sourceConsumer = new sourceMap.SourceMapConsumer(JSON.parse(source.compiledCoffee.v3SourceMap))
      map.applySourceMap(sourceConsumer)

    # save variables
    @sourceMap = map.toString()
    @jsCode = code


  ###
  uglify scripts
  ###
  uglify: () ->
    @uglifyAllFiles()
    @_isCompiling = false
    @emit 'built'

  ###
  return JavaScript src
  ###
  js: () ->
    return @jsCode + "\n" + '//# sourceMappingURL=' + @options.sourceMappingURL

  ###
  return source map
  ###
  map: () ->
    return @sourceMap || ''

module.exports = CoffeeUglifySinglefile
