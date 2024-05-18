# 1. 在java中重写方法应遵循规则的包括：

正确答案: B C  你的答案: A D (错误)

A 访问修饰符的限制一定要大于被重写方法的访问修饰符
B 可以有不同的访问修饰符
C 参数列表必须完全与被重写的方法相同
D 必须具有不同的参数列表

> **方法的重写（override）两同两小一大原则**：
>
> 方法名相同，参数类型相同
>
> 子类返回类型小于等于父类方法返回类型，
>
> 子类抛出异常小于等于父类方法抛出异常，
>
> 子类访问权限大于等于父类方法访问权限。

# 2. 关于下面的一段代码，以下哪些说法是正确的：

正确答案: A D  你的答案: B D (错误)

```java
public static void main(String[] args) {
    String a = new String("myString");
    String b = "myString";
    String c = "my" + "String";
    String d = c;
    System.out.print(a == b);
    System.out.print(a == c);
    System.out.print(b == c);
    System.out.print(b == d);
}
```
A System.out.print(a == b)打印出来的是false

B System.out.print(a == c)打印出来的是true

C System.out.print(b == c)打印出来的是false

D System.out.print(b == d)打印出来的是true

> A是运行时动态加载的，此时会在堆内存中生成一个myString字符串，指向堆内存字符串地址
>
> B是编译时静态加载的，此时会在常量池中存放一个myString字符串，指向常量池字符串地址
>
> C会在编译时对"my" + "String"进行拼接成myString字符串，再去常量池查找，找到之后指向该字符串地址
>
> D是C的脚本，地址相同
>
> 最后：Sting的==比较的是地址值是否相同

# 3. 下面赋值语句中正确的是：

正确答案: A  你的答案: B (错误)

A double d=5.3e12;
B float f=11.1;
C int i=0.0;
D Double oD=3;

> A：5.3e12表示5.3乘以10的12次方，正确,根据IEEE754标准，双精度规格化最大数为1.7e308
>
> B: **在Java中，如果你输入一个小数，系统默认的是double类型的，这个式子相当于** **float f=double 11.1，明显错误，如果想要表达11.1为float类型的，需要在11.1末尾加一个f标识你输入的是float类型即可**
>
> C：0.0是小数，默认是double，不是int
>
> D：int 转为 封装类型Double，是无法编译的，Double oD = 3.0， 会把double类型的3.0自动装箱为Double，没有问题

# 4. 以下哪种方式实现的单例是线程安全的

正确答案: A B C D  你的答案: B C (错误)

A 枚举
B 静态内部类
C 双检锁模式
D 饿汉式

>A. 枚举：Java 枚举本身就是线程安全的，因此使用枚举实现的单例模式也是线程安全的。  
>
>B. 静态内部类：静态内部类只有在被调用时才会加载，实现了懒加载，且由 JVM 保证了线程安全。  
>
>C. 双检锁模式：双检锁模式（Double-Checked Locking）在同步块外部和内部都检查了实例是否已经存在，只有当实例不存在时才会进行同步，这样既保证了线程安全，又提高了执行效率。  
>
>D. 饿汉式：饿汉式在类加载时就创建了实例，由 JVM 保证了线程安全，但没有实现懒加载。  所以，所有的选项都可以实现线程安全的单例模式，但是它们在懒加载和执行效率上有所不同。

# 5. 下列说法正确的是（内部类相关）

正确答案：A B

A 对于局部内部类，只有在方法的局部变量被标记为final或局部变量是effctively final的，内部类才能使用它们

B 成员内部类位于外部类内部，可以直接调用外部类的所有方法（静态方法和非静态方法）

C 由于匿名内部类只能用在方法内部，所以匿名内部类的用法与局部内部类是一致的

D 静态内部类可以直接访问外部类的非静态成员

![242025553_1550728055483_BA9669C5826A238ACEC0BD86755FA5DB](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/242025553_1550728055483_BA9669C5826A238ACEC0BD86755FA5DB.png)





# 6. 如果Child extends Parent，那么正确的有：？ 

正确答案：B C D

  A 如果Child是class，且只有一个有参数的构造函数，那么必然会调用Parent中相同参数的构造函数

  B 如果Child是interface，那么Parent必然是interface

  C 如果Child是interface，那么Child可以同时extends Parent1，Parent2等多个interface

  D 如果Child是class，并且没有显示声明任何构造函数，那么此时仍然会调用Parent的构造函数

>   A 可以调用父类无参的构造函数，子类的有参构造函数和是否调用父类的有参数的构造函数无必然联系。  
>
>   B 接口继承的时候只能继承接口不能继承类，因为如果类可以存在非抽象的成员，如果接口继承了该类，那么接口必定从类中也继承了这些非抽象成员，这就和接口的定义相互矛盾，所以接口继承时只能继承接口。  
>
>   C 接口可以多继承可以被多实现，因为接口中的方法都是抽象的，这些方法都被实现的类所实现，即使多个父接口中有同名的方法，在调用这些方法时调用的时子类的中被实现的方法，不存在歧义；同时，接口的中只有静态的常量，但是由于静态变量是在编译期决定调用关系的，即使存在一定的冲突也会在编译时提示出错；而引用静态变量一般直接使用类名或接口名，从而避免产生歧义，因此也不存在多继承的第一个缺点。 对于一个接口继承多个父接口的情况也一样不存在这些缺点。所以接口可以多继承。   
>
>   D 子类即使没有显示构造函数，也会有个无参数的默认构造函数，仍然会调用父类的构造函数。

# 7. java中提供了哪两种用于多态的机制

正确答案B C D                               

A 通过子类对父类方法的覆盖实现多态

B 利用重载来实现多态.即在同一个类中定义多个同名的不同方法来实现多态。

C 利用覆盖来实现多态.即在同一个类中定义多个同名的不同方法来实现多态。

D 通过子类对父类方法的重载实现多态

> **重载**（Overload）是**编译时的多态**，因为根据调用传参的类型、数量便可决定调用的是哪个重载方法，因此并不需要推迟到运行时去决定调用哪个方法，所以它是编译期就能决定的。  
>
> **重写**（Override，又称覆盖）是**运行时的多态**，我们都知道重写的前提是**类继承**，重写的方法的名称、参数必须跟被重写的方法一致（异常列表、返回结果及访问修饰符等限制这里不赘述），因此**无法通过方法参数决定调用的是哪个子类或是父类的方法**。**只能在运行时通过传入的对象来动态决定**。  
>
> 总结：不管是**重载（Overload）**还是**重写（Override）**，都是实现Java动态机制的一种手段。

# 8. 阅读如下代码。 请问，对语句行 test.hello(). 描述正确的有（）

```java
package NowCoder;
class Test {
	public static void hello() {
	    System.out.println("hello");
	}
}
public class MyApplication {
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Test test=null;
		test.hello();
	}
}
```

正确答案: A  你的答案: D (错误)

A 能编译通过，并正确运行
B 因为使用了未初始化的变量，所以不能编译通过
C 以错误的方式访问了静态方法
D 能编译通过，但因变量为null，不能正常运行

> 静态方法的使用不依靠对象，只看类型，在编译时就确定了

# 9. Java1.8版本之前的前提，Java特性中,abstract class和interface有什么区别（）

正确答案: A B D  你的答案: A C D (错误)

A 抽象类可以有构造方法，接口中不能有构造方法
B 抽象类中可以有普通成员变量，接口中没有普通成员变量
C 抽象类中不可以包含静态方法，接口中可以包含静态方法
D 一个类可以实现多个接口，但只能继承一个抽象类。

> A B D显然都是对的。主要说C选项：
>
> 在JDK1.8之前的版本（不包括JDK1.8），接口中不能有静态方法，抽象类中因为有普通方法，故也可以有静态方法。
>
> 在JDK1.8后（包括JDK1.8），在抽象类中依旧可以有静态方法，同时在接口中也可以定义静态方法了。
>
> 以下代码在JDK1.8之后是没有问题的（可以通过接口名来调用静态方法 ：Main.prinf(); ）：
>
> ```java
> public interface Demo{
>        public static void print() {         
>            System.out.println("Hello World!");      
>        }
> }
> ```
>
> PS：
>
> 在JDK1.7，接口中只包含抽象方法，使用public abstract 修饰。
>
> ```java
> public interface Demo{
>        public abstract void method();
> }
> ```
>
> 在JDK1.8，接口中新加了默认方法和静态方法：
>
> ​    默认方法：使用default修饰，在接口的实现类中，可以直接调用该方法，也可以重写该方法。
>
> ​    静态方法：使用static修饰，通过接口直接调用。
>
> ```java
> public interface Demo{
>        //默认方法
>        public default void method(){
>            System.out.println("default method...");
>        }
>        //静态方法
>        public static void print(){
>            System.out.println("static method...");
>        }
> }
> ```
>
> 在JDK1.9，接口中新加了私有方法，使用private修饰，私有方法供接口内的默认方法调用。
>
> ```java
> public interface Demo{
>        private void method() {
>            System.out.println("Hello World!");
>        }
> } 
> ```

# 10. ArrayLists和LinkedList的区别，下述说法正确的有？

正确答案: A B C D  你的答案: A C D (错误)

A ArrayList是实现了基于动态数组的数据结构，LinkedList基于链表的数据结构。
B 对于随机访问get和set，ArrayList绝对优于LinkedList，因为LinkedList要迭代器。
C 对于新增和删除操作add和remove，LinkedList比较占优势，因为ArrayList要移动数据。
D ArrayList的空间浪费主要体现在在list列表的结尾预留一定的容量空间，而LinkedList的空间花费则体现在它的每一个元素都需要消耗相当的空间。

