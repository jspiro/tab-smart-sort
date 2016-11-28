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
    @disp.push atom.commands.add 'atom-workspace',
      'tab-smart-sort:sort-existing-tabs': () -> sortAllItems()

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

addItem = (newItem, options) ->
  if newItem in @items then return
  newSortStr = getSortStr newItem
  lastSortStr = ''
  for item, newIndex in @items
    sortStr = getSortStr item
    if lastSortStr <= newSortStr < sortStr then break
    lastSortStr = sortStr
  options.index = newIndex
  originalAddItem.call this, newItem, options

sortString = (x, y) ->
  if x == y
    0
  else if x < y
    -1
  else
    1

# TODO this can be made faster
sortAllItems = ->
  pane = atom.workspace.getActivePane()

  # This stores both the original item and the sort string because:
  #
  #   1) pane.moveItem requires an item, not a string
  #
  #   2) If two items have the same sort string, we need to distinguish
  #      between them
  #
  #   3) It's faster to call getSortStr once per item, rather than multiple
  #      times inside the sort function
  #
  items = pane.getItems().map (item) ->
    item: item
    path: getSortStr item

  # This must use slice because sort modifies the original array
  sorted = items.slice().sort (x, y) -> sortString x.path, y.path

  index = 0
  length = items.length

  while index < length
    item = items[index]
    other = sorted[index]

    if item == other
      # We only increment the index when the two items match
      index = index + 1

    else
      # Because this algorithm moves from left-to-right, all the previous
      # items are already sorted, so the newIndex must be to the right
      # TODO verify that this is never -1
      newIndex = sorted.indexOf item, index + 1

      # This must match the algorithm for pane.moveItem
      items.splice index, 1
      items.splice newIndex, 0, item

      pane.moveItem item.item, newIndex

  undefined

module.exports = new TabSmartSort
