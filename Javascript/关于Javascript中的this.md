## 方法中的 “this”

**为了访问该对象，方法中可以使用 `this` 关键字。**

`this` 的值就是在点之前的这个对象，即调用该方法的对象。

举个例子：

```javascript
let user = {
    name: "John",
    age: 30,

    sayHi() {
        // "this" 指的是“当前的对象”
        alert(this.name);
    }

};

user.sayHi(); // John
```

在这里 `user.sayHi()` 执行过程中，`this` 的值是 `user`。

## “this” 不受限制

在 JavaScript 中，`this` 关键字与其他大多数编程语言中的不同。JavaScript 中的 `this` 可以用于任何函数，即使它不是对象的方法。

下面这样的代码没有语法错误：

```javascript
function sayHi() {
    alert( this.name );
}
```

不开启严格模式时：

```javascript
function sayHi() {
    console.log(this) // window 全局变量
    alert( this.name );
}
```

当开启严格模式时：

```javascript
'use strict'
function sayHi() {
    console.log(this) // undefined
    alert( this.name );
}
```

`this` 的值是在代码运行时计算出来的，它取决于代码上下文。

例如，这里相同的函数被分配给两个不同的对象，在调用中有着不同的 “this” 值：

```javascript
let user = { name: "John" };
let admin = { name: "Admin" };

function sayHi() {
    alert( this.name );
}

// 在两个对象中使用相同的函数
user.f = sayHi;
admin.f = sayHi;

// 这两个调用有不同的 this 值
// 函数内部的 "this" 是“点符号前面”的那个对象
user.f(); // John（this == user）
admin.f(); // Admin（this == admin）

admin['f'](); // Admin（使用点符号或方括号语法来访问这个方法，都没有关系。）
```

在 JavaScript 中，`this` 是“自由”的，它的值是在调用时计算出来的，它的值并不取决于方法声明的位置，而是取决于在`点符号前`的是什么对象。

## 箭头函数没有自己的 “this”

箭头函数有些特别：它们没有自己的 `this`。如果我们在这样的函数中引用 `this`，`this` 值取决于外部“正常的”函数。

举个例子，这里的 `arrow()` 使用的 `this` 来自于外部的 `user.sayHi()` 方法：

```java
let user = {
    firstName: "Ilya",
    sayHi() {
        let arrow = () => alert(this.firstName);
        arrow();
    }
};

user.sayHi(); // Ilya
```

在如下情况下

```javascript
'use strict '
function sayHi() {
    this.obj = this;
    return function() {
        console.log(`${this.obj}, Hello World`);
    }
}

let O = new sayHi();
O(); // undefined, Hello World
console.log(O.obj); // undefined
```

第一步我们设置了this.obj = this

此时的两个this指向的是sayHi,因为sayHi不是作为被调用的方法执行的，sayHi是作为一个新的对象

最后我们返回了自定义的function

之后我们使用O()调用这个函数，此时函数是作为一个方法被执行的

而对于一个普通的方法，`this`并不指向`O`对象，而是指向全局对象（在非严格模式下）或`undefined`（在严格模式下）

所以`O`对象中的`this.obj`并不存在，所以是未定义。

> 如果我们使用箭头函数来替代sayHi中的function()会怎么样呢?

```javascript
'use strict '
function sayHi() {
    this.obj = this;
    return () => {
        console.log(`${this.obj}, Hello World`);
    }
}

let O = new sayHi();
O(); // [object Object], Hello World
console.log(O.obj); // undefined
```

由于箭头函数的`this`取决于外部函数

所以返回的函数中的`this.obj`指向的是外部的return语句上方的`this.obj`

所以这种情况下`O()`能正常打印出obj而非是undefined

而O.obj仍然未定义因为箭头函数没有定义obj