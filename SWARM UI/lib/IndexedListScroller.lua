local mod = math.fmod
local max = math.max

function loopScrollIndex(indx,limit)
	return mod(indx-1+limit,limit)+1
end

local IndexedListScroller = {}


	IndexedListScroller.target_index=1
	IndexedListScroller.index_scroll_direction=1
	IndexedListScroller.list_size = 1
	
	function IndexedListScroller:updateListSize(size)
		self.list_size = size
	end
	function IndexedListScroller:getCurrentIndex()
		return self.target_index
	end
	function IndexedListScroller:scrollUp()
		self.index_scroll_direction = 1
		self.target_index = loopScrollIndex(self.target_index+self.index_scroll_direction,self.list_size)
	end
	function IndexedListScroller:scrollDown()
		self.index_scroll_direction = -1
		self.target_index = loopScrollIndex(self.target_index+self.index_scroll_direction,self.list_size)
	end
	function IndexedListScroller:skip()
		self.target_index = loopScrollIndex(self.target_index+self.index_scroll_direction,self.list_size)
	end
	function IndexedListScroller:getCurrentItem(list)
		return list[self.target_index]
	end

function IndexedListScroller:init(...) end

return IndexedListScroller

