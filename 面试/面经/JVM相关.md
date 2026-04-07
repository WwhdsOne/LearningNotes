# 1. 关于运行时常量池，下列哪个说法是正确的

A 运行时常量池大小受栈区大小的影响

B 运行时常量池大小受方法区大小的影响

C 存放了编译时期生成的各种字面量

D 存放编译时期生成的符号引用

正确答案：BCD

> 为了避免歧义，以下提及的JVM，是Hotspot
>
> 方法区是什么？
> 方法区是广义上的概念，是一个定义、标准，可以理解为Java中的接口，在Jdk6、7方法区的实现叫永久代；Jdk8之后方法区的实现叫元空间，并从JVM内存中移除，放到了直接内存中；
> 方法区是被所有方法线程共享的一块内存区域.
>
> 运行时常量池是什么？
> 运行时常量池是每一个类或接口的常量池的运行时表示形式.
>
> 具体体现就是在Java编译后生成的.class文件中，会有class常量池，也就是静态的运行时常量池；  
>
> 运行时常量池存放的位置？ 
>
> 运行时常量池一直是方法区的一部分，在不同版本的JDK中，由于方法区位置的变化，运行时常量池所处的位置也不一样.JDK1.7及之前方法区位于永久代.由于一些原因在JDK1.8之后彻底祛除了永久代,用元空间代替。 
>
> 运行时常量池存放什么？
> 存放编译期生成的各种字面量和符号引用；（字面量和符号引用不懂的同学请自行查阅）
> 运行时常量池中包含多种不同的常量，包括编译期就已经明确的数值字面量，也包括到运行期解析后才能够获得的方法或者字段引用。 此时不再是常量池中的符号地址了，这里换为真实地址。
>
> 运行时常量池与字符串常量池？（可能有同学把他俩搞混）
> 字符串常量池：在JVM中，为了减少相同的字符串的重复创建，为了达到节省内存的目的。会单独开辟一块内存，用于保存字符串常量，这个内存区域被叫做字符串常量池.
>
> 字符串常量池位置？ 
>
> JDK1.6时字符串常量池，被存放在方法区中（永久代），而到了JDK1.7，因为永久代垃圾回收频率低；而字符串使用频率比较高，不能及时回收字符串，会导致导致永久代内存不足，就被移动到了堆内存中。

# 2. 以下哪个区域不属于新生代？

正确答案：C

A eden区

B from区

C 元数据区

D to区

> （1）Eden区，from区，to区：三个区的内存比例可以通过参数【–XX:SurvivorRatio=数字】配置，默认该值为8，即Eden:from:to = 8:1:1 
>
> （2）大部分对象创建都是在Eden的（除了个别大对象外，大对象内存可以设置参数【-XX:PretenureSizeThreshold=字节数】配置，超过配置内存的大对象直接进入老年代），from和to不是固定的（可以互换身份，Survivor区），初始化的时候其中一个是空的。
>
> （3）新生代的 Minor GC 中，一个Survivor区中数据复制进去，另个是空的，下一次GC的时候，有数据的是from Survivor，没数据的to Survivor，GC的时候，from区和Eden区的数据都复制到to中。这样from和to就互换身份，一直这么循环处理。
>
> （4）第（3）步中复制一次，所有对象年龄加1，当任意一个对象复制到一定次数（默认15次，可以配置【-XX:MaxTenuringThreshold=数字】参数进行修改）的时候，就被复制到了老年代 
>
> （5）提到老年代，再补充一下，新生代 ( Young )、老年代 ( Old )内存比例为=1:2，新生代加老年代就是java堆内存了
>
> ![4AC5BFBDFC533AA394D4433D2375A422](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/4AC5BFBDFC533AA394D4433D2375A422.png)

# 3. JVM内存不包含如下哪个部分(待学习)

正确答案：D

A Stacks
B PC寄存器
C Heap
D Heap Frame

> ![272084FEBFF2E659FA20DF7ACF52DD13](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/272084FEBFF2E659FA20DF7ACF52DD13.png)

# 4. 以下描述错误的一项是（ JVM内存 ）？

正确答案: C  你的答案: A (错误)

A 程序计数器是一个比较小的内存区域，用于指示当前线程所执行的字节码执行  到了第几行，是线程隔离的
B 原则上讲，所有的对象都是在堆区上分配内存，是线程之间共享的
C 方法区用于存储JVM加载的类信息、常量、静态变量，即使编译器编译后的代码等数据，是线程隔离的
D Java方法执行内存模型，用于存储局部变量，操作数栈，动态链接，方法出口等信息，是线程隔离的