> A. ArrayList是实现了基于动态数组的数据结构，LinkedList基于链表的数据结构。  
>
> //**正确**，这里的所谓动态数组并不是那个“ 有多少元素就申请多少空间 ”的意思，通过查看源码，可以发现，这个动态数组是这样实现的，如果没指定数组大小，则申请默认大小为10的数组，当元素个数增加，数组无法存储时，系统会另个申请一个长度为当前长度1.5倍的数组，然后，把之前的数据拷贝到新建的数组。
>
> \-----------------------------------------------------------------------
>
> B. 对于随机访问get和set，ArrayList觉得优于LinkedList，因为LinkedList要移动指针。
>
> //**正确**，ArrayList是数组，所以，直接定位到相应位置取元素，LinkedList是链表，所以需要从前往后遍历。
>
> \------------------------------------------------------------------------
>
> C. 对于新增和删除操作add和remove，LinedList比较占优势，因为ArrayList要移动数据。
>
> //**正确**，ArrayList的新增和删除就是数组的新增和删除，LinkedList与链表一致。
>
> \-------------------------------------------------------------------------
>
> D. ArrayList的空间浪费主要体现在在list列表的结尾预留一定的容量空间，而LinkedList的空间花费则体现在它的每一个元素都需要消耗相当的空间。
>
> //**正确**，因为ArrayList空间的增长率为1.5倍，所以，最后很可能留下一部分空间是没有用到的，因此，会造成浪费的情况。对于LInkedList的话，由于每个节点都需要额外的指针，所以，你懂的。

# 11. 下面关于volatile的功能说法正确的是哪个

正确答案: B C  你的答案: A B D (错误)

A 原子性
B 有序性
C 可见性
D 持久性

> - 原子性：提供了互斥访问，同一时刻只能有一个线程来对它进行操作。
> - 可见性：一个线程对主内存的修改可以及时的被其他线程观察到。
> - 有序性：一个线程观察其他线程中的指令执行顺序，由于指令重排序的存在，该观察结果一般杂乱无序。
>
> synchronized保证三大性，原子性，有序性，可见性，volatile保证有序性，可见性，不能保证原子性
>
> volatile到底做了什么:
>
> - 禁止了指令重排
> - 保证了不同线程对这个变量进行操作时的可见性，即一个线程修改了某个变量值，这个新值对其他线程是立即可见的
> - 不保证原子性（线程不安全）
>
> synchronized关键字和volatile关键字比较：
>
> - volatile关键字是线程同步的轻量级实现，所以volatile性能肯定比synchronized关键字要好。但是volatile关键字只能用于变量而synchronized关键字可以修饰方法以及代码块。synchronized关键字在JavaSE1.6之后进行了主要包括为了减少获得锁和释放锁带来的性能消耗而引入的偏向锁和轻量级锁以及其它各种优化之后执行效率有了显著提升，实际开发中使用 synchronized 关键字的场景还是更多一些。
> - 多线程访问volatile关键字不会发生阻塞，而synchronized关键字可能会发生阻塞
> - volatile关键字能保证数据的可见性，但不能保证数据的原子性。synchronized关键字两者都能保证。
> - volatile关键字主要用于解决变量在多个线程之间的可见性，而synchronized关键字解决的是多个线程之间访问资源的同步性。

# 12. 下面代码的输出是什么？（类加载顺序相关）

```java
public class Base
{
    private String baseName = "base";
    public Base()
    {
        callName();
    }
    public void callName()
    {
        System. out. println(baseName);
    }
    static class Sub extends Base
    {
        private String baseName = "sub";
        public void callName()
        {
            System. out. println (baseName) ;
        }
    }
    public static void main(String[] args)
    {
        Base b = new Sub();
    }
}
```

正确答案: A  你的答案: C (错误)

A null
B sub
C base

> 1. 首先，需要明白**类的加载顺序**。
>
>    (1) 父类静态代码块(包括静态初始化块，静态属性，但不包括静态方法)
>
>    (2) 子类静态代码块(包括静态初始化块，静态属性，但不包括静态方法 )
>
>    (3) 父类非静态代码块( 包括非静态初始化块，非静态属性 )
>
>    (4) 父类构造函数
>
>    (5) 子类非静态代码块 ( 包括非静态初始化块，非静态属性 )
>
>    (6) 子类构造函数
>
>    其中：类中静态块按照声明顺序执行，并且(1)和(2)不需要调用new类实例的时候就执行了(意思就是在类加载到方法区的时候执行的)
>
> 2. 其次，需要理解子类覆盖父类方法的问题，也就是**方法重写实现多态**问题。
>
>    Base b = new Sub();**它为多态的一种表现形式，声明是Base,实现是Sub类，** **理解为** **b** **编译时表现为Base类特性，运行时表现为Sub类特性。**
>
>    当子类覆盖了父类的方法后，意思是父类的方法已经被重写，**题中** **父类初始化调用的方法为子类实现的方法，子类实现的方法中调用的baseName为子类中的私有属性。**
>
>    由1.可知，此时只执行到步骤4.,子类非静态代码块和初始化步骤还没有到，子类中的baseName还没有被初始化。所以此时 baseName为空。 所以为null。

# 13. 将下列哪个代码（A、B、C、D）放入程序中标注的【代码】处将导致编译错误？

```java
class A{
    public float getNum(){
        return 3.0f;
    }
}
public class B extends A{
    【代码】
}
```

正确答案: B  你的答案: D (错误)

A `public float getNum(){return 4.0f;}`
B `public void getNum(){}`
C `public void getNum(double d){}`
D `public double getNum(float d){return 4.0d;}`

> 方法重写要求方法名，返回值类型，参数完全相同，所以A符合，B返回值类型不同，编译错误。而C和D不仅返回值类型不同，参数也不同，不属于方法重写，而是属于子类自己新增的方法。所以选B
>
> 两同两小一大原则，即：
> 方法名相同，参数类型相同
> 子类返回类型小于等于父类方法返回类型，
> 子类抛出异常小于等于父类方法抛出异常，
> 子类访问权限大于等于父类方法访问权限。

# 14. 以下哪几种方式可用来实现线程间通知和唤醒：( )

正确答案: A C  你的答案: A B C D (错误)

A Object.wait/notify/notifyAll
B ReentrantLock.wait/notify/notifyAll
C Condition.await/signal/signalAll
D Thread.wait/notify/notifyAll

> **wait()、notify()和notifyAll()是Object类中的方法** 
> 
>从这三个方法的文字描述可以知道以下几点信息：  
> 
>1）wait()、notify()和notifyAll()方法是本地方法，并且为final方法，无法被重写。  
> 2）调用某个对象的wait()方法能让当前线程阻塞，并且当前线程必须拥有此对象的monitor（即锁）   
>
>    3）调用某个对象的notify()方法能够唤醒一个正在等待这个对象的monitor的线程，如果有多个线程都在等待这个对象的monitor，则只能唤醒其中一个线程；  
>4）调用notifyAll()方法能够唤醒所有正在等待这个对象的monitor的线程；  
>    有朋友可能会有疑问：为何这三个不是Thread类声明中的方法，而是Object类中声明的方法  
>    （当然由于Thread类继承了Object类，所以Thread也可以调用者三个方法）？其实这个问题很简单，由于每个对象都拥有monitor（即锁），所以让当前线程等待某个对象的锁，当然应该通过这个对象来操作了。而不是用当前线程来操作，因为当前线程可能会等待多个线程的锁，如果通过线程来操作，就非常复杂了。上面已经提到，如果调用某个对象的wait()方法，当前线程必须拥有这个对象的monitor（即锁），因此调用wait()方法必须在同步块或者同步方法中进行（synchronized块或者synchronized方法）。  
> 调用某个对象的wait()方法，相当于让当前线程交出此对象的monitor，然后进入等待状态，等待后续再次获得此对象的锁（Thread类中的sleep方法使当前线程暂停执行一段时间，从而让其他线程有机会继续执行，但它并不释放对象锁）；notify()方法能够唤醒一个正在等待该对象的monitor的线程，当有多个线程都在等待该对象的monitor的话，则只能唤醒其中一个线程，具体唤醒哪个线程则不得而知。同样地，调用某个对象的notify()方法，当前线程也必须拥有这个对象的monitor，因此调用notify()方法必须在同步块或者同步方法中进行（synchronized块或者synchronized方法）。ofityAll()方法能够唤醒所有正在等待该对象的monitor的线程，这一点与notify()方法是不同的。  
>    
>    **Condition是在java 1.5中才出现的，它用来替代传统的Object的wait()、notify()实现线程间的协作，相比使用Object的wait()、notify()，使用Condition1的await()、signal()这种方式实现线程间协作更加安全和高效。因此通常来说比较推荐使用Condition，在阻塞队列那一篇博文中就讲述到了，阻塞队列实际上是使用了Condition来模拟线程间协作。**
>    
>    - Condition是个接口，基本的方法就是await()和signal()方法；  
>    - Condition依赖于Lock接口，生成一个Condition的基本代码是lock.newCondition()  
>    -    调用Condition的await()和signal()方法，都必须在lock保护之内，就是说必须在lock.lock()和lock.unlock之间才可以使用Conditon中的await()对应Object的wait()；    Condition中的signal()对应Object的notify()；    Condition中的signalAll()对应Object的notifyAll()

# 15. 下面哪个不对？（异常相关）

