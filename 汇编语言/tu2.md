# 汇编语言作业

# 1.下列寄存器经常用来存储偏移量，它们的缺省段寄存器是哪些寄存器？

(a) SP (Stack Pointer) - SS (Stack Segment) 

(b) EBX (Extended Base Register) - DS (Data Segment) 

(c) DI (Destination Index) - ES (Extra Segment) 

(d) EBP (Extended Base Pointer) - SS (Stack Segment) 

(e) SI (Source Index) - DS (Data Segment)

# 2. 下列指令的操作是什么？ 

(a) PUSH AX - 将AX寄存器的内容压入堆栈。 

(b) POP ESI - 从堆栈中弹出顶部的值并将其存入ESI寄存器。 

(c) PUSH [BX] - 将BX寄存器指向的内存位置的值压入堆栈。 

(d) PUSHFD - 将标志寄存器（Flags Register）的内容压入堆栈。 

(e) POP DS - 从堆栈中弹出顶部的值并将其存入DS（Data Segment）寄存器。 

(f) PUSHD 4 - 将立即数4压入堆栈。

# 3.  什么是汇编语言中的先行词？下列汇编语言先行词是用来做什么的？

汇编语言中的先行词是一种指令，用于定义数据和代码的类型、大小等属性。以下是提到的先行词的用途：  

(a) DW（Define Word）：定义一个或多个16位的字。  

(b) DD（Define Doubleword）：定义一个或多个32位的双字。  

(c) EQU（Equate）：用于给符号赋值，通常用于定义常量。  

(d) .386：这是一个指令，用于指定目标处理器类型为80386。  

(e) SEGMENT：用于定义一个段的开始。  

(f) STACK：通常用于定义一个堆栈段。

# 4. 判断无条件转移命令JMP的类型（短跳转，近跳转，或远跳转）

(a) 跳转距离为0210H字节：这是一个近跳转，因为跳转距离在-32768到32767字节之间。  

(b) 跳转距离为0020H字节：这是一个短跳转，因为跳转距离在-128到127字节之间。  

(c) 跳转距离为10000H字节：这是一个远跳转，因为跳转距离超过了32767字节。

# 5. 使用REPEAT-UNTIL结构，写段简短的程序，将内存段BLOCKA中， 以字节为地址单位的内容，拷贝到内存段BLOCKB中。

```assembly
MOV SI, OFFSET BLOCKA  ; 将BLOCKA的偏移量加载到源索引寄存器SI中
MOV DI, OFFSET BLOCKB  ; 将BLOCKB的偏移量加载到目标索引寄存器DI中

.Repeat  ; 定义一个名为.Repeat的标签，用于循环
    LODSB  ; 将SI指向的内存单元的值加载到寄存器AL中，并将SI增加1
    STOSB  ; 将AL中的值复制到DI指向的内存单元中，并将DI增加1
.Until AL == 0  ; 如果AL的值为0，结束循环，否则跳转到.Repeat标签继续执行
```

# 6.使用8086指令编写汇编程序，计算：$\sum_{n=0}^82^n$

```assembly
.model small  ; 定义内存模型为small
.stack 100h   ; 定义堆栈大小为256字节

.data  ; 数据段开始
sum dw 0 ; 定义一个名为sum的字，用于存储结果
n dw 0 ; 定义一个名为n的字，用于存储指数
two dw 2 ; 定义一个名为two的字，其值为2

.code  ; 代码段开始
main PROC  ; 定义一个名为main的过程
    mov ax,@data  ; 将数据段的地址加载到寄存器AX中
    mov ds,ax  ; 将AX中的值复制到数据段寄存器DS中

    mov cx,8  ; 将8加载到计数器寄存器CX中
    mov bx,0  ; 将0加载到寄存器BX中

    loop_start:  ; 定义一个名为loop_start的标签，用于循环
        add bx,n  ; 将n的值加到BX中
        mov ax,two  ; 将two的值加载到寄存器AX中
        mul n  ; 将AX中的值与n的值相乘，结果存储在AX中
        mov n,ax  ; 将AX中的值复制到n中
        loop loop_start  ; 如果CX的值不为0，将其减1并跳转到loop_start标签，否则继续执行下一条指令

    mov sum,bx  ; 将BX中的值复制到sum中
    mov ax,4c00h  ; 将4c00h加载到寄存器AX中，4c00h是DOS中结束程序的功能号
    int 21h  ; 调用DOS中断21h，结束程序
main endp  ; 结束main过程
```

# 7. 写段程序，从键盘读入字符，并在屏幕上显示出来。

