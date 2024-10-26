### 1. **String**

- **用途**: 存储字符串、整数或浮点数。
- **底层实现**: SDS (Simple Dynamic String)。

#### SDS (Simple Dynamic String)

- **多种编码格式**
  - **EMBSTR 编码**: 用于存储较短的字符串，减少内存分配和释放的开销。
  - **RAW 编码**: 用于存储较长的字符串，提供灵活性和高效操作。

- **结构**:
  - `len`: 字符串的当前长度。
  - `free`: 未使用的字节数。
  - `buf[]`: 字符数组，存储实际的字符串内容。
- **优点**:
  - **动态扩展**: 可以根据需要动态扩展字符串长度。
  - **二进制安全**: 可以存储任意二进制数据。
  - **高效操作**: 提供了高效的追加、截取等操作。

### 2. **List**

- **用途**: 存储有序的字符串列表。
- **底层实现**: 双向链表或压缩列表 (ziplist)。

#### 双向链表

- **结构**:
  - `head`: 指向链表头部的指针。
  - `tail`: 指向链表尾部的指针。
  - `len`: 链表的长度。
  - `dup`: 复制函数。
  - `free`: 释放函数。
  - `match`: 匹配函数。
- **优点**:
  - **高效插入和删除**: 在链表头部和尾部插入和删除元素的时间复杂度为 O(1)。
  - **灵活性**: 可以动态扩展和收缩。

#### 压缩列表 (ziplist)

- **结构**:
  - `zlbytes`: 压缩列表的总字节数。
  - `zltail`: 压缩列表尾部的偏移量。
  - `zllen`: 压缩列表的元素个数。
  - `entryX`: 压缩列表的元素。
  - `zlend`: 压缩列表的结束标志。
- **优点**:
  - **节省内存**: 通过压缩数据结构来节省内存。
  - **高效遍历**: 支持高效的遍历操作。

### 3. **Set**

- **用途**: 存储无序的字符串集合，不允许重复元素。
- **底层实现**: 哈希表或整数集合 (intset)。

#### 哈希表

- **结构**:
  - `dict`: 哈希表结构。
  - `ht[2]`: 两个哈希表，用于渐进式 rehash。
  - `rehashidx`: rehash 索引。
- **优点**:
  - **高效查找**: 平均时间复杂度为 O(1)。
  - **动态扩展**: 可以根据需要动态扩展哈希表大小。

#### 整数集合 (intset)

- **结构**:
  - `encoding`: 整数集合的编码方式。
  - `length`: 整数集合的长度。
  - `contents[]`: 存储整数的数组。
- **优点**:
  - **节省内存**: 只存储整数，节省内存。
  - **高效插入和删除**: 支持高效的插入和删除操作。

### 4. **Hash**

- **用途**: 存储键值对集合。
- **底层实现**: 哈希表或压缩列表 (ziplist)。

#### 哈希表

- **结构**:
  - `dict`: 哈希表结构。
  - `ht[2]`: 两个哈希表，用于渐进式 rehash。
  - `rehashidx`: rehash 索引。
- **优点**:
  - **高效查找**: 平均时间复杂度为 O(1)。
  - **动态扩展**: 可以根据需要动态扩展哈希表大小。

#### 压缩列表 (ziplist)

- **结构**:
  - `zlbytes`: 压缩列表的总字节数。
  - `zltail`: 压缩列表尾部的偏移量。
  - `zllen`: 压缩列表的元素个数。
  - `entryX`: 压缩列表的元素。
  - `zlend`: 压缩列表的结束标志。
- **优点**:
  - **节省内存**: 通过压缩数据结构来节省内存。
  - **高效遍历**: 支持高效的遍历操作。

### 5. **Sorted Set**

- **用途**: 存储有序的字符串集合，每个元素关联一个分数 (score)，根据分数排序。
- **底层实现**: 跳表 (skiplist) 或压缩列表 (ziplist)。

#### 跳表 (skiplist)

- **结构**:
  - `header`: 指向跳表头部的指针。
  - `tail`: 指向跳表尾部的指针。
  - `level`: 跳表的最大层数。
  - `length`: 跳表的元素个数。
- **优点**:
  - **高效查找**: 平均时间复杂度为 O(log N)。
  - **高效插入和删除**: 支持高效的插入和删除操作。

#### 压缩列表 (ziplist)

- **结构**:
  - `zlbytes`: 压缩列表的总字节数。
  - `zltail`: 压缩列表尾部的偏移量。
  - `zllen`: 压缩列表的元素个数。
  - `entryX`: 压缩列表的元素。
  - `zlend`: 压缩列表的结束标志。
- **优点**:
  - **节省内存**: 通过压缩数据结构来节省内存。
  - **高效遍历**: 支持高效的遍历操作。

### 总结

- **String**: 使用 SDS 实现，支持动态扩展和二进制安全。
- **List**: 使用双向链表或压缩列表实现，支持高效插入和删除。
- **Set**: 使用哈希表或整数集合实现，支持高效查找和动态扩展。
- **Hash**: 使用哈希表或压缩列表实现，支持高效查找和节省内存。
- **Sorted Set**: 使用跳表或压缩列表实现，支持高效查找和排序。