正确答案: C


  A RuntimeException is the superclass of those exceptions that can be thrown during the normal operation of the Java Virtual Machine.`(RuntimeException是Java虚拟机正常操作期间可以抛出的异常的超类。)`

  B A method is not required to declare in its throws clause any subclasses of RuntimeExeption that might be thrown during the execution of the method but not caught`(方法不需要在其throws子句中声明RuntimeExeption的任何子类，这些子类可能在方法的执行过程中抛出但未被捕获)`

  C An RuntimeException is a subclass of Throwable that indicates serious problems that a reasonable application should not try to catch.`(RuntimeException是Throwable的一个子类，表示合理的应用程序不应该试图捕捉的严重问题。)`

  D NullPointerException is one kind of RuntimeException`(空指针异常是RuntimeException的一个子类)`

# 16. Servlet的生命周期可以分为初始化阶段，运行阶段和销毁阶段三个阶段，以下过程属于初始化阶段是（）。

正确答案: A C D  你的答案: A D (错误)

A 加载Servlet类及.class对应的数据
B 创建servletRequest和servletResponse对象
C 创建ServletConfig对象
D 创建Servlet对象

> <img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/837161_1500632807603_69CC22FA8A75E64DB0D6CBB3F4B6995F.jpg" alt="img" style="zoom:50%;" />
>
> Servlet（Server Applet），全称Java Servlet，未有中文译文。是用Java编写的服务器端程序。其主要功能在于交互式地浏览和修改数据，生成动态Web内容。狭义的Servlet是指Java语言实现的一个接口，广义的Servlet是指任何实现了这个Servlet接口的类，一般情况下，人们将Servlet理解为后者。 Servlet运行于支持Java的应用服务器中。从原理上讲，Servlet可以响应任何类型的请求，但绝大多数情况下Servlet只用来扩展基于HTTP协议的Web服务器。 这个过程为： 
>
> 1) 客户端发送请求至服务器端； 
> 2) 服务器将请求信息发送至 Servlet； 
> 3) Servlet 生成响应内容并将其传给服务器。响应内容动态生成，通常取决于客户端的请求； 
> 4) 服务器将响应返回给客户端。

# 17. 有如下一段代码，请选择其运行结果（java内存相关）

```java
public class StringDemo{
    private static final String MESSAGE="taobao";
    public static void main(String [] args) {
        String a = "tao"+"bao";
        String b = "tao";
        String c = "bao";
        System.out.println(  a == MESSAGE  );
        System.out.println( ( b + c ) == MESSAGE  );
    }
}  
```

正确答案: C  你的答案: A (错误)

A true true
B false false
C true false
D false true

> MESSAGE和a的字符串都存储在常量池里，且二者内容相同。
>
> 而(c+b)的内容则是存放在堆内存中，两者指向不同，所以是false。![AE29DD7F161F1C3498BBA73AA043DCB8](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/AE29DD7F161F1C3498BBA73AA043DCB8.png)

# 18. 下面选项中,哪些是interface中合法方法定义?()                                        
- ```
  public void main(String [] args);
  ```

- ```
  private int getSum();
  ```

- ```
  boolean setFlag(Boolean [] test);
  ```

- ```
  public float get(int x)                                        
  ```

正确答案：A C D

> java程序的入口必须是static类型的，接口中不允许有static类型的方法。A项没有static修饰符，可以作为普通的方法。而且接口中的方法必须是public的。想想借口就是为了让别人实现的，相当于标准，标准不允许别人使用是不合理的，所以接口中的方法必须是public。C项中，接口中的方法默认是public的。D项属于正常的方法。所以答案是：ACD

# 19. Java语言中，下面哪个语句是创建数组的正确语句？(   )                                        
- ```
  float f[][] = new float[6][6];
  ```

- ```
  float []f[] = new float[6][6];
  ```

- ```
  float f[][] = new float[][6];
  ```

- ```
  float [][]f = new float[6][6];
  ```

- ```
  float [][]f = new float[6][];                     
  ```

正确答案：A B D E

> 在Java中，第一个框必须有值

# 20.观察以下代码：（类中final方法相关） 
```java
class Car extends Vehicle
{
    public static void main (String[] args)
    {
        new  Car(). run();
    }
    private final void run()
    {
        System. out. println ("Car");
    }
}
class Vehicle
{
    private final void run()
    {
        System. out. println("Vehicle");
    }
}
```

 下列哪些针对代码运行结果的描述是正确的？                                        

A Car

B Vehicle

C Compiler error at line 3

D Compiler error at line 5

E Exception thrown at runtime                    

正确答案：A

> 父类定义为final后不允许被重写，所以子类的final方法定义的是属于自己的方法，不会导致编译错误。

# 21. 对文件名为Test.java的java代码描述正确的是(子类调用父类构造函数相关)

```java
class Person {
	String name = "No name";
	public Person(String nm) {
		name = nm;
	}
}
class Employee extends Person {
	String empID = "0000";
	public Employee(String id) {
		empID = id;
	}
}
public class Test {
	public static void main(String args[]) {
		Employee e = new Employee("123");
		System.out.println(e.empID);
	}
}
```

A 输出：0000
B 输出：123
C 编译报错
D 输出：No name

正确答案：C

> 子类的构造方法总是先调用父类的构造方法，如果子类的构造方法没有明显地指明使用父类的哪个构造方法，子类就调用父类不带参数的构造方法。
>
> 一个类只有在没有构造函数的时候，才会被编译器自动添加上无参构造。父类没有无参的构造函数，所以子类需要在自己的构造函数中显示的调用父类的构造函数。

# 22. Java是一门支持反射的语言,基于反射为Java提供了丰富的动态性支持，下面关于哪些是错误的：(  )

正确答案：A D F                                       


  A Java反射主要涉及的类如Class, Method, Filed,等，他们都在java.lang.reflet包下

  B 通过反射可以动态的实现一个接口，形成一个新的类，并可以用这个类创建对象，调用对象方法

  C 通过反射，可以突破Java语言提供的对象成员、类成员的保护机制，访问一般方式不能访问的成员

  D Java反射机制提供了字节码修改的技术，可以动态的修剪一个类


  E Java的反射机制会给内存带来额外的开销。例如对永生堆的要求比不通过反射要求的更多

  F Java反射机制一般会带来效率问题，效率问题主要发生在查找类的方法和字段对象，因此通过缓存需要反射类的字段和方法就能达到与之间调用类的方法和访问类的字段一样的效率

>   A Class类在java.lang包 
>
>   B 动态代理技术可以动态创建一个代理对象，反射不行 
>
>   C 反射访问私有成员时，Field调用setAccessible可解除访问符限制 
>
>   D CGLIB实现了字节码修改，反射不行 
>
>   E 反射会动态创建额外的对象，比如每个成员方法只有一个Method对象作为root，他不胡直接暴露给用户。调用时会返回一个Method的包装类 
>
>   F 反射带来的效率问题主要是动态解析类，JVM没法对反射代码优化

# 23. 下面说法正确的是？（yield和sleep）                             

  A 调用Thread的sleep()方法会释放锁，调用wait()方法不释放锁
  B 一个线程调用yield方法，可以使具有相同优先级线程获得处理器
  C 在Java中，高优先级的可运行的线程会抢占低优先级线程的资源
  D java中，线程可以调用yield方法使比自己低优先级的线程运行

正确答案: B C

# 24. 下面哪些描述是正确的：（回收内存相关）

```java
public class Test {
    public static class A {
        private B ref;
        public void setB(B b) {
            ref = b;
        }
    }
    public static Class B {
        private A ref;
        public void setA(A a) {
            ref = a;
        }
    }
    public static void main(String args[]) {
        start();
    }
    public static void start() { 
        A a = new A();
        B b = new B();
        a.setB(b);
        b = null;
        a = null;
    }
}
```

正确答案: B C  你的答案: D F (错误)

A b = null执行后b可以被垃圾回收
B a = null执行后b可以被垃圾回收
C a = null执行后a可以被垃圾回收
D a,b必须在整个程序结束后才能被垃圾回收
E 类A和类B在设计上有循环引用，会导致内存泄露
F a, b 必须在start方法执行完毕才能被垃圾回收

> ![165701207_1586336189484_802A6FE5D8D89EC50285B88F46C488F4](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/165701207_1586336189484_802A6FE5D8D89EC50285B88F46C488F4.png)

# 25. 一个Java源程序文件中定义几个类和接口，则编译该文件后生成几个以.class为后缀的字节码文件。

正确答案：B


  A 正确

  B 错误

> ![2272338_1526292885002_385B3583D97072502160951474A96124](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/2272338_1526292885002_385B3583D97072502160951474A96124.png)

# 26. 类之间存在以下几种常见的关系：

正确答案: A B C  你的答案: B C D (错误)

A “USES-A”关系
B “HAS-A”关系
C “IS-A”关系
D “INHERIT-A”关系

> ==不存在“INHERIT-A”==
>
> **USES-A：**依赖关系，A类会用到B类，这种关系具有偶然性，临时性。但B类的变化会影响A类。这种在代码中的体现为：A类方法中的参数包含了B类。
>
> **关联关系：**A类会用到B类，这是一种强依赖关系，是长期的并非偶然。在代码中的表现为：A类的成员变量中含有B类。
>
> **HAS-A：**聚合关系，拥有关系，是**关联关系**的一种特例，是整体和部分的关系。比如鸟群和鸟的关系是聚合关系，鸟群中每个部分都是鸟。
>
> **IS-A：**表示继承。父类与子类，这个就不解释了。
>
> 要注意：还有一种关系：**组合关系**也是关联关系的一种特例，它体现一种contains-a的关系，这种关系比聚合更强，也称为强聚合。它同样体现整体与部分的关系，但这种整体和部分是不可分割的。

# 27. 在Java线程状态转换时，下列转换不可能发生的有（）？

