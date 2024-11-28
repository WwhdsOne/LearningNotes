# ConcurrentHashMap 和 Hashtable 的区别

- **ConcurrentHashMap**:
  - 线程安全，支持高并发。
  - 使用分段锁（Segment）机制，允许多个线程同时访问不同的段。
  - 性能较高，适用于高并发场景。
- **Hashtable**:
  - 线程安全，但使用全局锁，性能较低。
  - 不支持高并发，适用于低并发场景。

# 扩容机制，链表怎么扩容至红黑树

- **扩容机制**:
  - 当 HashMap 中的元素数量超过阈值（容量 * 负载因子）时，会触发扩容。
  - 新表的大小是旧表的两倍。
- **链表扩容至红黑树**:
  - 当链表长度超过 8 且数组长度超过 64 时，链表会转换为红黑树。
  - 红黑树的插入、删除和查找操作的时间复杂度为 O(log n)，提高了性能。

# Java IO 类型

- **BIO (Blocking I/O)**:
  - 阻塞式 I/O，线程在读写数据时会被阻塞。
  - 适用于连接数较少且稳定的场景。
- **NIO (Non-blocking I/O)**:
  - 非阻塞式 I/O，使用 Channel 和 Buffer 进行数据传输。
  - 适用于高并发、连接数较多的场景。
- **AIO (Asynchronous I/O)**:
  - 异步 I/O，基于事件和回调机制。
  - 适用于高性能、高并发的场景。

# HashMap 为什么新表是旧表的两倍呢

- **原因**:
  - 扩容为旧表的两倍可以减少哈希冲突，提高查询效率。
  - 扩容后，元素的分布更加均匀，减少了链表长度，提高了性能。
  - 因为与散列公式`index = hash(key) & (new_length - 1)`进行散列,如果是2的倍数-1,可以获得类似`1111`的数，进行散列可以使用位运算，更快。

# JDK 实现的锁的种类

- **ReentrantLock**:
  - 可重入锁，支持公平锁和非公平锁。
- **ReentrantReadWriteLock**:
  - 读写锁，允许多个线程同时读，但只允许一个线程写。
- **StampedLock**:
  - 乐观读锁，适用于读多写少的场景。

# NIO 和 BIO

- **NIO**:
  - 非阻塞式 I/O，使用 Channel 和 Buffer。
  - 适用于高并发、连接数较多的场景。
- **BIO**:
  - 阻塞式 I/O，线程在读写数据时会被阻塞。
  - 适用于连接数较少且稳定的场景。

# ThreadLocal

- **内存泄漏问题**:

  - ThreadLocal 可能导致内存泄漏，因为每个线程都有一个 ThreadLocalMap，存储 ThreadLocal 对象和对应的值。

  - 如果线程长时间存活，ThreadLocalMap 中的 Entry 可能不会被回收，导致内存泄漏。

  - **长生命周期线程**：当线程存活时间较长时（例如线程池中的线程），如果开发者没有手动调用 `remove()` 清除 `ThreadLocal`，这些 `ThreadLocal` 变量可能会一直保存在 `ThreadLocalMap` 中，即使不再需要。

    **键被回收**：由于 `ThreadLocal` 键是弱引用，如果 `ThreadLocal` 对象被垃圾回收，键将被清除，但值是强引用，值仍然存在，导致内存泄漏，因为垃圾回收器无法回收这些值。

- **解决方法**:

  - 使用完 ThreadLocal 后，调用 `remove()` 方法清除数据。

- **应用场景**:

  - 线程隔离，如数据库连接、Session 管理等。

# AQS

AQS（AbstractQueuedSynchronizer，抽象队列同步器）是 Java 并发包 `java.util.concurrent.locks` 中的一个核心组件，它提供了一个框架，用于实现依赖于先进先出（FIFO）等待队列的阻塞锁和相关同步器（如信号量、事件等）。AQS 是许多同步工具的基础，包括 `ReentrantLock`、`Semaphore`、`CountDownLatch` 等。

# 创建线程池的常见参数

1. `corePoolSize`（核心线程数）

- **定义**: 线程池中始终保持的线程数量，即使这些线程处于空闲状态。
- **默认值**: 通常根据任务的性质和系统的负载来设置。
- **作用**: 确保线程池中有足够的线程来处理基本任务。

2. `maximumPoolSize`（最大线程数）

- **定义**: 线程池中允许的最大线程数量。
- **默认值**: 通常设置为核心线程数加上一些额外的线程数，以应对突发的高负载。
- **作用**: 控制线程池的最大并发度，防止资源耗尽。

3.  `keepAliveTime`（线程存活时间）

- **定义**: 当线程数量超过核心线程数时，多余的空闲线程在终止前等待新任务的最长时间。
- **默认值**: 通常设置为几分钟。
- **作用**: 控制非核心线程的存活时间，避免资源浪费。

4. `unit`（时间单位）

- **定义**: `keepAliveTime`的时间单位。
- **可选值**: `TimeUnit.SECONDS`, `TimeUnit.MILLISECONDS`, `TimeUnit.MINUTES`, 等。
- **作用**: 指定`keepAliveTime`的时间单位。

5.  `workQueue`（工作队列）

- **定义**: 用于保存等待执行的任务的队列。
- **常见类型**:
  - `ArrayBlockingQueue`: 有界队列。
  - `LinkedBlockingQueue`: 无界队列（默认）。
  - `SynchronousQueue`: 不存储元素的队列，每个插入操作必须等待另一个线程的移除操作。
- **作用**: 控制任务的排队策略。

6.  `threadFactory`（线程工厂）

- **定义**: 用于创建新线程的工厂。
- **默认值**: 使用默认的线程工厂。
- **作用**: 可以自定义线程的名称、优先级等属性。

7. `handler`（拒绝策略）

- **定义**: 当线程池和队列都满时，新任务的处理策略。
- **常见策略**:
  - `AbortPolicy`: 直接抛出`RejectedExecutionException`。
  - `CallerRunsPolicy`: 由调用线程执行任务。
  - `DiscardPolicy`: 直接丢弃任务。
  - `DiscardOldestPolicy`: 丢弃队列中最旧的任务。
- **作用**: 处理无法执行的任务。

# JNI

Java Native Interface (JNI) 是 Java 提供的一种机制，允许 Java 代码与用其他编程语言（如 C、C++）编写的本地代码进行交互。JNI 是 Java 平台的一部分，它定义了一套标准的 API，使得 Java 程序可以调用本地方法，同时本地代码也可以调用 Java 方法。

JNI 的作用

1. **调用本地库**：Java 程序通过 JNI 调用本地库，实现高性能计算或访问底层系统资源。
2. **性能优化**：将计算密集型任务交给本地代码处理，提高性能。
3. **访问底层资源**：Java 通过 JNI 访问硬件设备或操作系统特定功能。
4. **代码集成**：与现有 C/C++ 代码集成，无需重写。
5. **功能扩展**：通过 JNI 扩展 Java 功能。

