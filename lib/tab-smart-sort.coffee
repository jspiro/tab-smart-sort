###
  lib/tab-smart-sort.coffee
###

pathUtil = require 'path'

sortTerms = caseSensitive = placeSpecialTabsOnRight = null
originalAddItem = panePrototype = null

class TabSmartSort
  
  config:
    caseSensitive:
      type: 'boolean'
      default: no
    ordering:
      type: 'string'
      default: 'dir, ext, base'
    placeSpecialTabsOnRight:
      type: 'boolean'
      default: no
  
  activate: ->
    setOrdering = (order) ->
      sortTerms = (term.replace(/[^a-zA-Z]/g, '') for term in order.split /[\s,;:-]/)
      
    caseSensitive           = atom.config.get 'tab-smart-sort.caseSensitive'
    setOrdering               atom.config.get 'tab-smart-sort.ordering' 
    placeSpecialTabsOnRight = atom.config.get 'tab-smart-sort.placeSpecialTabsOnRight'
    
    @disp = []
    @disp.push atom.config.observe 'tab-smart-sort.caseSensitive', 
      (val) -> caseSensitive = val
    @disp.push atom.config.observe 'tab-smart-sort.ordering', 
      (val) -> setOrdering val
    @disp.push atom.config.observe 'tab-smart-sort.placeSpecialTabsOnRight', 
      (val) -> placeSpecialTabsOnRight = val
    
    panePrototype = atom.workspace.getActivePane().__proto__
    originalAddItem = panePrototype.addItem
    panePrototype.addItem = addItem

  deactivate: ->
    for disp in @disp then disp.dispose()
    panePrototype.addItem = originalAddItem
  
getSortStr = (item) ->
  if not (path = item.getPath?()) 
    return (if placeSpecialTabsOnRight then '~~~~~~~~~' else '')
  sortStr = ''
  for term in sortTerms
    switch term
      when 'dir'  then sortStr += pathUtil.dirname(path)  + ' '
      when 'base' then sortStr += pathUtil.basename(path) + ' '
      when 'ext'  then sortStr += pathUtil.extname(path)  + ' '
  if not caseSensitive then sortStr = sortStr.toLowerCase()
  sortStr

addItem = (newItem) ->
  if newItem in @items then return
  newSortStr = getSortStr newItem
  lastSortStr = ''
  for item, newIndex in @items
    sortStr = getSortStr item
    if lastSortStr <= newSortStr < sortStr then break
    lastSortStr = sortStr
  originalAddItem.call @, newItem, newIndex
  
module.exports = new TabSmartSort