```assembly
DATAS SEGMENT
buf db 50
    db ?  ;不指明初值
    db 50 dup(0)  ;定义一个50字节的缓冲区，用于存储从键盘读取的输入
DATAS ENDS
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS
START:
    MOV AX,DATAS  ;将数据段的地址加载到AX寄存器中
    MOV DS,AX     ;将AX寄存器的值加载到DS寄存器中，以便可以访问buf
    mov dx,offset buf   ;将buf的地址加载到DX寄存器中
    mov ah,10     ;设置AH寄存器的值为10，表示我们要调用DOS中断21h的功能号10h，这个功能可以从键盘读取一行输入
    int 21h       ;调用DOS中断21h，从键盘读取一行输入并存储在buf中
    
    mov dl,10     ;设置DL寄存器的值为10，这是换行符的ASCII码
    mov ah,02     ;设置AH寄存器的值为2，表示我们要调用DOS中断21h的功能号2h，这个功能可以打印一个字符
    int 21h       ;调用DOS中断21h，打印一个换行符
    
    mov bx,offset buf  ;将buf的地址加载到BX寄存器中
    inc bx             ;增加BX的值，以便跳过buf中的第一个字节（这个字节存储了输入的长度）
    mov cl,[bx]        ;将buf中的第一个字节（即输入的长度）加载到CL寄存器中
    mov ch,0           ;将CH寄存器的值设置为0，以便我们可以使用CX寄存器来存储输入的长度
    inc bx             ;再次增加BX的值，以便开始读取输入的内容

s0:mov dl,[bx]        ;将buf中的一个字节加载到DL寄存器中
    mov ah,02          ;设置AH寄存器的值为2，表示我们要调用DOS中断21h的功能号2h，这个功能可以打印一个字符
    int 21h            ;调用DOS中断21h，打印一个字符
    inc bx             ;增加BX的值，以便读取buf中的下一个字节
    loop s0            ;减少CX的值并跳回s0，直到CX的值为0
    MOV AH,4CH         ;设置AH寄存器的值为4Ch，表示我们要调用DOS中断21h的功能号4Ch，这个功能可以结束程序
    INT 21H            ;调用DOS中断21h，结束程序
CODES ENDS
    END START
```

![image-20240509093414508](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240509093414508.png)

# 8.计算寄存器AH中内容的平方，把结果存入寄存器BX。

```assembly
.model small
.stack 100h

.data

.code
main proc
    mov ah, 5   ; 将AH寄存器的值设置为5（你可以将其更改为你想要的值）
    mul ah      ; 计算AH寄存器的值的平方
    mov bx, ax  ; 将结果存储在BX寄存器中

    ; 在这里添加你的额外代码

    mov ah, 4Ch ; 设置AH寄存器的值为4Ch，表示我们要调用DOS中断21h的功能号4Ch，这个功能可以结束程序
    int 21h     ; 调用DOS中断21h，结束程序
main endp

end main
```

# 9.机器码与汇编语句转换：

(a) 机器码`8B07`对应的x86汇编语句是`MOV AX, [BX]`。这条指令将BX寄存器指向的内存位置的值加载到AX寄存器中。

(b) 汇编语句`mov SI,[BX+2]`对应的机器码是`8B70 02`。这条指令将BX寄存器指向的内存位置加2的值加载到SI寄存器中。

# 10. Figure 1（第 10 题）是一个存储系统组，可以使微处理器通过8-bit地址 总线访问它的64K字节空间。假设CPU中有4个8-bit通用寄存器AX, BX, CX和DX，系统支持立即数和变址间接寻址，回答下面的问题：

(a) 从CPU连接这个存储系统的输出端口号是3。

(b) 这台计算机系统的寻址能力是64K字节。通过8-bit地址线可以访问256字节的内存。

(c) 将ASCII码字符"A"写入这个内存系统的第四片RAM上地址为1FF0H的位置，可以使用以下汇编语言来实现：

```assembly
mov ah, 'A'  ; 将ASCII码字符"A"加载到AH寄存器中

mov dx, 3   ; 将输出端口号加载到DX寄存器中

out dx, ah   ; 将AH寄存器的值输出到端口3，选择第四片RAM

mov dx, 1FF0h ; 将地址1FF0h加载到DX寄存器中

out dx, ah   ; 将AH寄存器的值输出到地址1FF0h
```

(d) 从第五片RAM上0010H的位置读出一个字节，可以使用以下汇编语言来实现：

```assembly
mov dx, 3   ; 将输出端口号加载到DX寄存器中

mov al, 5   ; 将5加载到AL寄存器中，选择第五片RAM

out dx, al   ; 将AL寄存器的值输出到端口3

mov dx, 0010h ; 将地址0010h加载到DX寄存器中

in al, dx   ; 从地址0010h读取一个字节到AL寄存器中
```

(e) 将储存于存储于芯片RAM#4地址1FF0H到芯片RAM#5地址0010H之间的所有内容求和，可以使用以下汇编语言来实现：

```assembly
mov dx, 3   ; 将输出端口号加载到DX寄存器中

mov al, 4   ; 将4加载到AL寄存器中，选择第四片RAM

out dx, al   ; 将AL寄存器的值输出到端口3

mov dx, 1FF0h ; 将地址1FF0h加载到DX寄存器中

mov cx, 256  ; 设置循环计数为256

xor bx, bx   ; 清除BX寄存器，用于存储和

sum_loop:

in al, dx   ; 从当前地址读取一个字节到AL寄存器中

add bx, ax   ; 将AL寄存器的值加到BX寄存器中

inc dx     ; 增加DX寄存器的值，以便读取下一个字节

loop sum_loop ; 减少CX的值并跳回sum_loop，直到CX的值为0
```
