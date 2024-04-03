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
