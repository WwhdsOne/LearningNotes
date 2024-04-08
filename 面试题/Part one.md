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

# 4. 以下哪种方式实现的单例是线程安全的（待学习）

正确答案: A B C D  你的答案: B C (错误)

A 枚举
B 静态内部类
C 双检锁模式
D 饿汉式

>
>
>...

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
>     public static void print() {         
>         System.out.println("Hello World!");      
>     }
> }
> ```
>
> PS：
>
> 在JDK1.7，接口中只包含抽象方法，使用public abstract 修饰。
>
> ```java
> public interface Demo{
>     public abstract void method();
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
>     //默认方法
>     public default void method(){
>         System.out.println("default method...");
>     }
>     //静态方法
>     public static void print(){
>         System.out.println("static method...");
>     }
> }
> ```
>
> 在JDK1.9，接口中新加了私有方法，使用private修饰，私有方法供接口内的默认方法调用。
>
> ```java
> public interface Demo{
>     private void method() {
>         System.out.println("Hello World!");
>     }
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