正确答案: A C  你的答案: D (错误)

A 初始态->运行态
B 就绪态->运行态
C 阻塞态->运行态
D 运行态->就绪态

> ![7690A00F33D4E390B600FEB65D3EDE0A](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/7690A00F33D4E390B600FEB65D3EDE0A.png)

# 28. 下列说法正确的是（类内方法调用）

正确答案B，我选择的D


  A 在类方法中可用this来调用本类的类方法

  B 在类方法中调用本类的类方法时可直接调用

  C 在类方法中只能调用本类中的类方法

  D 在类方法中绝对不能调用实例方法

> D在类内可以通过new这个类调用实例方法

# 29. volatile关键字的说法错误的是

A 能保证线程安全

B volatile关键字用在多线程同步中，可保证读取的可见性

C JVM保证从主内存加载到线程工作内存的值是最新的

D volatile能禁止进行指令重排序

正确答案：A 你的答案：D

> 官方解析：
>
> A选项：volatile单纯使用不能保证线程安全，他只是提供了一种弱的同步机制来确保修饰的变量的更新操作通知到其他线程，A选项说法错误
>
> B选项：对一个volatile变量的读，总是能看到（任意线程）对这个volatile变量最后的写入。B选项说法正确。
>
> C选项： 对于用volatile修饰的变量，JVM虚拟机会保证从主内存加载到线程工作内存的值是最新的，例如线程1和线程2在进行read和load的操作中，发现主内存中某个变量的值都是5，那么都会加载这个最新的值。这也是可见性的一种体现。C选项说法正确。
>
> D选项：volatile的底层是采用内存屏障来实现的，就是在编译器生成字节码时，会在指令序列中插入内存屏障来禁止特定类型的处理器重排序。D选项说法正确。
>
> 综上所述，答案选择A

# 30. 关于运行时常量池，下列哪个说法是正确的

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

# 31. 下列哪个选项是Java调试器？如果编译器返回程序代码的错误，可以用它对程序进行调试。

A java

B javadoc

C jdb

D javaprof

> java.exe是java虚拟机 
>
> javadoc.exe用来制作java文档 
>
> jdb.exe是java的调试器 
>
> javaprof.exe是剖析工具

# 32. 在Java中，以下数据类型中,需要内存最多的是()

正确答案: B  你的答案: C (错误)

A byte
B long
C Object
D int

> Object 是引用数据类型，只申明而不创建实例，只会在栈内存中开辟空间，默认为空，空占1 bit.

# 33. 以下代码执行后输出结果为（包含main的类执行顺序）

正确答案: A  你的答案: D (错误)

A blockAblockBblockA
B blockAblockAblockB
C blockBblockBblockA
D blockBblockAblockB

> 静态块：用static申明，JVM加载类时执行，仅执行一次
> 构造块：类中直接用{}定义，每一次创建对象时执行
> 执行顺序优先级：静态块>main()>构造块>构造方法
> 静态块按照申明顺序执行，先执行Test t1 = new Test();
> 所有先输出blockA，然后执行静态块，输出blockB，最后执行main
> 方法中的Test t2 = new Test();输出blockA。

# 34. 判断对错。List，Set，Map都继承自继承Collection接口。

正确答案: B

A 对

B 错

> ![7010483_1496974867310_D5D2D67073C3D04D7B608AD94C2886F0](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/7010483_1496974867310_D5D2D67073C3D04D7B608AD94C2886F0.png)

# 35. 事务隔离级别是由谁实现的？

正确答案:C


A  Java应用程序

B  Hibernate

C  数据库系统

D  JDBC驱动程序

> A 我们写java程序的时候只是设定事物的隔离级别，而不是去实现它 
>
> B Hibernate是一个java的数据持久化框架，方便数据库的访问 
>
> C 事物隔离级别由数据库系统实现，是数据库系统本身的一个功能 
>
> D JDBC是java database connector，也就是java访问数据库的驱动

# 36. 有关finally语句块说法正确的是（ ）

正确答案: A B C  你的答案: A C D (错误)

A 不管catch是否捕获异常，finally语句块都是要被执行的
B 在try语句块或catch语句块中执行到System.exit(0)直接退出程序
C finally块中的return语句会覆盖try块中的return返回
D finally 语句块在 catch语句块中的return语句之前执行

> **如果try语句里有return，那么代码的行为如下：**
> 1.如果有返回值，就把返回值保存到局部变量中
> 2.执行jsr指令跳到finally语句里执行
> 3.执行完finally语句后，返回之前保存在局部变量表里的值
>
> **如果try，finally语句里均有return，忽略try的return，而使用finally的return.**

# 37. 以下哪些类是线程安全的（）

正确答案: A D E  你的答案: A (错误)

A Vector
B HashMap
C ArrayList
D StringBuffer
E Properties

> A，Vector相当于一个线程安全的List
>
> B，HashMap是非线程安全的，其对应的线程安全类是HashTable
>
> C，Arraylist是非线程安全的，其对应的线程安全类是Vector
>
> D，StringBuffer是线程安全的，相当于一个线程安全的StringBuilder
>
> E，Properties实现了Map接口，是线程安全的

# 38. 一般用()创建InputStream对象,表示从标准输入中获取数据,用()创建OutputStream对象，表示输出到标准输出设备中。

正确答案：A                                        

A System.in System.out

B System.out System.in

C System.io.in System.io.out

D System.io.out System.io.in    

> System.in 和 System.out 是java中的标准输入输出流，一般情况下代表从控制台输入和输出到控制台                

# 39. 以下哪个区域不属于新生代？

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

# 40. 下列流当中，属于处理流的是：（） 

正确答案：C D  

A FilelnputStream

B lnputStream

C DatalnputStream

D BufferedlnputStream

> 按照流是否直接与特定的地方（如磁盘、内存、设备等）相连，分为节点流和处理流两类。  
>
> - ​     节点流：可以从或向一个特定的地方（节点）读写数据。如FileReader.    
> - ​     处理流：是对一个已存在的流的连接和封装，通过所封装的流的功能调用实现数据读写。如BufferedReader.处理流的构造方法总是要带一个其他的流对象做参数。一个流对象经过其他流的多次包装，称为流的链接。    
>
> ​    **JAVA常用的节点流：**     
>
> - ​     文 件 FileInputStream FileOutputStrean FileReader FileWriter 文件进行处理的节点流。    
> - ​     字符串 StringReader StringWriter 对字符串进行处理的节点流。    
> - ​     数 组 ByteArrayInputStream ByteArrayOutputStreamCharArrayReader CharArrayWriter 对数组进行处理的节点流（对应的不再是文件，而是内存中的一个数组）。    
> - ​     管 道 PipedInputStream PipedOutputStream PipedReaderPipedWriter对管道进行处理的节点流。    
>
> ​    **常用处理流（关闭处理流使用关闭里面的节点流）**   
>
> - ​     缓冲流：BufferedInputStrean BufferedOutputStream BufferedReader BufferedWriter 增加缓冲功能，避免频繁读写硬盘。    
>
> - ​     转换流：InputStreamReader OutputStreamReader 实现字节流和字符流之间的转换。    
> - ​     数据流 DataInputStream DataOutputStream 等-提供将基础数据类型写入到文件中，或者读取出来.    
>
> ###     流的关闭顺序   
>
> 1. ​     一般情况下是：先打开的后关闭，后打开的先关闭    
> 2. ​     另一种情况：看依赖关系，如果流a依赖流b，应该先关闭流a，再关闭流b。例如，处理流a依赖节点流b，应该先关闭处理流a，再关闭节点流b    
> 3. ​     可以只关闭处理流，不用关闭节点流。处理流关闭的时候，会调用其处理的节点流的关闭方法。

# 41. 关于 Socket 通信编程，以下描述错误的是：（ ）

正确答案：D

A 服务器端通过new ServerSocket()创建TCP连接对象
B 服务器端通过TCP连接对象调用accept()方法创建通信的Socket对象
C 客户端通过new Socket()方法创建通信的Socket对象
D 客户端通过new ServerSocket()创建TCP连接对象              

> Socket套接字 
>
> 就是源Ip地址，目标IP地址，源端口号和目标端口号的组合 
>
> 服务器端：ServerSocket提供的实例 
>
> ServerSocket server= new ServerSocket(端口号) 
>
> 客户端：Socket提供的实例 
>
> Socket soc=new Socket(ip地址，端口号)

# 42. Which lines of the following will produce an error?(Java数据默认类型)



```java
bytea1 = 2, a2 = 4, a3;
shorts = 16;
a2 = s;
a3 = a1 * a2;
```


正确答案: A  你的答案: D (错误)

A Line 3 and Line 4
B Line 1 only
C Line 3 only
D Line 4 only

> 数值型变量在默认情况下为Int型，byte和short型在计算时会自动转换为int型计算，结果也是int 型。所以a1*a2的结果是int型的。

# 43. 下列Java代码中的变量a、b、c分别在内存的____存储区存放。
```java
class A {
    private String a = “aa”;
    public boolean methodB() {
        String b = “bb”;
        final String c = “cc”;
    }
}
```
  A 堆区、堆区、堆区
  B 堆区、栈区、堆区
  C 堆区、栈区、栈区
  D 堆区、堆区、栈区
  E 静态区、栈区、堆区
  F 静态区、栈区、栈区

> 堆区：只存放类对象，线程共享；
>
> 方法区：又叫静态存储区，存放class文件和静态数据，线程共享;
>
> 栈区：存放方法局部变量，基本类型变量区、执行环境上下文、操作指令区，线程不共享;

# 44. 有关线程的哪些叙述是对的（）     

#                                 