> <img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/5032673_1539139922699_59B2900AA03CB2182A51CDB520B535B6.png" alt="5032673_1539139922699_59B2900AA03CB2182A51CDB520B535B6" style="zoom: 50%;" />
>
> JAVA的JVM的内存可分为3个区：堆(heap)、栈(stack)和方法区(method)
>
> - 栈区:
>
> 1. **每个线程包含一个栈区**，栈中只保存方法中（不包括对象的成员变量）的**基础数据类型和自定义对象的引用(不是对象)**，对象都存放在堆区中
> 2. 每个栈中的数据(原始类型和对象引用)都是私有的，其他栈不能访问。
> 3. 栈分为3个部分：基本类型变量区、执行环境上下文、操作指令区(存放操作指令)。
>
> - 堆区:
>
> 1. 存储的全部是对象实例，每个对象都包含一个与之对应的class的信息(class信息存放在方法区)。
> 2. **jvm只有一个堆区(heap)被所有线程共享**，堆中不存放基本类型和对象引用，只存放对象本身，几乎所有的**对象实例和数组**都在堆中分配。
>
> - 方法区:
>
> 1. 又叫静态区，跟堆一样，被所有的线程共享。它用于存储已经被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据。

# 5.关于Java内存区域下列说法不正确的有哪些(JVM内存待学习)  

正确答案:B C                                    

A 程序计数器是一块较小的内存空间，它的作用可以看做是当前线程所执行的字节码的信号指示器，每个线程都需要一个独立的程序计数器.
B Java虚拟机栈描述的是java方法执行的内存模型，每个方法被执行的时候都会创建一个栈帧，用于存储局部变量表、类信息、动态链接等信息
C Java堆是java虚拟机所管理的内存中最大的一块，每个线程都拥有一块内存区域，所有的对象实例以及数组都在这里分配内存。
D 方法区是各个线程共享的内存区域，它用于存储已经被虚拟机加载的常量、即时编译器编译后的代码、静态变量等数据。                       

> A.程序计数器是一块较小的内存空间，它的作用可以看做是当前线程所执行的字节码的信号指示器（偏移地址），Java编译过程中产生的字节码有点类似编译原理的指令，程序计数器的内存空间存储的是当前执行的字节码的偏移地址，每一个线程都有一个独立的程序计数器（**程序计数器的内存空间是线程私有的**），因为当执行语句时，改变的是程序计数器的内存空间，因此它不会发生内存溢出 **，并且程序计数器是jvm虚拟机规范中唯一一个没有规定 \*OutOfMemoryError\* 异常 的区域；** 
>
> B.java虚拟机栈：**线程私有**，生命周期和线程一致。描述的是 Java 方法执行的内存模型：每个方法在执行时都会床创建一个栈帧(Stack Frame)用于存储局部变量表、操作数栈、动态链接、方法出口等信息。每一个方法从调用直至执行结束，就对应着一个栈帧从虚拟机栈中入栈到出栈的过程。 **没有类信息，类信息是在方法区中**
>
> C.java堆：对于绝大多数应用来说，这块区域是 JVM 所管理的内存中最大的一块。**线程共享**，主要是存放对象实例和数组
>
> D.方法区：属于**共享内存区域**，存储已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据。

# 6. 下面有关java classloader说法错误的是? 

正确答案：C                                     

A Java默认提供的三个ClassLoader是BootStrap ClassLoader，Extension ClassLoader，App ClassLoader
B ClassLoader使用的是双亲委托模型来搜索类的
C JVM在判定两个class是否相同时，只用判断类名相同即可，和类加载器无关
D ClassLoader就是用来动态加载class文件到内存当中用的

> 一个jvm中默认的classloader有Bootstrap ClassLoader、Extension  ClassLoader、App ClassLoader，分别各司其职： 
>
> - **BootstrapClassLoader**负责加载java基础类，主要是%JRE_HOME/lib/ 目录下的rt.jar、resources.jar、charsets.jar和class等 
> - **ExtensionClassLoader**负责加载java扩展类，主要是 %JRE_HOME/lib/ext 目录下的jar和class    
> - **AppClassLoader**负责加载当前java应用的classpath中的所有类。
>
> classloader 加载类用的是全盘负责委托机制。*所谓全盘负责，即是当一个classloader加载一个Class的时候，这个Class所依赖的和引用的所有 Class也由这个classloader负责载入，除非是显式的使用另外一个classloader载入。*  
> 所以，当我们自定义的classloader加载成功了com.company.MyClass以后，MyClass里所有依赖的class都由这个classLoader来加载完成。

