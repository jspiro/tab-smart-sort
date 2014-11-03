###
  lib/tab-smart-sort.coffee
###

pathUtil = require 'path'

sortTerms = caseSensitive = originalAddItem = null

class TabSmartSort
  
  configDefaults:
    enableByEachPaneInsteadOfGlobally: no
    caseSensitive: no
    ordering: 'dir, ext, base'
  
  activate: ->
    sortTerms = (term.replace(/[^a-zA-Z]/g, '') \
      for term in atom.config.get('tab-smart-sort.ordering').split /[\s,;:-]/)
    caseSensitive = atom.config.get 'tab-smart-sort.caseSensitive'

    atom.commands.add 'atom-workspace', 'tab-smart-sort:toggle': => @toggle()

  toggle: ->
    if not (pane = atom.workspace.getActivePane()) then return
    if pane.addItem isnt addItem then @hookAddItemAndSort pane
    else @unhookAddItem pane
    
  hookAddItemAndSort: (pane) ->
    originalAddItem = pane.addItem
    pane.addItem = addItem
    
    #sort
    
    # set status bar
  
  unhookAddItem: (pane) ->
    if pane.addItem is addItem 
      pane.addItem = originalAddItem
      
    # set status bar
    
  deactivate: ->
    for pane in atom.workspace.getPanes()
      @unhookAddItem pane
    
    # set status bar
  
getSortStr = (item) ->
  if not (path = item.getPath?()) then return '~~~~~~~~~'
  sortStr = ''
  for term in sortTerms
    switch term
      when 'dir'  then sortStr += pathUtil.dirname(path)  + ' '
      when 'base' then sortStr += pathUtil.basename(path) + ' '
      when 'ext'  then sortStr += pathUtil.extname(path)  + ' '
  if caseSensitive then sortStr = str.toLowerCase()
  sortStr

addItem = (newItem) ->
  newSortStr = getSortStr newItem
  lastSortStr = ''
  for item, newIndex in @items
    sortStr = getSortStr item
    if lastSortStr <= newSortStr < sortStr then break
    lastSortStr = sortStr
  originalAddItem.call @, newItem, newIndex
  
module.exports = new TabSmartSort
