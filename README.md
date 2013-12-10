lua-radixtree
=============

A radix tree matcher. It implements a lightweight tree search. 

Why do I need that?

If a set of strings is given and you want to return all of the strings that start with "abc", you would need to iterate over all strings and call string.find, string.match or compare the substring.
The radix tree does these things more sophisticated and therefore vastly reduces search time.

You can also use the radix tree to return a subset of elements that can then be evaluated further if the matching expressions provided by the radix tree do not cover the needed matching expressions completely.

example
=============

```Lua
local radix = require'radix'
local radixTree = radix.new()
radixTree.add('foo')
radixTree.add('bar')
local matches = radixTree.get_possible_matches({startsWith = "fo"}, false)
if matches then
  for path,_ in pairs(matches) do
    print(path)
  end
end

```

speed comparison
=============

- added radixtree:        16.518508911133
- lookup radixtree:       0.004925012588501
- added table:    3.9087619781494
- lookup table:   0.50004291534424

Obviously, adding strings to the radix-tree consumes more time (4x) than just pushing them into an array.
A lookup from the radix tree is much faster (100x) than an ordinary string.match.
If you rely on fast string compares the radix-tree is the way to go.

interface
=============

# Add elements to tree
add(string)

# Remove elements from tree
remove(string)

# Find in tree
get_possible_matches(Object, Boolean)
returns array of matches and completeness identifier

The Object can have the following identifiers:
- startsWith = string
- contains = string
- endsWith = string
- equals = string

If only a set of these identifiers is present, the completeness identifier is "all" and the returned elements represent the complete match that e.g. a string.find or string.match would return when iterating over all added strings.
More identifiers can be defined that are not evalueted by the tree but must be evaluated by the calling application. 
The tree than just reduces the search space and the completeness identifier is "partial".
If identifiers are duplicated, only unknown identifiers are present or a case sensitive search shall be performed, the completeness identifier is "impossible" and nil is returned instead of a set of matches