正确答案：B C D
A 一旦一个线程被创建，它就立即开始运行。
B 使用start()方法可以使一个线程成为可运行的，但是它不一定立即开始运行。
C 当一个线程因为抢先机制而停止运行，它可能被放在可运行队列的前面。
D 一个线程可能因为不同的原因停止并进入就绪状态。

> 我自己最开始的时候只选了BD没选C。看评论里面也对C存疑，通过书籍查证C是可以选的。 
>
>   在抢先式系统下，由高优先级的线程参与调度。分为2种情况： 
>
>   1.若多个线程都处于就绪状态，则具有高优先级的线程会在低优先级之前得到执行；
>
>   2.在当前线程的运行过程中，如果有较高级别的线程准备就绪，则正在运行的较低级别的线程将被挂起，转到较高级别的线程运行，直到结束后又会转到原来被挂起的线程。 
>
>   第二种情况就描述了C所代表的情况，可以看到当较高级别的线程抢去运行权并运行完成之后，是先将权利转给原来的线程的，所以C是正确的。                     

# 45. 代码片段：（final修饰变量不可再转换类型）

```java
byte b1=1,b2=2,b3,b6;  
final byte b4=4,b5=6;  
b6=b4+b5;  
b3=(b1+b2);  
System.out.println(b3+b6);
```

关于上面代码片段叙述正确的是（） 

正确答案 C

A 输出结果：13

B 语句：b6=b4+b5编译出错

C 语句：b3=b1+b2编译出错

D 运行期抛出异常

> 被final修饰的变量是常量，是最终类型，这里的b6=b4+b5可以看成是b6=10；在编译时就已经变为b6=10了 
>
> 而b1和b2是byte类型，java中进行计算时候将他们提升为int类型，再进行计算，b1+b2计算后已经是int类型，赋值给b3，b3是byte类型，类型不匹配，编译不会通过，需要进行强制转换。 
>
> Java中的byte，short，char进行计算时都会提升为int类型。

# 46. 要导入java/awt/event下面的所有类，叙述正确的是？()

正确答案:C

A import java.awt.*和import java.awt.event.*都可以
B 只能是import java.awt.*
C 只能是import java.awt.event.*
D import java.awt.*和import java.awt.event.*都不可以

> 导包只可以导到当前层，不可以再导入包里面的包中的类

# 47. java语言的下面几种数组复制方法中，哪个效率最高？

正确答案:B

A for 循环逐一复制
B System.arraycopy
C Array.copyOf
D 使用clone方法

> System.arraycopy()：native方法+JVM手写函数，在JVM里预写好速度最快   
>
> clone()：native方法，但并未手写，需要JNI转换，速度其次   
>
> Arrays.copyof()：本质是调用1的方法   
>
> for()：全是深复制，并且不是封装方法，最慢情有可原
>
> **效率：System.arraycopy > clone > Arrays.copyOf > for循环**

# 48. Which method you define as the starting point of new thread in a class from which n thread can be execution?


下列哪一个方法你认为是新线程开始执行的点，也就是从该点开始线程n被执行。 

A public void start()
B public void run()
C public void int()
D public static void main(String args[])
E public void runnable()

> 题目的意思是，下列哪一个方法你认为是新线程开始执行的点，也就是从该点开始线程n被执行。
> 了解过线程的知识我们知道：
> start()方法是启动一个线程，此时的线程处于就绪状态，但并不一定就会执行，还需要等待CPU的调度。
> run()方法才是线程获得CPU时间，开始执行的点。

# 49. 下面几个关于Java里queue的说法哪些是正确的（）？

正确答案: A C  你的答案: B C D (错误)

A LinkedBlockingQueue是一个可选有界队列，不允许null值
B PriorityQueue，LinkedBlockingQueue都是线程不安全的
C PriorityQueue是一个无界队列，不允许null值，入队和出队的时间复杂度是O（log(n)）
D PriorityQueue，ConcurrentLinkedQueue都遵循FIFO原则

> - ArrayBlockingQueue：基于数组，在创建ArrayBlockingQueue对象时必须制定容量大小，先进先出队列，有界队列，容量有上限。      
> - LinkedBlockingQueue：基于链表，在创建LinkedBlockingQueue对象时如果不指定容量大小，默认大小为Integer.MAX_VALUE，先进先出队列，有界队列，容量有上限。
> - PriorityBlockingQueue：按照元素的优先级对元素进行排序，按照优先级顺序出队，每次出队的元素都是优先级最高的元素。注意，此阻塞队列为无界阻塞队列，即容量没有上限。
>
> blocking queue说明：不接受null元素；可能是容量有限的；实现被设计为主要用于生产者 - 消费者队列；不支持任何类型的“关闭”或“关闭”操作，表示不再添加项目实现是线程安全的；

# 50. 以下选项中，合法的**赋值**语句是（）

正确答案: B,我的答案：C

A a>1;
B i++;
C a = a+1=5;
D y = int(i);

> ![5405625_1527164035805_CAAD68FC10A3980D447E333B567B643F](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/5405625_1527164035805_CAAD68FC10A3980D447E333B567B643F.png)

# 51. 以下哪些方法是Object类中的方法

正确答案：A B C D

A clone()
B toString()
C wait()
D finalize()

> ![330581894_1566056683581_BCF7AE6ECD3CE4E58BE8D9E8DB25E169](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/330581894_1566056683581_BCF7AE6ECD3CE4E58BE8D9E8DB25E169.png)

# 52.给出以下代码,请给出结果(方法传递的是值而不是地址)

```java
class Two{
    Byte x;
}
class PassO{
    public static void main(String[] args){
        PassO p=new PassO();
        p.start();
    }
    void start(){
        Two t=new Two();
        System.out.print(t.x+””);
        Two t2=fix(t);
        System.out.print(t.x+” ” +t2.x);
    }
    Two fix(Two tt){
        tt.x=42;
        return tt;
    }
}
```

A null null 42
B null 42 42
C 0 0 42
D 0 42 42
E An exception is thrown at runtime
F Compilation

> `Byte`是包装类，当`fix`方法调用时，传入的是`t`实例的值，但是方法中使用的`t.x`是它的地址值。
>
> 当修改`t`中的`x`时，其内存指向的部分被修改，所以`t`和`t2`的`x`在调用后均为`42`

# 53. 以下代码执行的结果显示是多少（ ）？

![image-20240423081628869](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240423081628869.png)


A true,false,true

B false,true,false

C true,true,false

D false,false,true

正确答案：D

> 对于-128到127之间的数，Java会对其进行缓存
>
> String s = "abc"：通过字面量赋值创建字符串。则将栈中的引用直接指向该字符串，如不存在，则在常量池中生成一个字符串，再将栈中的引用指向该字符串 
>
> String s = “a”+“bc”：编译阶段会直接将“a”和“bc”结合成“abc”，这时如果方法区已存在“abc”，则将s的引用指向该字符串，如不存在，则在方法区中生成字符串“abc”对象，然后再将s的引用指向该字符串 
>
> String s = "a" + new String("bc"):栈中先创建一个"a"字符串常量，再创建一个"bc"字符串常量，编译阶段不会进行拼接，在运行阶段拼接成"abc"字符串常量并将s的引用指向它，效果相当于String s = new String("abc")，只有'+'两边都是字符串常量才会在编译阶段优化

# 54. 下面论述正确的是（关于hashcode和equal）？

正确答案D

A 如果两个对象的hashcode相同，那么它们作为同一个HashMap的key时，必然返回同样的值
B 如果a,b的hashcode相同，那么a.equals(b)必须返回true
C 对于一个类，其所有对象的hashcode必须不同
D 如果a.equals(b)返回true，那么a,b两个对象的hashcode必须相同

> 当两个对象的hashCode相同，但它们实际上不相等（即它们的equals方法返回false）时，它们可以作为HashMap的不同的键存在。在这种情况下，它们可以关联到HashMap中的不同的值。
>
> hashCode()方法和equals()方法的作用其实是一样的，在Java里都是用来对比两个对象是否相等一致。
>
> ***那么equals()既然已\******经\******能\******实现\******对\******比的功能了，为什么还要hashCode()呢？\***因为重写的equals()里一般比较的比较全面比较复杂，这样效率就比较低，而利用hashCode()进行对比，则只要生成一个hash值进行比较就可以了，效率很高。*
>
> ***那么hashCode()既然效率这么高为什么还要equals()呢***？ 因为hashCode()并不是完全可靠，有时候不同的对象他们生成的hashcode也会一样（生成hash值得公式可能存在的问题），所以hashCode()只能说是大部分时候可靠，并不是绝对可靠，  
>
> **所以我们可以得出：**  
>
>    **1.equals()相等的两个对象他们的hashCode()肯定相等，也就是用equals()对比是绝对可靠的。**  
>
>    **2.hashCode()相等的两个对象他们的equal()不一定相等，也就是hashCode()不是绝对可靠的。**

# 55. socket编程中，以下哪个socket的操作是不属于服务端操作的（）？

正确答案:C

A accept
B recieve
C getInputStream
D close

> ![8955099_1521189690989_0BB28C2A1ECCC47EC020E89E8A554BBC](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/8955099_1521189690989_0BB28C2A1ECCC47EC020E89E8A554BBC.png)

# 56. 下面有关Java的说法正确的是（）        

​                    

正确答案：A C D E F  

A  一个类可以实现多个接口

B 抽象类必须有抽象方法

C protected成员在子类可见性可以修改

D 通过super可以调用父类构造函数

E final的成员方法实现中只能读取类的成员变量

F String是不可修改的，且java运行环境中对string对象有一个常量池保存

