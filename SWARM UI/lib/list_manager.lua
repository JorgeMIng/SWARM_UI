local mod = math.fmod
local max = math.max

function loopScrollIndex(indx,limit)
	return mod(indx-1+limit,limit)+1
end

function IndexedListScroller()
	return{
	target_index=1,
	index_scroll_direction=1,
	list_size = 1,
	updateListSize=function(self,size)
		self.list_size = size
	end,
	setCurrentIndex=function(self,new_index)
		self.target_index = new_index
	end,
	getCurrentIndex=function(self)
		return self.target_index
	end,
	scrollUp=function(self)
		self.index_scroll_direction = 1
		self.target_index = loopScrollIndex(self.target_index+self.index_scroll_direction,self.list_size)
	end,
	scrollDown=function(self)
		self.index_scroll_direction = -1
		self.target_index = loopScrollIndex(self.target_index+self.index_scroll_direction,self.list_size)
	end,
	skip=function(self)
		self.target_index = loopScrollIndex(self.target_index+self.index_scroll_direction,self.list_size)
	end,
	getCurrentItem=function(self,list)
		return list[self.target_index]
	end
	}
end