# 7. 下面有关 java 类加载器,说法正确的是?()   


A 引导类加载器(bootstrap class loader):它用来加载 Java 的核心库,是用C++来实现的
B 扩展类加载器(extensions class loader):它用来加载 Java 的扩展库。
C 系统类加载器(system class loader):它根据 Java 应用的类路径(CLASSPATH)来加载 Java 类
D tomcat 为每个 App 创建一个 Loader,里面保存着此 WebApp 的 ClassLoader。需要加载 WebApp 下的类时,就取出 ClassLoader 来使用                        

正确答案：B C D

> 	1）Bootstrap ClassLoader
>   						
>   	负责加载$JAVA_HOME中jre/lib/rt.jar里所有的class，由C++实现，不是ClassLoader子类
>   						
>   	2）Extension ClassLoader
>   						
>   	负责加载java平台中扩展功能的一些jar包，包括$JAVA_HOME中jre/lib/*.jar或-Djava.ext.dirs指定目录下的jar包
>   						
>   	3）App ClassLoader
>   						
>   	负责记载classpath中指定的jar包及目录中class
>   						
>   	4）Custom ClassLoader
>   						
>   	属于应用程序根据自身需要自定义的ClassLoader，如tomcat、jboss都会根据j2ee规范自行实现ClassLoader
>   						
>   	加载过程中会先检查类是否被已加载，检查顺序是自底向上，从Custom ClassLoader到BootStrap ClassLoader逐层检查，只要某个classloader已加载就视为已加载此类，保证此类只所有ClassLoader加载一次。而加载的顺序是自顶向下，也就是由上层来逐层尝试加载此类。

# 8.下面有关JVM内存，说法错误的是？ 

正确答案：C                         

A 程序计数器是一个比较小的内存区域，用于指示当前线程所执行的字节码执行到了第几行，是线程隔离的
B 虚拟机栈描述的是Java方法执行的内存模型，用于存储局部变量，操作数栈，动态链接，方法出口等信息，是线程隔离的
C 方法区用于存储JVM加载的类信息、常量、静态变量、以及编译器编译后的代码等数据，是线程隔离的
D 原则上讲，所有的对象都在堆区上分配内存，是线程之间共享的

> 方法区在JVM中也是一个非常重要的区域，它与堆一样，是被 **线程共享** 的区域。 在方法区中，存储了每个类的信息（包括类的名称、方法信息、字段信息）、静态变量、常量以及编译器编译后的代码等。

# 9. 下面有关java classloader说法正确的是（）？ 

A ClassLoader就是用来动态加载class文件到内存当中用的


B JVM在判定两个class是否相同时，只用判断类名相同即可，和类加载器无关


C ClassLoader使用的是双亲委托模型来搜索类的


D Java默认提供的三个ClassLoader是Boostrap ClassLoader，Extension ClassLoader，App ClassLoader

E 以上都不正确



> JDK中提供了三个ClassLoader，根据层级从高到低为： 
>
> 1. Bootstrap ClassLoader，主要加载JVM自身工作需要的类。      
> 2. Extension ClassLoader，主要加载%JAVA_HOME%\lib\ext目录下的库类。      
> 3. Application ClassLoader，主要加载Classpath指定的库类，一般情况下这是程序中的默认类加载器，也是**ClassLoader.getSystemClassLoader()** 的返回值。（这里的Classpath默认指的是环境变量中配置的Classpath，但是可以在执行Java命令的时候使用-cp 参数来修改当前程序使用的Classpath）     
>
> ​    JVM加载类的实现方式，我们称为 **双亲委托模型**：   
>
> ​    如果一个类加载器收到了类加载的请求，他首先不会自己去尝试加载这个类，而是把这个请求委托给自己的父加载器，每一层的类加载器都是如此，因此所有的类加载请求最终都应该传送到顶层的**Bootstrap ClassLoader**中，只有当父加载器反馈自己无法完成加载请求时，子加载器才会尝试自己加载。   
>
>    **双亲委托模型的重要用途是为了解决类载入过程中的安全性问题。**  
>
>    假设有一个开发者自己编写了一个名为java.lang.Object的类，想借此欺骗JVM。现在他要使用**自定义ClassLoader**来加载自己编写的***java.lang.Object\**类。然而幸运的是，**双亲委托模型**不会让他成功。因为JVM会优先在**Bootstrap ClassLoader**的路径下找到**java.lang.Object类，并载入它