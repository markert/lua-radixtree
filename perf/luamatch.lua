local this_dir = arg[0]:match('(.+/)[^/]+%.lua') or './'
package.path = this_dir..'../src/'..package.path

local radix = require'radix'
local socket = require("socket")
local tinsert = table.insert

local count = 300000
local long_path_prefix = string.rep('foobar',1)

local radixTree = radix.new()


local t_start = socket.gettime()

for i=1,count do
  radixTree.add(long_path_prefix..i)
end
local t_added = socket.gettime()
print("added radixtree: ", t_added-t_start)
local matches = radixTree.get_possible_matches({startsWith = "2012", contains = "fo", endsWith = "ar"}, false) -- returns 10 matches
local t_end = socket.gettime()
print("lookup radixtree: ", t_end - t_added)

local t_start = socket.gettime()
local elements = {}
for i=1,count do
  tinsert(elements, i..long_path_prefix)
end
local t_added = socket.gettime()
print("added table: ", t_added-t_start)
local element_matches = {}
for _,path in pairs(elements) do
  if (path:match("^2012.*fo.*ar$")) then
    tinsert(element_matches, path)
  end
end
local t_end = socket.gettime()
print("lookup table: ", t_end - t_added)
