fs = require 'fs'
path = require 'path'
events = require 'events'


###
Find Files in directory recursively
emit finish when file searched
###
class FilesInDirectory extends events.EventEmitter
  ###
  constructor
  ###
  constructor: (dir) ->
    @dir = dir

    @_isProcessing = false  # if is processing
    @_processings = 0 # processing files count
    @_fileList = [] # file paths in it

    @initializeEvents()


  ###
  initialize events
  ###
  initializeEvents: () ->
    @on 'globbedDirectory', @parsePaths
    @on 'gotPath', @statFile
    @on 'gotStat', @divideFile


  ###
  add / subtract processing files
  when processings == 0 emit 'finish'
  ###
  processings: (count) ->
    @_processings += count
    if @_processings <= 0
      @_isProcessing = false
      @emit 'finish'


  ###
  glob dir
  ###
  glob: () ->
    throw new Error('is processing') if @_isProcessing
    @_fileList = []
    @_isProcessing = true
    @_processings = 1
    @readDir(@dir)

  ###
  return files 
  ###
  fileList: () ->
    return @_fileList


  ###
  find file in dir
  ###
  readDir: (dir) ->
    fs.readdir dir, (err, files) =>
      if err
        throw new Error(err)
        processings -1
        return
      @emit 'globbedDirectory', dir, files
      # when the type is directory, decrement here
      @processings -1


  ###
  stat each files
  ###
  parsePaths: (dir, files) ->
    @processings files.length
    for file in files
      filePath = path.join dir, file
      @emit 'gotPath', filePath

  ###
  get stats
  ###
  statFile: (file) ->
    fs.stat file, (err, data) =>
      if data
        isDirectory = data.isDirectory()
        @emit 'gotStat', file, isDirectory
        return

      @processings -1

  ###
  divide file or directory
  ###
  divideFile: (file, isDirectory) ->
    if isDirectory
      @readDir file
      return

    @_fileList.push file
    # when the type is file, decrement here
    @processings -1

module.exports = FilesInDirectory
