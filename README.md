![Linux Build Status (Github Actions)](https://github.com/ayman-albaz/circularbuffer/actions/workflows/install_and_test.yml/badge.svg) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# circularbuffer

This library contains a high-performance circular buffer / ring buffer / cyclic buffer implementation.

## Highlights
This library from similar circular buffer libraries due to the following features:
1. Zero-allocation ordered-read operations
2. Modulo-free implementation for faster operations
3. Useful misc operations like `itemsHead` for a zero-allocation head slice. 
4. Uses `array` instead of `seq` for the underlying buffer

As the buffer grows, the last element added is removed, making it similar to python [deque](https://docs.python.org/3/library/collections.html#collections.deque). To add a new element, please use `add`. To remove the newest added element, please use `pop`.

Please note that circularbuffer does not provide a thread-safe implementation. Instead the focus is on single-threaded performance for embedded systems and low latency applications. If you are looking for a thread-safe queue implementation, take a look at [lockfreequeues](https://github.com/elijahr/lockfreequeues).


## Supported Functions

Creating a circularbuffer
```Nim
import circularbuffer

var circularBuffer = initCircularBuffer[5, int]()  
```

Adding and popping
```Nim
import circularbuffer

var circularBuffer = initCircularBuffer[5, int]()
for i in 0..12:
  circularBuffer.add(i)
for i in 0..4:
  discard circularBuffer.pop()
for i in 0..12:
  circularBuffer.add(i)
for i in 0..2:
  discard circularBuffer.pop()
assert @circularBuffer == @[8, 9]
assert len(circularBuffer) == 2
```

Zero-allocation iterators for reading
```Nim
import circularbuffer

var circularBuffer = initCircularBuffer[5, int]()
for i in 0..12:
  circularBuffer.add(i)

# items
for i in circularBuffer.items():
  echo i  # 8, 9, 10, 11, 12

# itemsPairs
for i in circularBuffer.itemsPairs():
  echo i  # (0, 8), (1, 9), (2, 10, (3, 11), (4, 12)

# itemsAt (This is just slicing)
for i in circularBuffer.itemsAt(1, 3):
  echo i  # 9, 10, 11

# itemsHead
for i in circularBuffer.itemsHead(2):
  echo i  # 8, 9

# itemsTail
for i in circularBuffer.itemsTail(2):
  echo i  # 11, 12
```

Allocation functions for reading
```Nim
import circularbuffer

var circularBuffer = initCircularBuffer[5, int]()
for i in 0..12:
  circularBuffer.add(i)

# Using `@`
assert @circularBuffer == @[8, 9, 10, 11, 12]
```

## Performance
Performance was the number one priority in mind when writing this library. Allocation-free and fast reads were the main focus functionality-wise. Simple if statements are used instead of expensive modulo operations. If you have any improvements or would like to write a benchmark, feel free to submit a PR.

## Contact
I can be reached at aymanalbaz98@gmail.com