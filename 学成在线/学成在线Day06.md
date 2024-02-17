# 学成在线Day06



# 上传视频

## 断点续传技术

### 1.什么是断点续传

通常视频文件都比较大，所以对于媒资系统上传文件的需求要满足大文件的上传要求。http协议本身对上传文件大小没有限制，但是客户的网络环境质量、电脑硬件环境等参差不齐，如果一个大文件快上传完了网断了没有上传完成，需要客户重新上传，用户体验非常差，所以对于大文件上传的要求最基本的是断点续传。

什么是断点续传：

​    引用百度百科：断点续传指的是在下载或上传时，将下载或上传任务（一个文件或一个压缩包）人为的划分为几个部分，每一个部分采用一个线程进行上传或下载，如果碰到网络故障，可以从已经上传或下载的部分开始继续上传下载未完成的部分，而没有必要从头开始上传下载，断点续传可以提高节省操作时间，提高用户体验性。

断点续传流程如下图：

![image-20240217205319182](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240217205319182.png)

流程如下：

1、前端上传前先把文件分成块

2、一块一块的上传，上传中断后重新上传，已上传的分块则不用再上传

3、各分块上传完成最后在服务端合并文件

文件分块测试代码：

```
//分块测试
@Test
public void testChunk() throws IOException {
    File sourceFile = new File("C:\\Users\\Administrator\\Desktop\\分块测试\\test.mp4");

    String fileChunkPath = "C:\\Users\\Administrator\\Desktop\\分块测试";
    //分块大小
    int chunkSize = 1024 * 1024 * 1;
    //分块数量
    int chunkNum = (int) Math.ceil(sourceFile.length() * 1.0 / chunkSize);
    RandomAccessFile ref_r = new RandomAccessFile(sourceFile, "r");
    //缓冲区
    byte[] b = new byte[1024];
    for ( int i = 0; i < chunkNum; i++ ) {
        //创建分块文件
        File chunkFile = new File(fileChunkPath + i);
        //分块文件写入流
        RandomAccessFile ref_w = new RandomAccessFile(chunkFile, "rw");
        int len = -1;
        //读取文件
        while ( (len = ref_r.read(b)) != -1 ) {
            ref_w.write(b, 0, len);
            if ( chunkFile.length() >= chunkSize ) {
                break;
            }
        }
    }
```

其中用到了`RandomAccessFile`

RandomAccessFile从字面意思翻译：随机通行文件

下面开始介绍一下RandomAccessFile，该类是直接继承Object的类，既可以读取文件内容，也可以向文件输出数据。

RandomAccessFile支持“随机访问”的方式，程序快可以直接跳转到文件的**任意地方**来读写数据。

RandomAccessFile的一个重要使用场景就是网络请求中的多线程下载及断点续传。