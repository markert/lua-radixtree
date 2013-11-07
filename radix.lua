local pairs = pairs

new = function(config)
  local j = {}
  local radix_tree = {}
  local radix_elements = {}
  
  local lookup_fsm = function (wordpart, next_state, next_letter)
    if (wordpart:sub(next_state,next_state) ~= next_letter) then
      next_state = 0
    end
    if (wordpart:len() == next_state) then
      return true, next_state
    else
      return false, next_state
    end
  end
  
  local add_to_tree
  add_to_tree = function( a, fullword, part )
    part = part or fullword;
    if part:len() < 1 then
      a[fullword]=true;
    else
      local s = part:sub( 1, 1 )
      if type(a[s])~="table" then
        a[s] = {};
      end
      add_to_tree( a[s], fullword, part:sub(2) )
    end
  end
  
  local remove_from_tree
  remove_from_tree = function( a, fullword, part )
    part = part or fullword;
    if part:len() < 1 then
      a[fullword]=nil;
    else
      local s = part:sub( 1, 1 )
      if type(a[s])~="table" then
        a[s] = {};
      end
      remove_from_tree( a[s], fullword, part:sub(2) )
    end
  end
  
  local radix_traverse
  radix_traverse = function( a )
    for k, v in pairs(a) do
      if type(v)=="boolean" then
        radix_elements[k] = true
      elseif type(v)=="table" then
        radix_traverse( v );
      end
    end
  end
  
  local root_lookup
  root_lookup = function( a, part )
    if part:len() < 1 then
      radix_traverse( a )
    else
      local s = part:sub( 1, 1 )
      if type(a[s])=="table" then
        root_lookup( a[s], part:sub(2) )
      end
    end
  end
  
  local leaf_lookup
  leaf_lookup = function( a, word, state )
    local next_state = state+1
    local hit, next_state = lookup_fsm(word, next_state, word:sub(next_state,next_state))
    if (hit == true) then
      radix_traverse(a)
    else
      for k, v in pairs(a) do
        if type(v)=="table" then
          leaf_lookup( v, word, next_state);
        end
      end
    end
  end
  
  local clear_tree = function (tree_to_clear)
    tree_to_clear = {}
  end
  
  local reset_elements = function (elements)
    elements = {}
  end
  
  j.add = add_to_tree
  j.add_main = function (word)
    add_to_tree(radix_tree, word)
  end
  j.remove = remove_from_tree
  j.remove_main = function (word)
    remove_from_tree(radix_tree, word)
  end
  j.traverse = radix_traverse
  j.traverse_main = function ()
    radix_traverse(radix_tree)
  end
  j.root_lookup = root_lookup
  j.root_lookup_main = function (word)
    root_lookup(radix_tree, word)
  end
  j.leaf_lookup = leaf_lookup
  j.leaf_lookup_main = function (word)
    leaf_lookup(radix_tree, word, 0)
  end
  j.clear = clear_tree
  j.found_elements = radix_elements
  j.tree = radix_tree
  
  return j
end

return {
  new = new
}
