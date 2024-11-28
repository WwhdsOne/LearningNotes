# @Async注解开的线程是通过线程池开的吗？

默认情况下，`@Async` 注解开启的线程是通过 Spring 提供的线程池来管理的。Spring 使用 `TaskExecutor` 接口来管理线程池，默认情况下使用的是 `SimpleAsyncTaskExecutor`，但通常建议配置一个自定义的线程池以更好地控制线程资源。

# @PostConstruct和Construct和@Autowired的顺序

1. **构造函数**：
   - 首先执行 Bean 的构造函数。
   - 构造函数在 Bean 实例化时执行，用于创建 Bean 实例。
2. **`@Autowired`**：
   - 在构造函数执行完成后，Spring 会进行依赖注入。
   - `@Autowired` 注解用于字段、构造函数和方法上，Spring 会自动将匹配的 Bean 注入到被注解的元素中。
3. **`@PostConstruct`**：
   - 在依赖注入完成后，Spring 会执行被 `@PostConstruct` 注解标记的方法。
   - `@PostConstruct` 方法用于在 Bean 初始化完成后执行一些初始化操作。