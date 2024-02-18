# 1 Markdown标题语法

创建标题需要在单词或短语面前添加(#),#号数量代表标题级别,最多添加6个#

```
# 一级标题
```

# 1.1 一级标题

```
## 二级标题
```

## 1.2 二级标题

```
### 三级标题
```

### 1.3 三级标题

不同的 Markdown 应用程序处理 `#` 和标题之间的空格方式并不一致。为了兼容考虑，请用一个空格在 `#` 和标题之间进行分隔。

|    ✅     |    ❌    |
| :------: | :-----: |
| `# 标题` | `#标题` |

Typora快捷键: Crtl + 1-6

# 2 Markdown 段落语法

要创建段落，请使用空白行将一行或多行文本进行分隔。

```
这是第一段的段落
这是第二段的段落
```

**请不要在段落面前加入空格或者制表符(TAB)**

# 3 Markdown 换行语法

```
按下回车即可换行
就像这样😀
```

# 4 Markdown强调语法

通过将文本设置为粗体或斜体来强调其重要性。

### 4.1 粗体（Bold）

```
**这是粗体语法**
```

**这是粗体语法**

Typora快捷键: Crtl + B

### 4.2 斜体（Italic）

```
*这是斜体语法*
```

*这是斜体语法*

Typora快捷键: Crtl + I

### 4.3 粗体（Bold）和斜体（Italic）

```
***这是粗体和斜体同时作用***
```

***这是粗体和斜体同时作用***

Typora快捷键: Crtl + I + B

### 4.4 删除线

```
~~这是删除线~~
```

~~这是删除线~~

# 5 Markdown 引用语法

要创建块引用，请在段落前添加一个 `>` 符号。

### 5.1 单行引用

```
>这就是单行引用
```

> 这就是单行引用  

### 5.2 多个段落的块引用

```
>第一行引用
>
>
>
>第二行引用
```

> 第一行引用
>
> 
>
> 第二行引用

### 5.3 嵌套块引用

```
>
>
>>这是外层引用
>>这是第一行内层引用
>>这是第二行内层引用
```

>这是外层引用
>
>>这是第一行内层引用
>>
>>这是第二行内层引用

### 5.4 带有其他元素的引用

> #### 效果看起来很不错!
>
> - 这是无序列表第一行!
> - 这是无序列表第二行!
>
> ***效果如同我们想象的那样出现***

# 6 Markdown 列表语法

可以将多个条目组织成有序或无序列表。

### 6.1 有序列表

要创建有序列表，请在每个列表项前添加数字并紧跟一个英文句点。数字不必按数学顺序排列，但是列表应当以数字 1 起始。

```
1.第一件物品
2.第二件物品
3.第三件物品
4.LOLOLOLOL
```

1. 第一件物品

2. 第二件物品

3. 第三件物品

4. LOLOLOLOL

Typora快捷键: Crtl + Shift + [

即使你在定义时数字并非从1开始，列表显示时也会正常工作，效果如下

```
1.第一件物品
1.第二件物品
1.第三件物品
1.LOLOLOLOL
```

1. 第一件物品
1. 第二件物品
1. 第三件物品
1. LOLOLOLOL

### 6.2 无序列表

要创建无序列表，请在每个列表项前面添加破折号 (-)、星号 (*) 或加号 (+) 。缩进一个或多个列表项可创建嵌套列表。

```
- 第一件物品
- 第二件物品
- 第三件没了
- 再看一下上一行
```

- 第一件物品
- 第二件物品
- 第三件没了
- 再看一下上一行

Typora快捷键: Crtl + Shift + ]

```
无序列表四种符号均可使用
但是不能混用,例如:
- 第一件物品
+ 第二件物品
- 第三件没了
* 再看一下上一行
```

### 6.3 在列表中嵌套其他元素

要在保留列表连续性的同时在列表中添加另一种元素，请将该元素缩进四个空格或一个制表符，如下例所示

```
*   This is the first list item.
*   Here's the second list item.

    >I need to add another paragraph below the second list item.

*   And here's the third list item.
```

* This is the first list item.

*   Here's the second list item.

    > I need to add another paragraph below the second list item.

* And here's the third list item.

```
1.   This is the first list item.
2.   Here's the second list item.
	
	- 拦腰截断！
	- 再接回去！

3.   And here's the third list item.
```



1.   This is the first list item.
2.   Here's the second list item.

     - 拦腰截断！
     - 再接回去！
3.   And here's the third list item.

# 7 Markdown 代码语法

要将单词或短语表示为代码，请将其包裹在反引号 (`) 中。

```
一句话里面掺一些`代码`
```

一句话里面掺一些`代码`

如果你要表示为代码的单词或短语中包含一个或多个反引号，则可以通过将单词或短语包裹在双反引号(````)中。

```
``Use `code` in your Markdown file.``
```

``Use `code` in your Markdown file.``

Typora快捷键: Crtl + Shift + Q

### 围栏式代码块

~~~text
```
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```
~~~

```
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```

# 8 Markdown 分隔线语法

要创建分隔线，请在单独一行上使用三个或多个星号 (`***`)、破折号 (`---`) 或下划线 (`___`) ，并且不能包含其他内容。

```
***
---
_________
```



***
---
_________

为了兼容性，请在分隔线的前后均添加空白行。

|                              ✅                               |                              ❌                               |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| Try to put a blank line before...<br><br>---<br><br>...and after a horizontal rule. | Without blank lines, this would be a heading.<br/>\---<br/>Don't do this! |

# 9 Markdown 链接语法

### 9.1 标准链接语法

链接文本放在中括号内，链接地址放在后面的括号中，链接title可选。

超链接Markdown语法代码：`[超链接显示名](超链接地址 "超链接title")`

```
[不懂就去问百度](www.baidu.com)
```

[不懂就去问百度](www.baidu.com)

### 9.2 带title的链接语法

```
[不懂就去问百度](www.baidu.com "这是百度哦😙")
```

[不懂就去问百度](www.baidu.com "这是百度哦😙")

### 9.3 网址和Email地址

使用尖括号可以很方便地把URL或者email地址变成可点击的链接。

```
<www.bilibili.com>

<892920290@qq.com>
```

<www.bilibili.com>

<892920290@qq.com>

### 9.4 带格式化的链接

```text
I love supporting the **[EFF](https://eff.org)**.
This is the *[Markdown Guide](https://www.markdownguide.org)*.
See the section on [`code`](#code).
```

I love supporting the **[EFF](https://eff.org)**.
This is the *[Markdown Guide](https://www.markdownguide.org)*.
See the section on [`code`](#code).

```
[百度]: www.baidu.com "芝士百度"
```

不懂就问[芝士百度][百度]

不同的 Markdown 应用程序处理URL中间的空格方式不一样。为了兼容性，请尽量使用%20代替空格。

| ✅ Do this                                           | ❌ Don't do this                                 |
| --------------------------------------------------- | ----------------------------------------------- |
| `[link](https://www.example.com/my%20great%20page)` | `[link](https://www.example.com/my great page)` |

### 9.5 脚注

```
[^footnote]: 这是个脚注
```

您可以像这样创建脚注[^footnote]

[^footnote]: 这是个脚注



# 10 Markdown 图片语法

### 10.1 基础语法

要添加图像，请使用感叹号 (`!`), 然后在方括号增加替代文本，图片链接放在圆括号里，括号里的链接后可以增加一个可选的图片标题文本。

```
<img src="https://wwhds-blog.oss-cn-beijing.aliyuncs.com/avatar/w.jpg" alt="个人头像" style="zoom:50%;" />
```



<img src="https://wwhds-blog.oss-cn-beijing.aliyuncs.com/avatar/w.jpg" alt="个人头像" style="zoom:50%;" />

Typora快捷键: Crtl + Shift + I

### 10.2 带链接的图像

给图片增加链接，请将图像的Markdown 括在方括号中，然后将链接添加在圆括号中。

```text
[![风景图](https://4kbizhi.com/d/file/2024/01/26/small092925Rh8Tv1706232565.jpg)](www.baidu.com)
```



[![风景图](https://4kbizhi.com/d/file/2024/01/26/small092925Rh8Tv1706232565.jpg)](www.baidu.com)



# 11 Markdown 转义字符语法

### 11.1特殊字符用法

要显示原本用于格式化 Markdown 文档的字符，请在字符前面添加反斜杠字符 \ 。

```text
\* Without the backslash, this would be a bullet in an unordered list.
```

\* Without the backslash, this would be a bullet in an unordered list.

### 11.2特殊字符自动转义

在 HTML 文件中，有两个字符需要特殊处理： `<` 和 `&` 。 `<` 符号用于起始标签，`&` 符号则用于标记 HTML 实体，如果你只是想要使用这些符号，你必须要使用实体的形式，像是 `<` 和 `&`。

例如:

```
http://images.google.com/images?num=30&q=larry+bird
```

应该如此才能正常使用

```
http://images.google.com/images?num=30&amp;q=larry+bird
```

|   >    |    &    |
| :----: | :-----: |
| `&lt;` | `&amp;` |

# 12 Markdown 内嵌 HTML 标签

对于 Markdown 涵盖范围之外的标签，都可以直接在文件里面用 HTML 本身。如需使用 HTML，不需要额外标注这是 HTML 或是 Markdown，只需 HTML 标签添加到 Markdown 文本中即可。

### 12.1 行级內联标签

HTML 的行级內联标签如 `<span>`、`<cite>`、`<del>` 不受限制，可以在 Markdown 的段落、列表或是标题里任意使用。依照个人习惯，甚至可以不用 Markdown 格式，而采用 HTML 标签来格式化。例如：如果比较喜欢 HTML 的 `<a>` 或 `<img>` 标签，可以直接使用这些标签，而不用 Markdown 提供的链接或是图片语法。当你需要更改元素的属性时（例如为文本指定颜色或更改图像的宽度），使用 HTML 标签更方便些。

HTML 行级內联标签和区块标签不同，在內联标签的范围内， Markdown 的语法是可以解析的。

```
**这一段话既可以这么加粗**,<strong>也可以这么加粗。</strong>
```

**这一段话既可以这么加粗**,<strong>也可以这么加粗。</strong>

### 12.2 区块标签

区块元素──比如 `<div>`、`<table>`、`<pre>`、`<p>` 等标签，必须在前后加上空行，以便于内容区分。而且这些元素的开始与结尾标签，不可以用 tab 或是空白来缩进。Markdown 会自动识别这区块元素，避免在区块标签前后加上没有必要的 `<p>` 标签。

例如，在 Markdown 文件里加上一段 HTML 表格：

```
在标签之前的元素

<div>
	<span>
        <strong>
            span标签内的元素
        </strong>
    </span>
</div>

在标签之后的元素
```

在标签之前的元素

<div>
	<span>
        <strong>
            span标签内的元素
        </strong>
    </span>
</div>

在标签之后的元素

**注意：在 HTML 块级标签内不能使用 Markdown 语法。例如 `<p>italic and **bold**</p>` 将不起作用。**

