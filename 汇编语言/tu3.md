# 1 

(a) 

1. `mov ax, 100`：机器码是 `B8 0064`，长度是3字节。在内存中，它被存储为 `B8 64 00`。
2. `mov bx, 13`：机器码是 `BB 000D`，长度是3字节。在内存中，它被存储为 `BB 0D 00`。
3. `mov bx, OFFSET array`：机器码是 `BB 0008`，长度是3字节。在内存中，它被存储为 `BB 08 00`。

(b)

可以推断出 `mov REG, imm` 的操作码是 `B8+rd`，其中 `rd` 是寄存器的编号。例如，`ax` 的编号是 `0`，所以 `mov ax, imm` 的操作码是 `B8`；`bx` 的编号是 `3`，所以 `mov bx, imm` 的操作码是 `BB`。

# 2

```assembly
cmp ax, bx
jg check_ax_cx  ; 如果 ax > bx，跳转到 check_ax_cx
jl check_bx_cx  ; 如果 ax < bx，跳转到 check_bx_cx

; 如果 ax == bx，那么比较 ax 和 cx
cmp ax, cx
jg swap_ax_cx   ; 如果 ax > cx，交换 ax 和 cx
jmp end         ; 如果 ax <= cx，那么 ax 就是中间值

check_ax_cx:    ; ax > bx
cmp ax, cx
jg swap_ax_cx   ; 如果 ax > cx，交换 ax 和 cx
jmp end         ; 如果 ax <= cx，那么 ax 就是中间值

check_bx_cx:    ; ax < bx
cmp bx, cx
jg swap_bx_ax   ; 如果 bx > cx，交换 bx 和 ax
jmp end         ; 如果 bx <= cx，那么 ax 就是中间值

swap_ax_cx:     ; 交换 ax 和 cx
xchg ax, cx     
jmp end

swap_bx_ax:     ; 交换 bx 和 ax
xchg bx, ax

end:
```

# 3 
   ```assembly
   mov bx, 0       ; 初始化 bx 为 0
   mov cx, 16      ; 设置 cx 为 16（ax 的位数）
   
   count_ones:
   shr ax, 1       ; 将 ax 右移一位
   jnc skip_inc    ; 如果进位标志未设置，跳过增加操作
   inc bx          ; 增加 bx（1 的计数）
   
   skip_inc:
   loop count_ones ; 减少 cx 并循环，如果 cx != 0
   ```
# 4
 ```assembly
   xor ax, bx      ; 对 ax 和 bx 进行异或操作。如果它们相同，ax 将为 0
   or ax, ax       ; 对 ax 与自身进行或运算。如果 ax 是 0，零标志将被设置
   mov ax, 1       ; 将 ax 设置为 1
   jz end          ; 如果零标志被设置（ax 是 0），跳转到 end
   dec ax          ; 如果零标志未被设置（ax 不是 0），将 ax 减 1，变为 0
   
   end:
 ```
# 5
 ```assembly
   ; 假设 a, b, c, n 分别存储在寄存器 eax, ebx, ecx, edx 中
   
   add ebx, ecx    ; 计算 b + c
   cmp eax, ebx    ; 比较 a 和 (b + c)
   jge L2          ; 如果 a >= (b + c)，跳转到 L2
   
   ; a < (b + c) 的情况
   do:             ; 开始 do-while 循环
   cmp ebx, ecx    ; 比较 b 和 c
   je increment_a  ; 如果 b == c，跳转到 increment_a
   cmp eax, ebx    ; 比较 a 和 b
   jl increment_a  ; 如果 a < b，跳转到 increment_a
   jmp decrement_c ; 否则，跳转到 decrement_c
   
   increment_a:    ; 增加 a 的值
   add eax, ebx    ; a = a + b
   
   decrement_c:    ; 减少 c 的值
   dec ecx         ; c = c - 1
   jg do           ; 如果 c > 0，跳回到 do 开始 do-while 循环
   
   cmp eax, 0      ; 比较 a 和 0
   jne L2          ; 如果 a != 0，跳转到 L2
   cmp edx, 0      ; 比较 n 和 0
   jne L2          ; 如果 n != 0，跳转到 L2
   
   inc ecx         ; 如果 a == 0 并且 n == 0，执行 c = c + 1
   
   L2:             ; 结束
 ```
