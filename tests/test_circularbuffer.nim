import sequtils
import unittest
import ../src/circularbuffer


suite "CircularBuffer":
  
  test "init":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()

  test "add":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..10:
      check len(circularbuffer) == min(n, i)
      circularBuffer.add(i)

  test "pop":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..10:
      circularBuffer.add(i)
    for i in 0..<2:
      discard circularBuffer.pop()
    check len(circularbuffer) == 3

  test "toSeq empty":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    check @circularbuffer == newSeq[int](0)

  test "toSeq pre loop":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..3:
      circularBuffer.add(i)
    check @circularbuffer == @[0, 1, 2, 3]

  test "toSeq post loop":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..50:
      circularBuffer.add(i)
    check @circularbuffer == @[46, 47, 48, 49, 50]

  test "toSeq complex":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..12:
      circularBuffer.add(i)
    for i in 0..4:
      discard circularBuffer.pop()
    for i in 0..12:
      circularBuffer.add(i)
    for i in 0..2:
      discard circularBuffer.pop()
    check @circularbuffer == @[8, 9]

  test "itemsAt set 0":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..4: circularBuffer.add(i)
    var result: seq[int]

    # Variant 1 
    result = newSeq[int]()
    for i in circularBuffer.itemsAt(0, 2): result.add(i)
    check result == @[0, 1, 2]

    # Variant 2 
    result = newSeq[int]()
    for i in circularBuffer.itemsAt(2, 4): result.add(i)
    check result == @[2, 3, 4]

    # Variant 3 
    result = newSeq[int]()
    for i in circularBuffer.itemsAt(4, 4): result.add(i)
    check result == @[4]


  test "itemsAt set 1":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..12: circularBuffer.add(i)
    var result: seq[int]

    # Variant 1 
    result = newSeq[int]()
    for i in circularBuffer.itemsAt(0, 2): result.add(i)
    check result == @[8, 9, 10]

    # Variant 2 
    result = newSeq[int]()
    for i in circularBuffer.itemsAt(2, 4): result.add(i)
    check result == @[10, 11, 12]

    # Variant 3 
    result = newSeq[int]()
    for i in circularBuffer.itemsAt(4, 4): result.add(i)
    check result == @[12]


  test "itemsHead set 0":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..4: circularBuffer.add(i)
    var result: seq[int]

    for i in 1..5:
      result = newSeq[int]()
      for j in circularBuffer.itemsHead(i):
        result.add(j)
      check result == @[0, 1, 2, 3, 4][0 ..< i]


  test "itemsHead set 1":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..12: circularBuffer.add(i)
    var result: seq[int]

    for i in 1..5:
      result = newSeq[int]()
      for j in circularBuffer.itemsHead(i):
        result.add(j)
      check result == @[8, 9, 10, 11, 12][0 ..< i]

  test "itemsTail set 0":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..4: circularBuffer.add(i)
    var result: seq[int]

    for i in 1..5:
      result = newSeq[int]()
      for j in circularBuffer.itemsTail(i):
        result.add(j)
      check result == @[0, 1, 2, 3, 4][^i .. n - 1]

  test "itemsHead set 1":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..12: circularBuffer.add(i)
    var result: seq[int]

    for i in 1..5:
      result = newSeq[int]()
      for j in circularBuffer.itemsTail(i):
        result.add(j)
      check result == @[8, 9, 10, 11, 12][^i .. n - 1]


  test "[] set 0":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..4: circularBuffer.add(i)

    for i in 0..4: check circularBuffer[i] == @[0, 1, 2, 3, 4][i]


  test "[] set 1":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..12: circularBuffer.add(i)

    for i in 0..4: check circularBuffer[i] == @[8, 9, 10, 11, 12][i]


  test "[]= set 0":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..4: circularBuffer.add(i)

    for i in 0..2: circularBuffer[i] = 10
    check @circularBuffer == @[10, 10, 10, 3, 4]

    for i in 0..4: circularBuffer[i] = 100
    check @circularBuffer == @[100, 100, 100, 100, 100]

  test "[]= set 1":
    const n = 5
    var circularBuffer = initCircularBuffer[n, int]()
    for i in 0..12: circularBuffer.add(i)

    for i in 0..2: circularBuffer[i] = 10
    check @circularBuffer == @[10, 10, 10, 11, 12]

    for i in 0..4: circularBuffer[i] = 100
    check @circularBuffer == @[100, 100, 100, 100, 100]