> A对：java类单继承，多实现
> B错：被abstract修饰的类就是抽象类，有没有抽象方法无所谓
> C错：描述有问题。protected成员在子类的可见性，我最初理解是子类（不继承父类protected成员方法）获取父类被protected修饰的成员属性或方法，可见性是不可能变的，因为修饰符protected就是描述可见性的。
> 这道题应该是要考察子类继承父类，并重写父类的protected成员方法，该方法的可见性可以修改，这是对的，因为子类继承父类的方法，访问权限可以相同或往大了改 
> D对。
> E错：final修饰的方法只是不能重写，static修饰的方法只能访问类的成员变量
> F对。

# 57. 以下程序段的输出结果为：（包装类相关）

正确答案:B

```java
public class EqualsMethod
{
    public static void main(String[] args)
    {
        Integer n1 = new Integer(47);
        Integer n2 = new Integer(47);
        System.out.print(n1 == n2);
        System.out.print(",");
        System.out.println(n1 != n2);
    }
}

```


A false，false

B false，true

C true，false

D true，true

> 使用Integer a = 1;或Integer a = Integer.valueOf(1);  在值介于-128至127直接时，作为基本类型。 
>
> 使用Integer a = new Integer(1); 时，无论值是多少，都作为对象。

# 58. JVM内存不包含如下哪个部分(待学习)

正确答案：D

A Stacks
B PC寄存器
C Heap
D Heap Frame

> ![272084FEBFF2E659FA20DF7ACF52DD13](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/272084FEBFF2E659FA20DF7ACF52DD13.png)

# 59. 执行以下程序后的输出结果是（StringBuffer相关）

```java
public class Test {
    public static void main(String[] args) {
        StringBuffer a = new StringBuffer("A"); 
        StringBuffer b = new StringBuffer("B"); 
        operator(a, b); 
        System.out.println(a + "," + b); 
    } 
    public static void operator(StringBuffer x, StringBuffer y) { 
        x.append(y); y = x; 
    }
}
```
正确答案：D
A  A,A
B  A,B
C  B,B
D  AB,B

> StringBuffer传的是引用，String传的是值
>
> x.append(y),将x指向的内容后添加了"B"，a中的指向的内容更改
>
> y = x,将y指向了x，b中指向的内容并未更改

# 60. 下面有关 Java ThreadLocal 说法正确的有？

正确答案：A B C D 

A ThreadLocal存放的值是线程封闭，线程间互斥的，主要用于线程内共享一些数据，避免通过参数来传递
B 线程的角度看，每个线程都保持一个对其线程局部变量副本的隐式引用，只要线程是活动的并且 ThreadLocal 实例是可访问的；在线程消失之后，其线程局部实例的所有副本都会被垃圾回收
C 在Thread类中有一个Map，用于存储每一个线程的变量的副本。
D 对于多线程资源共享的问题，同步机制采用了“以时间换空间”的方式，而ThreadLocal采用了“以空间换时间”的方式

> ThreadLocal类用于创建一个线程本地变量
> 在Thread中有一个成员变量ThreadLocals，该变量的类型是ThreadLocalMap,也就是一个Map，它的键是threadLocal，值就是变量的副本，ThreadLocal为每一个使用该变量的线程都提供了一个变量值的副本，每一个线程都可以独立地改变自己的副本，是线程隔离的。通过ThreadLocal的get()方法可以获取该线程变量的本地副本，在get方法之前要先set,否则就要重写initialValue()方法。
> ThreadLocal不是用来解决对象共享访问问题的，而主要是提供了保持对象的方法和避免参数传递的方便的对象访问方式。一般情况下，通过ThreadLocal.set() 到线程中的对象是该线程自己使用的对象，其他线程是不需要访问的，也访问不到的。各个线程中访问的是不同的对象。

# 61. 执行完以下代码 int [ ] x = new int[10] ；后，以下哪项说明是正确的（ ）

正确答案：A

A x[9]为0
B x[9]未定义
C x[10]为0
D x[0]为空

> **数组引用类型的变量的默认值为 null。当数组变量的实例后，如果没有没有显示的为每个元素赋值，Java 就会把该数组的所有元素初始化为其相应类型的默认值。**
>
> **int型的默认值为0**

# 62. 以下描述错误的一项是（ JVM内存 ）？

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

# 63. 一个容器类数据结构，读写平均，使用锁机制保证线程安全。如果要综合提高该数据结构的访问性能，最好的办法是______。  

正确答案：C                                      

A 只对写操作加锁，不对读操作加锁

B 读操作不加锁，采用copyOnWrite的方式实现写操作

C 分区段加锁

D 无法做到                   

> A，只对写操作加锁，不对读操作加锁，会造成读到脏数据 
>
> B，CopyOnWrite的核心思想是利用高并发往往是读多写少的特性，对读操作不加锁，对写操作，先复制一份新的集合，在新的集合上面修改，然后将新集合赋值给旧的引用。这里读写平均，不适用
>
> C，分段加锁，只在影响读写的地方加锁，锁可以用读写锁，可以提高效率

# 64. 以下说法错误的是（泛型相关）

正确答案：D
A 虚拟机中没有泛型，只有普通类和普通方法
B 所有泛型类的类型参数在编译时都会被擦除
C 创建泛型对象时请指明类型，让编译器尽早的做参数检查
D 泛型的类型擦除机制意味着不能在运行时动态获取List<T>中T的实际类型

> 1. 创建泛型对象的时候，一定要指出类型变量T的具体类型。争取让编译器检查出错误，而不是留给JVM运行的时候抛出类不匹配的异常。 
>
> 2. JVM如何理解泛型概念 —— 类型擦除。事实上，JVM并不知道泛型，所有的泛型在编译阶段就已经被处理成了普通类和方法。 处理方法很简单，我们叫做类型变量T的擦除(erased) 。  
>
> 3. 总结：泛型代码与JVM      
>
>    1. 虚拟机中没有泛型，只有普通类和方法。 
>
>    2. 在编译阶段，所有泛型类的类型参数都会被Object或者它们的限定边界来替换。(类型擦除)     
>
>    3. 在继承泛型类型的时候，桥方法的合成是为了避免类型变量擦除所带来的多态灾难。     
>
>    4. 无论我们如何定义一个泛型类型，相应的都会有一个原始类型被自动提供。原始类型的名字就是擦除类型参数的泛型类型的名字。
>
>       泛型擦除意味着在运行时无法通过class.getTypeParameters()获得类型参数；但是可以通过擦除补偿机制来保存泛型参数类型，比如Class<T>,Class/Method/Filed的signature属性。

# 65.关于Java内存区域下列说法不正确的有哪些(JVM内存待学习)  

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

# 66. 关于Java中的数组，下面的一些描述，哪些描述是准确的：（  ）

正确答案: A C F  你的答案: A C D E F (错误)

A 数组是一个对象，不同类型的数组具有不同的类
B 数组长度是可以动态调整的
C 数组是一个连续的存储结构
D　一个固定长度的数组可类似这样定义: int array[100]
E 两个数组用equals方法比较时，会逐个遍历其中的元素，对每个元素进行比较
F 可以二维数组，且可以有多维数组，都是在Java中合法的

