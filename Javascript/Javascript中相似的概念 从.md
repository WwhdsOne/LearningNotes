# Rest语法 和 Spread语法

Rest语法让函数可以在调用时传入任意数量参数

Rest语法使用如下：

```javascript
function sumAll(...args) { // 数组名为 args
    let sum = 0;

    for (let arg of args) sum += arg;

    return sum;
}

alert( sumAll(1) ); // 1
alert( sumAll(1, 2) ); // 3
alert( sumAll(1, 2, 3) ); // 6
```

:heavy_exclamation_mark:**Rest 参数必须放到参数列表的末尾**

Rest 参数会收集剩余的所有参数，因此下面这种用法没有意义，并且会导致错误：

```javascript
function f(arg1, ...rest, arg2) { // arg2 在 ...rest 后面？！
    // error
}
```

`...rest` 必须写在参数列表最后。

Spread语法与Rest语法作用相反，他的作用是将数组对象中的内容展开到函数中

例子如下：

```javascript
let arr = [3, 5, 1];

alert( Math.max(...arr) ); // 5（spread 语法把数组转换为参数列表）
```

当我们在代码中看到 `"..."` 时，它要么是 rest 参数，要么是 spread 语法。

有一个简单的方法可以区分它们：

- 若 `...` 出现在函数参数列表的最后，那么它就是 rest 参数，它会把参数列表中剩余的参数收集到一个数组中。
- 若 `...` 出现在函数调用或类似的表达式中，那它就是 spread 语法，它会把一个数组展开为列表。

使用场景：

- Rest 参数用于创建可接受任意数量参数的函数。
- Spread 语法用于将数组传递给通常需要含有许多参数的函数。

# ...args 和 arguments

`arguments`和`...args`（剩余参数）都是在JavaScript函数中使用的，用于处理函数的参数，但它们的工作方式有所不同。

1. `arguments`：这是一个类数组对象，它包含了函数调用时传递给函数的所有参数。`arguments`对象不是一个真正的数组，所以它没有数组的方法，如`push`、`pop`或`forEach`。`arguments`在所有函数中都可用，不仅仅是在箭头函数中。

   ```javascript
   function testArguments() {
   
       console.log(arguments[0]); // 输出 "first"
   
       console.log(arguments[1]); // 输出 "second"
   
       console.log(arguments.length); // 输出 2
   
   }
   
   testArguments('first', 'second');
   ```

2. `...args`（剩余参数）：这是ES6引入的一个新特性，它将一个不定数量的参数表示为一个数组。与`arguments`不同，`...args`是一个真正的数组，所以你可以在它上面使用所有的数组方法。`...args`只能在函数的最后一个参数中使用。

   ```javascript
   function testRestParameters(...args) {
   
       console.log(args[0]); // 输出 "first"
   
       console.log(args[1]); // 输出 "second"
   
       console.log(args.length); // 输出 2
   
   }
   ```

   testRestParameters('first', 'second');

   总的来说，`...args`（剩余参数）是一个更现代的、更强大的方式来处理函数的参数，它提供了比`arguments`更多的功能和更好的可读性。

# func.apply 和 func.call

1. `func.apply`：这个方法接受两个参数。第一个参数是要绑定到`this`的值，第二个参数是一个数组，数组中的元素将作为参数传递给函数。

   ```javascript
   function greet(name, age) {
   
       console.log(`Hello, my name is ${name} and I am ${age} years old.`);
   
   }
   
   greet.apply(null, ['John', 25]); // 输出 "Hello, my name is John and I am 25 years old."
   ```

   在这个例子中，`greet.apply(null, ['John', 25])`调用了`greet`函数，`this`被绑定到`null`，`'John'`和`25`作为参数传递给`greet`函数。

2. `func.call`：这个方法接受一个或多个参数。第一个参数是要绑定到`this`的值，后面的参数将作为参数传递给函数。

   ```javascript
   function greet(name, age) {
     console.log(`Hello, my name is ${name} and I am ${age} years old.`);
   }
   
   greet.call(null, 'John', 25); // 输出 "Hello, my name is John and I am 25 years old."
   ```

   在这个例子中，`greet.call(null, 'John', 25)`调用了`greet`函数，`this`被绑定到`null`，`'John'`和`25`作为参数传递给`greet`函数。

   总的来说，`func.apply`和`func.call`的主要区别在于如何传递参数：`func.apply`接受一个参数数组，而`func.call`接受一个参数列表。

# prototype 和 [[Prototype]] 和 \__proto__   

