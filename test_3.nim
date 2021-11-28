import times
import sequtils
import algorithm, strutils
 
proc median(xs: seq[float]): float =
  var ys = xs
  sort(ys, system.cmp[float])
  0.5 * (ys[ys.high div 2] + ys[ys.len div 2]) 
 

template benchmark(n: int, body: untyped) =
  var t0, t1: Time
  var m0, m1: int
  var td = newSeq[float](n)
  var md = newSeq[float](n)
  var tmed: Duration
  var mmed: int
  for i in 0..<n:
    m0 = getOccupiedMem()
    t0 = getTime()
    body
    t1 = getTime()
    m1 = getOccupiedMem()
    td[i] = (t1 - t0).inNanoseconds().float
    md[i] = (m1 - m0).float
  tmed = median(td).int.initDuration()
  mmed = md[0].int
  echo "Benchmark rounds: ", n
  echo "Run Time: ", $tmed.inNanoseconds().int.nanoseconds() & ", " & $tmed.inMicroseconds().int.microseconds() & ", " & $tmed.inMilliseconds().int.milliseconds() & ", " & $tmed.inSeconds().int.seconds()
  echo "Memory: ", $mmed & " bytes, " & $int(mmed / 1024) & " kilobytes, " & $int(mmed / 1024 / 1024) & " megabytes, " & $int(mmed / 1024 / 1024 / 1024) & " gigabytes"


type
  RingBuffer*[L: static[int], T] = object
    buffer*: array[L, T]
    head*, tail*, size*: int

proc initRingBuffer[L: static[int], T](): RingBuffer[L, T] = 
  result.tail = -1


proc `[]`*[L, T](self: RingBuffer[L, T], idx: int): T {.inline} =
  result = self.buffer[(idx + self.head) mod L]

  
proc `[]=`*[L, T](self: var RingBuffer[L, T], idx: int, item: T) {.raises: [IndexError].} =
  if idx == self.size: inc(self.size)
  elif idx > self.size: raise newException(IndexError, "Index " & $idx & " out of bound")
  self.buffer[(idx + self.head) mod L] = item

iterator `items`*[L, T](self: RingBuffer[L, T]): T =
  for i in 0..self.size - 1:
    yield self[i]

iterator `items_pairs`*[L, T](self: RingBuffer[L, T]): (int, T) =
  for i in 0..self.size - 1:
    yield (i, self[i])


iterator fast_items*[L, T](self: RingBuffer[L, T]): T =
  if self.tail == -1:
    raise newException(IndexError, "Index " & $(-1) & " out of bound")
  elif self.head == self.tail:
    yield self.buffer[self.head]
  elif self.head < self.tail:
    for i in self.head .. self.tail:
      yield self.buffer[i]
  else:
    for i in self.head .. self.size:
      yield self.buffer[i]
    for i in 0 .. self.tail:
      yield self.buffer[i]


iterator fast_items_pairs*[L, T](self: RingBuffer[L, T]): (int, T) =
  if self.tail == -1:
    raise newException(IndexError, "Index " & $(-1) & " out of bound")
  elif self.head == self.tail:
    yield (0, self.buffer[self.head])
  elif self.head < self.tail:
    for i in self.head .. self.tail:
      yield (i, self.buffer[i])
  else:
    for i in self.head .. self.size:
      yield (i, self.buffer[i])
    for i in 0 .. self.tail:
      yield (i, self.buffer[i])

proc len*(self: RingBuffer): int =
  result = self.size


proc adjustHead[L, T](self: var RingBuffer[L, T]) = 
  self.head = (L + self.tail + self.size + 1) mod L


proc adjustTail[L, T](self: var RingBuffer[L, T], change: int) =
  self.tail = (self.tail + change) mod L

  
proc add*[L, T](self: var RingBuffer[L, T], item: T) =
  self.adjustTail(1)
  self.buffer[self.tail] = item
  self.size = min(self.size + 1, L)
  self.adjustHead()


proc add*[L, T](self: var RingBuffer[L, T], items: openArray[T]) =
  for item in items:
    self.add(item)


proc pop*[L, T](self: var RingBuffer[L, T], item: T): T =
  result = self.data[self.tail]
  self.adjustTail(-1)
  self.size -= 1
  self.adjustHead()


func `@`*[L, T](self: RingBuffer[L, T]): seq[T] =
  ## Convert the buffer to a sequence
  result = newSeq[T](self.size)
  for i, item in self.pairs():
    result[i] = item

const n = 20000
var ringBuffer = initRingBuffer[n, int]()
var c1, c2, c3: seq[int]


for i in 0..<n + 20000:
  ringBuffer.add(i)

c1 = newSeq[int](n)
benchmark 1000:
  for i, v in ringBuffer.buffer:
    c1[i] = v

c2 = newSeq[int](n)
benchmark 1000:
  for i, v in ringBuffer.items_pairs():
    c2[i] = v

c3 = newSeq[int](n)
benchmark 1000:
  for i, v in ringBuffer.fast_items_pairs():
    c3[i] = v


assert c1 == c2
assert c1 == c3