> ![img](https://uploadfiles.nowcoder.com/images/20190906/200363574_1567760472632_522D5A4C43009D74D65824C4059EE6CB)
>
> 数组是一种引用数据类型 那么他肯定是继承Object类的 所以里面有equals() 方法 但是肯定没有重写过 因为他并不是比较数组内的内容 
>
> 使用Arrays.equals() 是比较两个数组中的内容。

# 67. 关于多线程和多进程，下面描述正确的是（）：   

  正确答案：A C

  A 多进程里，子进程可获得父进程的所有堆和栈的数据；而线程会与同进程的其他线程共享数据，拥有自己的栈空间。
  B 线程因为有自己的独立栈空间且共享数据，所有执行的开销相对较大，同时不利于资源管理和保护。

  C 线程的通信速度更快，切换更快，因为他们在同一地址空间内。

  D 一个线程可以属于多个进程。         

> **A.**子进程得到的是除了代码段是与父进程共享以外，其他所有的都是得到父进程的一个副本，子进程的所有资源都继承父进程，得到父进程资源的副本，子进程可获得父进程的所有堆和栈的数据，但二者并不共享地址空间。两个是单独的进程，继承了以后二者就没有什么关联了，子进程单独运行；进程的线程之间共享由进程获得的资源，但线程拥有属于自己的一小部分资源，就是栈空间，保存其运行状态和局部自动变量的。 
>
> **B.**线程之间共享进程获得的数据资源，所以开销小，但不利于资源的管理和保护；而进程执行开销大，但是能够很好的进行资源管理和保护。 
>
> **C.**线程的通信速度更快，切换更快，因为他们共享同一进程的地址空间。 
>
> **D.**一个进程可以有多个线程，线程是进程的一个实体，是CPU调度的基本单位。          

# 68. 以下是java concurrent包下的4个类，选出差别最大的一个

A Semaphore
B ReentrantLock
C Future
D CountDownLatch

正确答案：C

> A、Semaphore：类，控制某个资源可被同时访问的个数; 
>
> B、ReentrantLock：类，具有与使用synchronized方法和语句所访问的隐式监视器锁相同的一些基本行为和语义，但功能更强大； 
>
> C、Future：接口，表示异步计算的结果；
>
> D、CountDownLatch： 类，可以用来在一个线程中等待多个线程完成任务的类。

# 69. 往OuterClass类的代码段中插入内部类声明, 哪一个是错误的:

```java
public class OuterClass{
    private float f=1.0f;
    //插入代码到这里
}
```
A class InnerClass{
public static float func(){return f;}
}
B abstract class InnerClass{
public abstract float func(){}
}
C static class InnerClass{
protected static float func(){return f;}
}
D public class InnerClass{
 static float func(){return f;}
}

正确答案：A B C D

> 1.静态内部类才可以声明静态方法
>
> 2.静态方法不可以使用非静态变量
>
> 3.抽象方法不可以有函数体



# 70. 下面有关java classloader说法错误的是? 

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

# 71. 以下哪个方法用于定义线程的执行体？

正确答案:C

A start()

B init()

C run()

D synchronized()

> start方法是开始一个线程，init()是初始化线程，使线程处于就绪状态，run()方法是线程的具体执行方法，synchronized()是锁，运行锁定阻塞，防止其他线程抢占。

# 72. 下列哪些方法是针对循环优化进行的(待学习)

A 强度削弱
B 删除归纳变量
C 删除多余运算
D 代码外提

正确答案：A B D

> 常见的代码优化技术有：复写传播，删除死代码, 强度削弱，归纳变量删除
>
> ### 复写传播:
>
> ![图片说明](https://uploadfiles.nowcoder.com/images/20190815/878899945_1565879193358_3845AC1B1009E13B758E333DABF8FAE9)
>
> - 复写语句：形式为f = g 的赋值
>   - 优化过程中会大量引入复写
>   - 复写传播变换的做法是在复写语句f = g后，尽可能用g代表f
>   - 复写传播变换本身并不是优化，但它给其他优化带来机会
>     - 常量合并（编译时可完成的计算）
>     - 死代码删除
>
> ### 死代码删除
>
> - 死代码是指计算的结果决不被引用的语句
> - 一些优化变换可能会引起死代码
>
> ### 代码外提
>
> - 代码外提是循环优化的一种
> - 循环优化的其它重要技术
>   - 归纳变量删除
>   - 强度削弱
>
> 例:
>
> ```
> while(i <= limit - 2) ...
> // 代码外提后变成
> t = limit - 2;
> while(i <= t) ...
> ```
>
> ### 归纳变量删除
>
> ```
> j = j - 1
> t4 = 4 * j
> t5 = a[t4]
> if t5 > value goto B3
> ```
>
> - j和t4的值步伐一致地变化，这样的变量叫作归纳变量
> - 在循环中有多个归纳变量时，也许只需要留下一个
> - 这个操作由归纳变量删除过程来完成
> - 对本例可以先做强度削弱，它给删除归纳变量创造机会
>
> ### 强度削弱
>
> - 强度削弱的本质是把强度大的运算换算成强度小的运算，例如将乘法换成加法运算。



# 73. 在使用super和this关键字时，以下描述错误的是（）   

正确答案：B C D                                     

A 在子类构造方法中使用super()显示调用父类的构造方法，super()必须写在子类构造方法的第一行，否则编译不通过
B super()和this()不一定要放在构造方法内第一行
C this()和super()可以同时出现在一个构造函数中
D this()和super()可以在static环境中使用，包括static方法和static语句块

> A选项正确，B选项，super()必须在第一行的原因是: 子类是有可能访问父类对象的, 比如在构造函数中使用父类对象的成员函数和变量, 在成员初始化使用了父类, 在代码块中使用了父类等等, 所以为保证在子类可以访问父类对象之前，一定要完成对父类对象的初始化。　　 关于this()必须在第一行的原因，我们假设这样一种情况,，类B是类A的子类， 如果this()可以在构造函数的任意行使用, 那么当程序运行到构造函数B()的第一行,发现没有调用this()和super()，那么就会自动在第一行补齐super() 来完成对父类对象的初始化, 然后返回子类的构造函数继续执行, 当运行到构造函数B()的"this() ;"时, 调用B类对象的构造函数, 还会对父类对象再次初始化!，这就造成了资源的浪费，以及某些意想不到的错误。也正因如此C选项错误。 
>
>   D选项，无论是this()还是super()指的都是对象，而static环境中是无法使用非静态变量的。因此D选项错误。

# 74. 下面有关值类型和引用类型描述正确的是（JVM相关）？ 

正确答案: ABCD

A 值类型的变量赋值只是进行数据复制，创建一个同值的新对象，而引用类型变量赋值，仅仅是把对象的引用的指针赋值给变量，使它们共用一个内存地址。
B 值类型数据是在栈上分配内存空间，它的变量直接包含变量的实例，使用效率相对较高。而引用类型数据是分配在堆上，引用类型的变量通常包含一个指向实例的指针，变量通过指针来引用实例。
C 引用类型一般都具有继承性，但是值类型一般都是封装的，因此值类型不能作为其他任何类型的基类。
D 值类型变量的作用域主要是在栈上分配内存空间内，而引用类型变量作用域主要在分配的堆上。

> A. 值类型的变量赋值只是进行数据复制，创建一个同值的新对象，而引用类型变量赋值，仅仅是把对象的引用的指针赋值给变量，使它们共用一个内存地址。  
>
> B. 值类型数据是在栈上分配内存空间，它的变量直接包含变量的实例，使用效率相对较高。而引用类型数据是分配在堆上，引用类型的变量通常包含一个指向实例的指针，变量通过指针来引用实例。  
>
> C. 引用类型一般都具有继承性，但是值类型一般都是封装的，因此值类型不能作为其他任何类型的基类。  
>
> D. 值类型变量的作用域主要是在栈上分配内存空间内，而引用类型变量作用域主要在分配的堆上。

# 75. 下列哪些操作会使线程释放锁资源？

A sleep()
B wait()
C join()
D yield()

正确答案：B C

> **1.sleep()方法** 
>
>   在指定时间内让当前正在执行的线程暂停执行，但不会释放“锁标志”。不推荐使用。 
>
>   sleep()使当前线程进入阻塞状态，在指定时间内不会执行。 
>
>   **2.wait()方法** 
>
>   在其他线程调用对象的notify或notifyAll方法前，导致当前线程等待。线程会释放掉它所占有的“锁标志”，从而使别的线程有机会抢占该锁。 
>
>   当前线程必须拥有当前对象锁。如果当前线程不是此锁的拥有者，会抛出IllegalMonitorStateException异常。 
>
>   唤醒当前对象锁的等待线程使用notify或notifyAll方法，也必须拥有相同的对象锁，否则也会抛出IllegalMonitorStateException异常。 
>
>   waite()和notify()必须在synchronized函数或synchronized　block中进行调用。如果在non-synchronized函数或non-synchronized　block中进行调用，虽然能编译通过，但在运行时会发生IllegalMonitorStateException的异常。 
>
>   **3.yield方法** 
>
>   暂停当前正在执行的线程对象。 
>
>   yield()只是使当前线程重新回到可执行状态，所以执行yield()的线程有可能在进入到可执行状态后马上又被执行。 
>
>   yield()只能使同优先级或更高优先级的线程有执行的机会。 
>
>   **4.join方法** 
>
>   等待该线程终止。 
>
>   等待调用join方法的线程结束，再继续执行。如：t.join();//主要用于等待t线程运行结束，若无此句，main则会执行完毕，导致结果不可预测。
>
> join内部调用的是wait方法
>
> ![495010940_1562147338837_CA90DF9A61C1D798EDAFFF96726FC437](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/495010940_1562147338837_CA90DF9A61C1D798EDAFFF96726FC437.png)

# 76. 以下代码段执行后的输出结果为

```java
public class Test {
    public static void main(String[] args) {
        System.out.println(test());

    }
    private static int test() {
        int temp = 1;
        try {
            System.out.println(temp);
            return ++temp;
        } catch (Exception e) {
            System.out.println(temp);
            return ++temp;
        } finally {
            ++temp;
            System.out.println(temp);
        }
    }
}
```

A 1,2,2
B 1,2,3
C 1,3,3
D 1,3,2

正确答案：D

> finally代码块在return中间执行。return的值会被放入临时空间，然后执行finally代码块，如果finally中有return，会刷新临时空间的值，方法结束返回临时空间值。

# 77. Java的Daemon线程，setDaemon( )设置必须要？

A 在start之前
B 在start之后
C 前后都可以

正确答案：A

> 中线程分为两种类型： 
>
> 1：用户线程。通过Thread.setDaemon(false)设置为用户线程； 
>
> 2：守护线程。通过Thread.setDaemon(true)设置为守护线程，如果不设置，默认用户线程； 
>
> 守护线程是服务用户线程的线程，在它启动之前必须先set。

# 78. 以下类型为Final类型的为（）

A HashMap
B StringBuffer
C String
D Hashtable

正确答案：B C

> 通过阅读源码可以知道，string与stringbuffer都是通过字符数组实现的。 
>
> 其中string的字符数组是final修饰的，所以字符数组不可以修改。 
>
> stringbuffer的字符数组没有final修饰，所以字符数组可以修改。 
>
> string与stringbuffer都是final修饰，只是限制他们所存储的引用地址不可修改。 
>
> 至于地址所指内容能不能修改，则需要看字符数组可不可以修改。

# 79. java8中，下面哪个类用到了解决哈希冲突的开放定址法 

A LinkedHashSet
B HashMap
C ThreadLocal
D TreeMap

正确答案：C

> ThreadLocalMap使用开放定址法解决hash冲突，HashMap使用链地址法解决hash冲突。

# 80. 运行代码，输出的结果是（父子类加载顺序）

```java
public class P {
    public static int abc = 123;
    static{
        System.out.println("P is init");
    }
}
public class S extends P {
    static{
        System.out.println("S is init");
    }
}
public class Test {
    public static void main(String[] args) {
        System.out.println(S.abc);
    }
}
```

A P is init<br /123
B S is init<br /P is init<br /123
C P is init<br /S is init<br /123
D S is init<br /123

> 不会初始化子类的几种
>
> 1. 调用的是父类的static方法或者字段
>
> 2.调用的是父类的final方法或者字段
>
> 3. 通过数组来引用

# 81. Java数据库连接库JDBC用到哪种设计模式?

A 生成器
B 桥接模式
C 抽象工厂
D 单例模式
> JDBC连接 [数据库](https://gw-c.nowcoder.com/api/sparta/jump/link?link=http://www.2cto.com/database/) 的时候，在各个数据库之间进行切换，基本不需要动太多的代码，甚至丝毫不动，原因就是JDBC提供了统一接口，每个数据库提供各自的实现，用一个叫做数据库驱动的程序来桥接就行了

# 82. 以下JAVA程序的运行结果是什么( )

```java
public static void main(String[] args) {
    Object o1 = true ? new Integer(1) : new Double(2.0);
    Object o2;
    if (true) {
    o2 = new Integer(1);
    } else {
        o2 = new Double(2.0);
    }
    System.out.print(o1);
    System.out.print(" ");         
    System.out.print(o2);
}
```

A 1 1
B 1.0 1.0
C 1 1.0
D 1.0 1

> ```java
> byte b = 1;
> char c = 1;
> short s = 1;
> int i = 1;
> 
> // 三目，一边为byte另一边为char，结果为int
> // 其它情况结果为两边中范围大的。适用包装类型
> i = true ? b : c; // int
> b = true ? b : b; // byte
> s = true ? b : s; // short
> 
> // 表达式，两边为byte,short,char，结果为int型
> // 其它情况结果为两边中范围大的。适用包装类型
> i = b + c; // int
> i = b + b; // int
> i = b + s; // int
> 
> // 当 a 为基本数据类型时，a += b，相当于 a = (a) (a + b)
> // 当 a 为包装类型时， a += b 就是 a = a + b
> b += s; // 没问题
> c += i; // 没问题
> 
> // 常量任君搞，long以上不能越
> b = (char) 1 + (short) 1 + (int) 1; // 没问题
> // i = (long) 1 // 错误
> ```
>
> 

# 83. 关于中间件特点的描述.不正确的是（） 
正确答案：A     
A 中间件运行于客户机/服务器的操作系统内核中，提高内核运行效率
B 中间件应支持标准的协议和接口
C 中间件可运行于多种硬件和操作系统平台上
D 跨越网络,硬件，操作系统平台的应用或服务可通过中间件透明交互

> 中间件是一种独立的系统软件或服务程序，分布式应用软件借助这种软件在不同的技术之间共享资源。中间件位于客户机服务器的`操作系统`之上，管理计算机资源和网络通讯。是连接两个独立应用程序或独立系统的软件。相连接的系统，即使它们具有不同的接口，但通过中间件相互之间仍能交换信息。执行中间件的一个关键途径是信息传递。通过中间件，应用程序可以工作于多平台或OS环境。  
>
> （简单来说，中间件并不能提高内核的效率，一般只是负责网络信息的分发处理）  
>
>  中间件特点的描述：
>
> 1. 中间件应支持标准的协议和接口
> 2. 中间件可运行于多种硬件和操作系统平台上
> 3. 跨越网络,硬件，操作系统平台的应用或服务可通过中间件透明交互
>
> ​                  

# 84. 以下那些代码段能正确执行(关于+=类型转换) 

正确答案：C D  


A
 ```
  public static void main(String args[]) {
  byte a = 3;
  byte b = 2;
  b = a + b;
  System.out.println(b);
  }
 ```
B
 ```
  public static void main(String args[]) {
  byte a = 127;
  byte b = 126;
  b = a + b;
  System.out.println(b);
  }
 ```
C
 ```
  public static void main(String args[]) {
  byte a = 3;
  byte b = 2;
  a+=b;
  System.out.println(b);
  }
 ```
D
 ```
  public static void main(String args[]) {
  byte a = 127;
  byte b = 127;
  a+=b;
  System.out.println(b);
  }
 ```

> byte类型的变量在做运算时被会转换为int类型的值，故A、B左为byte，右为int，会报错；而C、D语句中用的是a+=b的语句，此语句会将被赋值的变量自动强制转化为相对应的类型。
>
> A、B选项需要加强转(byte)
>
> C、D选项中的+=会自动进行强转，相当于加了(byte)；

# 85.下面代码运行结果是

```java
class Value{
    public int i=15;
}
public class Test{
    public static void main(String argv[]){
        Test t=new Test( );
        t.first( );
    }

    public void first( ){
        int i=5;
        Value v=new Value( );
        v.i=25;
        second(v,i);
        System.out.println(v.i);
    }

    public void second(Value v,int i){
        i = 0;
        v.i = 20;
        Value val = new Value( );
        v = val;
        System.out.println(v.i+" "+i);
    }
}
```

A 15 0 20
B 15 0 15
C 20 0 20
D 0 15 20

> 这题选A，考察的是值传递与引用传递，Java中原始数据类型都是值传递，传递的是值得副本，形参的改变不会影响实际参数的值， 引用传递传递的是引用类型数据，包括String,数组，列表, map,类对象等类型，形参与实参指向的是同一内存地址，因此形参改变会影响实参的值。



# 86. final、finally和finalize的区别中，下述说法正确的有？


正确答案：A B C                                         

A final用于声明属性，方法和类，分别表示属性不可变，方法不可覆盖，类不可继承。
B finally是异常处理语句结构的一部分，表示总是执行。
C finalize是Object类的一个方法，在垃圾收集器执行的时候会调用被回收对象的此方法，可以覆盖此方法提供垃圾收集时的其他资源的回收，例如关闭文件等。
D 引用变量被final修饰之后，不能再指向其他对象，它指向的对象的内容也是不可变的。

> **A，D考的一个知识点，final修饰变量，变量的引用（也就是指向的地址）不可变，但是引用的内容可以变（地址中的内容可变）。**  
>
> **B，finally表示总是执行。但是其实finally也有不执行的时候，但是这个题不要扣字眼。**  
>
> **1. 在try中调用System.exit(0)，强制退出了程序，finally块不执行。**  
>
> 2. 在进入try块前，出现了异常，finally块不执行。
>     
>
> **C，finalize方法，这个选项错就错在，这个方法一个对象只能执行一次，只能在第一次进入被回收的队列，而且对象所属于的类重写了finalize方法才会被执行。第二次进入回收队列的时候，不会再执行其finalize方法，而是直接被二次标记，在下一次GC的时候被GC。**  

# 87. 以下说法错误的是（）

A 其他选项均不正确
B java线程类优先级相同
C Thread和Runnable接口没有区别
D 如果一个类继承了某个类，只能使用Runnable实现线程

> D 实现多线程的三种方式，一种是继承Thread类使用此方式就不能继承其他的类了。还有两种是实现Runnable接口或者实现Callable接口

# 88. 说明输出结果(获取类名相关)

正确答案：C

```java
import java.util.Date;  
public class SuperTest extends Date{  
    private static final long serialVersionUID = 1L;  
    private void test(){  
       System.out.println(super.getClass().getName());  
    }  
     
    public static void main(String[]args){  
       new SuperTest().test();  
    }  
}  
```

A SuperTest
B SuperTest.class
C test.SuperTest
D test.SuperTest.class

> TestSuper和Date的getClass都没有重写，他们都是调用Object的getClass，而Object的getClass作用是返回的是运行时的类的名字。
>
> 这个运行时的类就是当前类，所以`super.getClass().getName()` 返回的是test.SuperTest，与Date类无关
>
> 要返回Date类的名字需要写super.getClass().getSuperclass()

# 89. 下面有关SPRING的事务传播特性，说法错误的是？

正确答案：B                                       

A PROPAGATION_SUPPORTS：支持当前事务，如果当前没有事务，就以非事务方式执行
B PROPAGATION_REQUIRED：支持当前事务，如果当前没有事务，就抛出异常
C PROPAGATION_REQUIRES_NEW：新建事务，如果当前存在事务，把当前事务挂起
D PROPAGATION_NESTED：支持当前事务，新增Savepoint点，与当前事务同步提交或回滚

> PROPAGATION_REQUIRED--支持当前事务，如果当前没有事务，就新建一个事务。这是最常见的选择。 
>
> PROPAGATION_SUPPORTS--支持当前事务，如果当前没有事务，就以非事务方式执行。 
> PROPAGATION_MANDATORY--支持当前事务，如果当前没有事务，就抛出异常。 
> PROPAGATION_REQUIRES_NEW--新建事务，如果当前存在事务，把当前事务挂起。 
> PROPAGATION_NOT_SUPPORTED--以非事务方式执行操作，如果当前存在事务，就把当前事务挂起。 
> PROPAGATION_NEVER--以非事务方式执行，如果当前存在事务，则抛出异常。

# 90. 下面代码输出是？（枚举相关）

```java
enum AccountType
{
    SAVING, FIXED, CURRENT;
    private AccountType()
    {
        System.out.println("It is a account type");
    }
}
class EnumOne
{
    public static void main(String[]args)
    {
        System.out.println(AccountType.FIXED);
    }
}
```

A 编译正确，输出”It is a account type”once followed by”FIXED”
B 编译正确，输出”It is a account type”twice followed by”FIXED”
C 编译正确，输出”It is a account type”thrice followed by”FIXED”
D 编译正确，输出”It is a account type”four times followed by”FIXED”
E 编译错误

> 答案：C
>
> 枚举类有三个实例，故调用三次构造方法，打印三次It is a account type
