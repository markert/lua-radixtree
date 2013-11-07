local pcall = pcall
local pairs = pairs
local ipairs = ipairs
local print = print

new = function(config)
  local j = {}
  local radix_tree = {}
  local radix_elements = {}
  local add_to_tree
  
  local lookup_fsm = function (wordpart , state, letter)
    local next_state = state + 1
	if (wordpart:sub(next_state,next_state) ~= letter) then
	  next_state = 0
	end
	if (wordpart:len() == next_state) then
	  return true, next_state
	else
	  return false, next_state
	end
  end
  
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
  leaf_lookup = function( a, part )
    if part:len() < 1 then
      radix_traverse( a )
    else
      local s = part:sub( 1, 1 )
      if type(a[s])=="table" then
        root_lookup( a[s], part:sub(2) )
      end
    end
  
  local clear_tree = function (tree_to_clear)
    tree_to_clear = {}
  end
  
  local reset_elements = function (elements)
    elements = {}
  end
  
  j.add_to_tree = add_to_tree
  j.remove_from_tree = remove_from_tree
  j.radix_traverse = radix_traverse
  j.root_lookup = root_lookup
  j.clear_tree = clear_tree
  j.reset_elements = reset_elements
  j.radix_elements = radix_elements
  j.radix_tree = radix_tree
  
  return j
end

return {
  new = new
}