1. `prototype`：这是函数的一个属性。每个函数都有一个`prototype`属性，它指向一个对象（称为原型对象）。当你使用`new`关键字创建一个新的对象时，新对象的`[[Prototype]]`属性会被设置为构造函数的`prototype`属性所指向的对象。这就是新对象如何继承构造函数原型上的方法和属性的。

   ```javascript
   function MyConstructor() {}
   MyConstructor.prototype.sayHello = function() {
       console.log('Hello!');
   };
   
   let myObject = new MyConstructor();
   myObject.sayHello(); // 输出 "Hello!"
   ```

   在这个例子中，`MyConstructor.prototype`是一个对象，它有一个`sayHello`方法。当我们创建一个新的`MyConstructor`对象时，这个对象的`[[Prototype]]`属性被设置为`MyConstructor.prototype`，所以它可以访问`sayHello`方法。

2. `[[Prototype]]`：这是每个对象都有的一个内部属性（在ES6之前，这个属性被称为`__proto__`），它指向该对象的原型。你不能直接访问`[[Prototype]]`，但你可以使用`Object.getPrototypeOf()`和`Object.setPrototypeOf()`方法来获取和设置一个对象的原型。

   ```javascript
   let obj = {};
   console.log(Object.getPrototypeOf(obj) === Object.prototype); // 输出 true
   ```

   在这个例子中，`Object.getPrototypeOf(obj)`返回的是`obj`对象的原型，即`Object.prototype`。

3. `__proto__`：这是每个对象都有的一个属性，它指向该对象的原型，相当于`[[Prototype]]`的`getter`和`setter`。你可以通过`__proto__`属性来访问和修改一个对象的原型。然而，`__proto__`属性已经被弃用，并且在某些情况下可能会导致性能问题。因此，现代的JavaScript代码应该避免使用`__proto__`，而应该使用`Object.getPrototypeOf()`和`Object.setPrototypeOf()`方法来获取和设置一个对象的原型。

# Class和new Function()

   在JavaScript中，`class`和`new Function()`都可以用来创建对象，但它们之间存在一些重要的区别。

   1. `class`：`class`是ES6引入的新语法，用于创建对象和实现面向对象编程的特性，如继承。`class`语法更清晰，更易于理解和使用。在类中，你可以定义构造函数（constructor）和其他方法。类默认使用严格模式（strict mode），并且不可被重新声明。

      `class User {...}` 构造实际上做了如下的事儿：

      1. 创建一个名为 `User` 的函数，该函数成为类声明的结果。该函数的代码来自于 `constructor` 方法（如果我们不编写这种方法，那么它就被假定为空）。

      ```javascript
      class User {
          constructor(name) { this.name = name; }
          sayHi() { alert(this.name); }
      }
      // 佐证：User 是一个函数
      alert(typeof User); // function
      ```

      2. 存储类中的方法，例如 `User.prototype` 中的 `sayHi`。

      ```javascript
      class MyClass {
          constructor(name) {
              this.name = name;
          }
      
          sayHello() {
              console.log(`Hello, ${this.name}!`);
          }
      }
      
      let obj = new MyClass('John');
      obj.sayHello(); // 输出 'Hello, John!'
      ```

      虽然很多人说`class`是一种语法糖，但实际上它与`Function`有重大差异

      1. 首先，通过 `class` 创建的函数具有特殊的内部属性标记 `[[IsClassConstructor]]: true`。因此，它与手动创建并不完全相同。

         编程语言会在许多地方检查该属性。例如，与普通函数不同，必须使用 `new` 来调用它：

         ```javascript
         class User {
             constructor() {}
         }
         
         alert(typeof User); // function
         User(); // Error: Class constructor User cannot be invoked without 'new'
         ```

         此外，大多数 JavaScript 引擎中的类构造器的字符串表示形式都以 “class…” 开头

         ```javascript
         class User {
             constructor() {}
         }
         
         alert(User); // class User { ... }
         ```

         还有其他的不同之处，我们很快就会看到。

      2. 类方法不可枚举。 类定义将 `"prototype"` 中的所有方法的 `enumerable` 标志设置为 `false`。

         这很好，因为如果我们对一个对象调用 `for..in` 方法，我们通常不希望 class 方法出现。

      3. 类总是使用 `use strict`。 在类构造中的所有代码都将自动进入严格模式。

   2. `new Function()`：`new Function()`是一种创建新函数的方式。这种方式的特点是，你可以在运行时动态地创建函数，因为函数的主体是通过字符串来定义的。但是，这种方式的缺点是，代码可能难以阅读和维护，而且可能存在安全风险，因为它允许执行任意的JavaScript代码。

      ```javascript
      let MyFunc = new Function('name', `this.name = name;`);
      
      MyFunc.prototype.sayHello = function() {
          console.log(`Hello, ${this.name}!`);
      };
      
      let obj = new MyFunc('John');
      obj.sayHello(); // 输出 'Hello, John!'
      ```

      

   
