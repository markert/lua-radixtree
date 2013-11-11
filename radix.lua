local pairs = pairs
local print = print

new = function(config)
  local j = {}
  local radix_tree = {}
  local radix_elements = {}
  local temp_instance = nil
  local lookup_fsm
  local root_lookup
  local leaf_lookup
  local radix_traverse
  local root_leaf_lookup
  local root_anypos_lookup
  
  if config and config.ci then
    lookup_fsm = function (wordpart, next_state, next_letter, ci)
      if ci then
        if (wordpart:sub(next_state,next_state):lower() ~= next_letter:lower()) then
          return false, 0
	    end
      else
        if (wordpart:sub(next_state,next_state) ~= next_letter) then
          return false, 0
	    end
      end
      if (wordpart:len() == next_state) then
        return true, next_state
      else
        return false, next_state
      end
    end

    root_lookup = function( tree_instance, part, traverse, ci)
      if part:len() < 1 then
        if (traverse) then
          radix_traverse( tree_instance )
        else
          temp_instance = tree_instance
        end
      else
        local s = part:sub( 1, 1 )
        if type(tree_instance[s])=="table" then
          root_lookup( tree_instance[s], part:sub(2), traverse ,ci )
        elseif type(tree_instance[s:upper()])=="table" and ci then
          root_lookup( tree_instance[s:upper()], part:sub(2), traverse, ci)
        end
      end
    end
  
    leaf_lookup = function( tree_instance, word, state, only_end, ci )
      local next_state = state+1
      for k, v in pairs(tree_instance) do
        if type(v)=="table" then
          local hit, next_state = lookup_fsm(word, next_state, k, ci)
          if (hit == true) then
            if only_end then
              if type(v[next(v)])=="boolean" then
                radix_elements[next(v)] = true
              end
            else
              radix_traverse( v )
            end
          else
            leaf_lookup( v, word, next_state, only_end, ci);
          end
        end
      end
    end
  
  else
  
    lookup_fsm = function (wordpart, next_state, next_letter)
      if (wordpart:sub(next_state,next_state) ~= next_letter) then
        return false, 0
      end
      if (wordpart:len() == next_state) then
        return true, next_state
      else
        return false, next_state
      end
    end

    root_lookup = function( tree_instance, part, traverse)
      if part:len() < 1 then
        if (traverse) then
          radix_traverse( tree_instance )
        else
          temp_instance = tree_instance
        end
      else
        local s = part:sub( 1, 1 )
        if type(tree_instance[s])=="table" then
          root_lookup( tree_instance[s], part:sub(2), traverse)
        end
      end
    end
  
    leaf_lookup = function( tree_instance, word, state, only_end)
      local next_state = state+1
      for k, v in pairs(tree_instance) do
        if type(v)=="table" then
          local hit, next_state = lookup_fsm(word, next_state, k)
          if (hit == true) then
            if only_end then
              if type(v[next(v)])=="boolean" then
                radix_elements[next(v)] = true
              end
            else
              radix_traverse( v )
            end
          else
            leaf_lookup( v, word, next_state, only_end);
          end
        end
      end
    end
  end

  local add_to_tree
  add_to_tree = function( tree_instance, fullword, part )
    part = part or fullword;
    if part:len() < 1 then
      tree_instance[fullword]=true;
    else
      local s = part:sub( 1, 1 )
      if type(tree_instance[s])~="table" then
        tree_instance[s] = {};
      end
      add_to_tree( tree_instance[s], fullword, part:sub(2) )
    end
  end
  
  local remove_from_tree
  remove_from_tree = function( tree_instance, fullword, part )
    part = part or fullword;
    if part:len() < 1 then
      tree_instance[fullword]=nil;
    else
      local s = part:sub( 1, 1 )
      if type(tree_instance[s])~="table" then
        return
      end
      remove_from_tree( tree_instance[s], fullword, part:sub(2) )
    end
  end
  
  
  radix_traverse = function( tree_instance )
    for k, v in pairs(tree_instance) do
      if type(v)=="boolean" then
        radix_elements[k] = true
      elseif type(v)=="table" then
        radix_traverse( v );
      end
    end
  end
  
  root_leaf_lookup = function(tree_instance, wordstart, wordend, ci)
    temp_instance = {}
    root_lookup(tree_instance, wordstart, false, ci)
    leaf_lookup(temp_instance, wordend, 0, true, ci)
  end
  
  root_anypos_lookup = function(tree_instance, wordstart, wordend, ci)
    root_lookup(tree_instance, wordstart, false, ci)
    leaf_lookup(temp_instance, wordend, 0, false, ci)
  end
  
  local match_get_parts
  match_get_parts = function (match_string)  
    local start_id = false
    local end_id = false
    local left_string = match_string
    local right_string = false
    if (match_string:sub(1,1) == '^') then
      start_id = true
      left_string = left_string:sub(2,left_string:len())
    end
    if (left_string:sub(left_string:len(),left_string:len()) == '$') then
      end_id = true
      left_string = left_string:sub(1,left_string:len()-1)
    end
    local wildcard = left_string:find('%.')
    if (wildcard ~=  nil) then
      right_string = left_string:sub(wildcard+1, left_string:len())
      left_string = left_string:sub(1,wildcard-1)
    end
    return left_string, right_string, start_id, end_id
  end
  
  local match_tree
  match_tree = function (tree_instance, left_string, right_string, start_id, end_id, ci)
    if(start_id == true) then
      if (end_id == true) then
        if (type(right_string) ~= "boolean") then
          root_leaf_lookup(tree_instance, left_string, right_string, ci) -- '^abc.cda$'
        else
          temp_instance = {}
          root_lookup(tree_instance, left_string, false, ci) -- '^abccda$'
          if type(temp_instance[next(temp_instance)])=="boolean" then
            radix_elements[next(temp_instance)] = true
          end
        end
      else
        if (type(right_string) ~= "boolean") then
          root_anypos_lookup(tree_instance, left_string, right_string, ci) -- '^abc.cda'
        else
          root_lookup(tree_instance, left_string, true, ci) -- '^abc'
        end
      end
    else
      if (end_id == true) then
        if (type(right_string) ~= "boolean") then
          -- TODO: 'abc.cda$'
        else
          leaf_lookup(tree_instance, left_string, 0, true, ci) -- 'abc$'
        end
      else
        if (type(right_string) ~= "boolean") then
          --TODO: 'abc.cda'
        else
          leaf_lookup(tree_instance, left_string, 0, false, ci) -- 'abc'
        end
      end
    end
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
  j.root_lookup_main = function (word, ci)
    root_lookup(radix_tree, word, true, ci)
  end
  j.root_leaf_lookup = root_leaf_lookup
  j.root_leaf_lookup_main = function (wordstart, wordend, ci)
    root_leaf_lookup(radix_tree, wordstart, wordend, ci)
  end
  j.root_anypos_lookup = root_leaf_lookup
  j.root_anypos_lookup_main = function (wordstart, wordend, ci)
    root_anypos_lookup(radix_tree, wordstart, wordend, ci)
  end
  j.leaf_lookup = leaf_lookup
  j.leaf_lookup_main = function (word, ci)
    leaf_lookup(radix_tree, word, 0, true, ci)
  end
  j.anypos_lookup_main = function (word, ci)
    leaf_lookup(radix_tree, word, 0, false, ci)
  end
  j.reset_elements = function ()
    for k,v in pairs(radix_elements) do radix_elements[k]=nil end
  end
  j.reset_tree = function ()
    for k,v in pairs(radix_tree) do radix_tree[k]=nil end
  end
  j.match_tree = match_tree
  j.match_tree_main = function (left_string, right_string, start_id, end_id, ci)
    match_tree(radix_tree, left_string, right_string, start_id, end_id, ci)
  end
  j.match_get_parts = match_get_parts
  j.found_elements = radix_elements
  j.tree = radix_tree
  
  return j
end

return {
  new = new
}
