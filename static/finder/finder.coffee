# adapted from https://github.com/marshill/jquery-page-search/blob/master/jquery.search.js

jQuery = window.jQuery || throw "jQuery required."

settings = undefined # scope these as shared
searchables = undefined
searchfield = undefined

jQuery.fn.search = (target, options) ->
  @each ->
    jQuery.search jQuery(this), jQuery(target), options


# invocation eg: jQuery.searchText($(), 'lorem', $('body'), null)
# WebBuddy - forked and tweaked version that removes dep to an input#search element.
jQuery.searchText = (callee, string, target, options) ->
  settings = {}
  jQuery.extend settings, options  if options
  searchables = target
  searchables.removeHighlight()
  term = string

  if term is ""
    # searchables.slideDown()
    return

  words = term.split(" ")
  searchables.each ->
    i = 0

    # while word = words[i]  # match each word
    word = term
    # continue if word is ""

    pass = true

    regexp = new RegExp(string, 'i')
    unless jQuery(this).html().match regexp
      pass = false
      # break
    else
      jQuery(this).highlight word

    i++

#     if(pass) jQuery(this).slideDown()
#      else jQuery(this).slideUp()

# WebBuddy - dynamically define the highlight style.
style = document.createElement("style")
style.innerHTML = ".webbuddy-highlight { background-color: yellow; }"
document.head.appendChild style

# FIXME name clashes, cases of style definition

#/////////// Highliting //////////////////////////////////////////////////////////////////////////////////////
# http://johannburkard.de/blog/programming/javascript/highlight-javascript-text-higlighting-jquery-plugin.html
jQuery.fn.highlight = (pat) ->
  innerHighlight = (node, pat) ->
    skip = 0
    if node.nodeType is 3
      pos = node.data.toUpperCase().indexOf(pat)
      if pos >= 0
        spannode = document.createElement("span")
        spannode.className = "webbuddy-highlight"
        middlebit = node.splitText(pos)
        endbit = middlebit.splitText(pat.length)
        middleclone = middlebit.cloneNode(true)
        spannode.appendChild middleclone
        middlebit.parentNode.replaceChild spannode, middlebit
        skip = 1
    else if node.nodeType is 1 and node.childNodes and not /(script|style)/i.test(node.tagName)
      i = 0

      while i < node.childNodes.length
        i += innerHighlight(node.childNodes[i], pat)
        ++i
    skip
  @each ->
    innerHighlight this, pat.toUpperCase()


jQuery.fn.removeHighlight = ->
  $("span.webbuddy-highlight").each(->
    parentNode = @parentNode
    parentNode.replaceChild @firstChild, this
    parentNode.normalize()
  ).end()

#/////////// End Highliting ///////////////////////////////////////////////////////////////////////////////////
