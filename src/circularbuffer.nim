type
  CircularBuffer*[L: static[int], T] = object
    data*: array[L, T]
    head*, tail*, size*: int

proc initCircularBuffer*[L: static[int], T](): CircularBuffer[L, T] = 
  result.tail = -1

proc `[]`*[L: static[int], T](self: CircularBuffer[L, T], idx: Natural): T {.inline.} =
  if self.size == 0:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. Buffer is probably empty.")
  elif idx >= self.size:
    raise newException(IndexDefect, "Index " & $idx & " out of bound")
  else:
    var head = self.head + idx
    if head >= L:
      head -= L
    result = self.data[head]
  
proc `[]=`*[L: static[int], T](self: var CircularBuffer[L, T], idx: int, item: T) =
  if self.size == 0:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. Buffer is probably empty.")
  elif idx >= self.size:
    raise newException(IndexDefect, "Index " & $idx & " out of bound")
  else:
    var head = self.head + idx
    if head >= L:
      head -= L
    self.data[head] = item

iterator `items`*[L: static[int], T](self: CircularBuffer[L, T]): T =
  if self.size == 0:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. Buffer is probably empty.")
  elif self.head < self.tail:
    for i in self.head .. self.tail:
      yield self.data[i]
  else:
    for i in self.head ..< L:
      yield self.data[i]
    for i in 0 .. self.tail:
      yield self.data[i]

iterator `itemsPairs`*[L: static[int], T](self: CircularBuffer[L, T]): (int, T) =
  var counter = 0
  if self.size == 0:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. Buffer is probably empty.")
  elif self.head < self.tail:
    for i in self.head .. self.tail:
      yield (counter, self.data[i])
      counter.inc()
  else:
    for i in self.head ..< L:
      yield (counter, self.data[i])
      counter.inc()
    for i in 0 .. self.tail:
      yield (counter, self.data[i])
      counter.inc()

iterator itemsAt*[L: static[int], T](self: CircularBuffer[L, T], first, last: Natural): T =
  ## Generates an iterator at a specific slice in the buffer, Kind of like an openarray
  ## Does not error out if `last` - `first` is bigger than current size of buffer, instead it iterates whats available.
  if self.size == 0:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. Buffer is probably empty.")
  elif self.size < first:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. First is bigger than buffer size.")
  elif self.head < self.tail:
    for i in self.head + first.. self.tail - (L - last - 1):
      yield self.data[i]
  else:
    for i in self.head + first ..< L:
      yield self.data[i]
    for i in max(0, (self.head + first - L)) .. self.tail - (L - last - 1):
      yield self.data[i]

iterator itemsHead*[L: static[int], T](self: CircularBuffer[L, T], n: Positive): T =
  ## Generates an iterator at a specific slice in the buffer, Kind of like an openarray
  ## Selects the first n items available
  if self.size == 0:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. Buffer is probably empty.")
  elif self.head < self.tail:
    for i in self.head .. min(self.tail, self.head + n - 1):
      yield self.data[i]
  else:
    for i in self.head ..< min(L, self.head + n):
      yield self.data[i]
    for i in 0 .. min(self.tail, n - (L - self.head + 1)):
      yield self.data[i]

iterator itemsTail*[L: static[int], T](self: CircularBuffer[L, T], n: Positive): T =
  ## Generates an iterator at a specific slice in the buffer, Kind of like an openarray
  ## Selects the last n items available
  if self.size == 0:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. Buffer is probably empty.")
  elif self.head < self.tail:
    for i in max(self.head, self.tail - n + 1) .. self.tail:
      yield self.data[i]
  else:
    for i in max(self.head, L + (self.tail - n + 1)) ..< L:
      yield self.data[i]
    for i in max(0, self.tail - n + 1) .. self.tail:
      yield self.data[i]



func `@`*[L: static[int], T](self: CircularBuffer[L, T]): seq[T] =
  ## Convert the buffer to a sequence
  result = newSeq[T](self.size)
  if self.size > 0: 
    for i, item in self.itemsPairs():
      result[i] = item


proc len*(self: CircularBuffer): int =
  result = self.size


proc adjustHead[L: static[int], T](self: var CircularBuffer[L, T]) = 
  if self.size == L:
    var head = self.tail + 1
    if head >= L:
      head -= L
    self.head = head


proc adjustTail[L: static[int], T](self: var CircularBuffer[L, T], change: int) =
  var tail = self.tail + change
  if tail >= L: tail -= L
  elif tail < 0: tail += L
  self.tail = tail

  
proc add*[L: static[int], T](self: var CircularBuffer[L, T], item: T) =
  self.adjustTail(1)
  self.data[self.tail] = item
  self.size = min(self.size + 1, L)
  self.adjustHead()


proc add*[L: static[int], T](self: var CircularBuffer[L, T], items: openArray[T]) =
  for item in items:
    self.add(item)


proc pop*[L: static[int], T](self: var CircularBuffer[L, T]): T =
  if self.size == 0:
    raise newException(IndexDefect, "Index " & $(-1) & " out of bound. Buffer is probably empty.")
  result = self.data[self.tail]
  self.adjustTail(-1)
  self.size -= 1
  self.adjustHead()

