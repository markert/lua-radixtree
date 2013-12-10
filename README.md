lua-radixtree
=============

A radix tree matcher. It implements a lightweight tree search. 

example
=============

```Lua
local radix = require'radix'
local radixtree = radix.new()
radixTree.add('foo')
radixTree.add('bar')
local matches = radixTree.get_possible_matches({startsWith = "fo"}, false)
if matches then
  for path,_ in pairs(matches) do
    print(path)
  end
end

```

interface
=============

# Add elements to tree
add(<string>)

# Remove elements from tree
remove(<string>)

# Find in tree
get_possible_matches(<Object>, <Boolean>)
returns array of matches and completeness identifier

The Object can have the following identifiers:
startsWith = <string>
contains = <string>
endsWith = <string>

If only a set of these identifiers is present, the completeness identifier is "all" and the returned elements represent the complete match that e.g. a string.find or string.match would return when iterating over all added strings.
More identifiers can be defined that are not evalueted by the tree but must be evaluated by the calling application. 
The tree than just reduces the search space and the completeness identifier is "partial".
If identifiers are duplicated, only unknown identifiers are present or a case sensitive search shall be performed, the completeness identifier is "impossible" and nil is returned instead of a set of matches
