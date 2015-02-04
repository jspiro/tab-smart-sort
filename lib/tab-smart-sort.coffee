###
  lib/tab-smart-sort.coffee
###

SubAtom  = require 'sub-atom'
pathUtil = require 'path'

# these have to be in a closure so monkey-patched addItem works from core
sortTerms = caseSensitive = placeSpecialTabsOnRight = originalAddItem = null

getSortStr = (item) ->
  if not (path = item.getPath?()) 
    return (if placeSpecialTabsOnRight then '~~~~~~~~~' else '')
  path = path.replace /\\/g, '/'
  dirname  = pathUtil.dirname  path
  basename = pathUtil.basename path 
  extname  = pathUtil.extname  path
    
  sortStr = ''
  for term in sortTerms
    sortStr += ' ' + switch term
      when 'filetree' then dirname.split(/\/|\\/g).join('/\u0000')
      when 'dir'      then dirname
      when 'base'     then pathUtil.basename path 
      when 'ext'      then pathUtil.extname  path
      else ''
  if not caseSensitive then sortStr = sortStr.toLowerCase()
  console.log 'sortStr', sortStr
  sortStr
  
addItem = (newItem) ->
  newSortStr = getSortStr newItem
  lastSortStr = ''
  for item, newIndex in @items
    sortStr = getSortStr item
    if lastSortStr <= newSortStr < sortStr then break
    lastSortStr = sortStr
  originalAddItem.call @, newItem, newIndex

module.exports =
  
  config:
    caseSensitive:
      type: 'boolean'
      default: no
    ordering:
      type: 'string'
      default: 'filetree, dir, ext, base'
    placeSpecialTabsOnRight:
      type: 'boolean'
      default: no

  activate: ->      
    @subs = new SubAtom
    @subs.add atom.config.observe 'tab-smart-sort.caseSensitive',           (val) => 
      caseSensitive = val
      
    @subs.add atom.config.observe 'tab-smart-sort.ordering',              (order) => 
      order = order.toLowerCase()
      sortTerms = (term.replace(/[^a-zA-Z]/g, '') for term in order.split /[\s,;:-]/)
      
    @subs.add atom.config.observe 'tab-smart-sort.placeSpecialTabsOnRight', (val) => 
      placeSpecialTabsOnRight = val
      
    @subs.add atom.config.observe 'tab-smart-sort.activationOrder',         (val) => 
      @activationOrder = val
    
    @panePrototype = atom.workspace.getActivePane().__proto__
    originalAddItem = @panePrototype.addItem
    @panePrototype.addItem = addItem
      
  deactivate: ->
    @subs.dispose()
    @panePrototype.addItem = originalAddItem
  
  