# 6
 ```assembly
   MYMUL PROC
   push DI        ; 保存 DI 的值
   push CX        ; 保存 CX 的值
   mov AX, 0      ; 将 AX 初始化为 0
   mov DX, 0      ; 将 DX 初始化为 0
   mov CX, 8      ; 将 CX 初始化为 8，因为我们正在处理 8 位数
   
   L1: 
   shl AX, 1      ; 将 AX 左移一位
   rcl DX, 1      ; 将 DX 左移一位，包括进位
   shl DI, 1      ; 将 DI 左移一位
   jnc L2         ; 如果没有进位，跳转到 L2
   add AX, SI     ; 将 SI 加到 AX 上
   jnc L2         ; 如果没有进位，跳转到 L2
   inc DX         ; 如果有进位，将 DX 加 1
   
   L2: 
   loop L1        ; 如果 CX 不为 0，将 CX 减 1 并跳转到 L1。否则，继续执行下一条指令
   
   pop CX         ; 恢复 CX 的值
   pop DI         ; 恢复 DI 的值
   ret            ; 返回
   
   MYMUL ENDP
 ```

​	它将 SI 和 DI 的值相乘，结果存储在 DX:AX 中（DX 为高位，AX 为低位）。

​	寄存器内容如下

| 循环次数 | DI       | DX       | AX       |
| -------- | -------- | -------- | -------- |
| 初始值   | 00001101 | 00000000 | 00000000 |
| 1        | 00011010 | 00000000 | 00011001 |
| 2        | 00110100 | 00000000 | 00110010 |
| 3        | 01101000 | 00000000 | 01100100 |
| 4        | 11010000 | 00000000 | 11001000 |
| 5        | 10100000 | 00000001 | 10010000 |
| 6        | 01000000 | 00000011 | 00100000 |
| 7        | 10000000 | 00000110 | 01000000 |
| 8        | 00000000 | 00001100 | 10000000 |
# 7
 ```assembly
   ; 假设 BP 已经被初始化为堆栈的栈底地址
   
   mov AX, [BP]      ; 取出堆栈中的第一个参数
   push AX           ; 将第一个参数压入堆栈
   add BP, 2         ; 移动 BP 到下一个参数
   
   mov AX, [BP]      ; 取出堆栈中的第二个参数
   push AX           ; 将第二个参数压入堆栈
   add BP, 2         ; 移动 BP 到下一个参数
   
   mov AX, [BP]      ; 取出堆栈中的第三个参数
   push AX           ; 将第三个参数压入堆栈
   
   ; 现在，堆栈中的三个参数已经被复制到了栈顶，我们可以开始比较它们
   
   pop AX            ; 取出第一个参数
   pop BP            ; 取出第二个参数
   cmp AX, BP        ; 比较第一个参数和第二个参数
   jge L1            ; 如果第一个参数大于等于第二个参数，跳转到 L1
   
   xchg AX, BP       ; 如果第一个参数小于第二个参数，交换 AX 和 BP
   
   L1:
   pop SP            ; 取出第三个参数
   cmp AX, SP        ; 比较最大的参数和第三个参数
   jge L2            ; 如果最大的参数大于等于第三个参数，跳转到 L2
   
   xchg AX, SP       ; 如果最大的参数小于第三个参数，交换 AX 和 SP
   
   L2:
   add BP, SP        ; 计算两个较小参数的和
   cmp AX, BP        ; 比较最大的参数和两个较小参数的和
   jne L3            ; 如果最大的参数不等于两个较小参数的和，跳转到 L3
   
   mov AX, SP        ; 如果最大的参数等于两个较小参数的和，将当前栈顶的内容（即第三个参数）放入 AX
   jmp L4            ; 跳转到 L4
   
   L3:
   mov AX, [BP]      ; 如果最大的参数不等于两个较小参数的和，将原栈顶参数的值放入 AX
   
   L4:
   ; 现在，AX 中存储的就是我们要返回的结果
 ```
# 8
   a. ISR1的起始地址为0x20000000+0x00000004=0x20000004，ISR2的起始地址为0x20000000+0x00000008=0x20000008。

   b. 因为设备1的优先级高于设备2，所以新程序的起始位置应该在设备1的中断服务程序之后，即从0x2000000C开始。

   c. 设备1的总不发出中断申请时，可以直接发起该设备的中断申请。

   d. 可以，可以通过设置设备2的中断掩码位来屏蔽其中断请求。例如，可以将设备2的中断掩码位设置为1，从而禁止设备2的中断请求被响应。

