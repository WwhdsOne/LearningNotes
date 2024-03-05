# 学成在线Day11

# 用户授权

## RBAC

如何实现授权？业界通常基于RBAC实现授权。

RBAC分为两种方式：

基于角色的访问控制（Role-Based Access Control）

基于资源的访问控制（Resource-Based Access Control）

角色的访问控制（Role-Based Access Control）是按角色进行授权，比如：主体的角色为总经理可以查询企业运营报表，查询员工工资信息等，访问控制流程如下：

![image-20240304162632533](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240304162632533.png)

根据上图中的判断逻辑，授权代码可表示如下：

```java
if(主体.hasRole("总经理角色id")){
	查询工资
}
```

如果上图中查询工资所需要的角色变化为总经理和部门经理，此时就需要修改判断逻辑为“判断用户的角色是否是总经理或部门经理”，修改代码如下：

```java
if(主体.hasRole("总经理角色id") ||  主体.hasRole("部门经理角色id")){
    查询工资
}
```

根据上边的例子发现，当需要修改角色的权限时就需要修改授权的相关代码，系统可扩展性差。

基于资源的访问控制（Resource-Based Access

Control）是按资源（或权限）进行授权，比如：用户必须具有查询工资权限才可以查询员工工资信息等，访问控制流程如下：

![image-20240304163606002](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240304163606002.png)

根据上图中的判断，授权代码可以表示为：

```java
if(主体.hasPermission("查询工资权限标识")){
    查询工资
}
```

优点：系统设计时定义好查询工资的权限标识，即使查询工资所需要的角色变化为总经理和部门经理也不需要修改授权代码，系统可扩展性强。

## 资源服务授权流程

本项目在资源服务内部进行授权，基于资源的授权模式，因为接口在资源服务，通过在接口处添加授权注解实现授权。

在资源服务集成Spring Security

在需要授权的接口处使用@PreAuthorize("hasAuthority('权限标识符')")进行控制

下边代码指定/course/list接口需要拥有xc_teachmanager_course_list 权限。

![image-20240304164611743](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240304164611743.png)

设置了@PreAuthorize表示执行此方法需要授权，如果当前用户请求接口没有权限则抛出异常

org.springframework.security.access.AccessDeniedException: 不允许访问

在统一异常处理处处理异常

```java
@ResponseBody
@ExceptionHandler(Exception.class)
@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
public RestErrorResponse exception(Exception e) {
    log.error("【系统异常】{}",e.getMessage(),e);
    e.printStackTrace();
    if(e.getMessage().equals("不允许访问")){
        return new RestErrorResponse("没有操作此功能的权限");
    }
    return new RestErrorResponse(CommonError.UNKOWN_ERROR.getErrMessage());
}
```

重启资源服务进行测试

使用教学机构用户登录系统

这里使用t1用户登录，账号:t1、密码：111111

登录成功，点击“教学机构”

![image-20240304171025127](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240304171025127.png)

如何给用户分配权限呢？

首先要学习数据模型，本项目授权相关的数据表如下：

![image-20240304171201768](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240304171201768.png)

xc_user：用户表，存储了系统用户信息，用户类型包括：学生、老师、管理员等

xc_role：角色表，存储了系统的角色信息，学生、老师、教学管理员、系统管理员等。

xc_user_role：用户角色表，一个用户可拥有多个角色，一个角色可被多个用户所拥有

xc_menu:模块表，记录了菜单及菜单下的权限

xc_permission:角色权限表，一个角色可拥有多个权限，一个权限可被多个角色所拥有

本项目要求掌握基于权限数据模型（5张数据表），要求在数据库中操作完成给用户分配权限、查询用户权限等需求。

1、查询用户所拥有的权限

步骤：

查询用户的id

查询用户所拥有的角色

查询用户所拥有的权限

例子：

```mysql
SELECT * FROM xc_menu WHERE id IN(
    SELECT menu_id FROM xc_permission WHERE role_id IN(
        SELECT role_id FROM xc_user_role WHERE user_id = '49'
    )
)
```

2、给用户分配权限

1）添加权限

查询用户的id

查询权限的id

查询用户的角色，如果没有角色需要先给用户指定角色

向角色权限表添加记录

2）删除用户权限

本项目是基于角色分配权限，如果要删除用户的权限可以给用户换角色，那么新角色下的权限就是用户的权限；如果不换用户的角色可以删除角色下的权限即删除角色权限关系表相应记录，这样操作是将角色下的权限删除，属于该角色的用户都将删除此权限。

## 查询用户权限

使用Spring Security进行授权，首先在生成jwt前会查询用户的权限，如下图

![image-20240304173446011](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240304173446011.png)

接下来需要修改UserServiceImpl和PasswordAuthServiceImpl从数据库查询用户的权限。

1. 定义mapper接口

```java
public interface XcMenuMapper extends BaseMapper<XcMenu> {
    @Select("SELECT    * FROM xc_menu WHERE id IN (SELECT menu_id FROM xc_permission WHERE role_id IN ( SELECT role_id FROM xc_user_role WHERE user_id = #{userId} ))")
    List<XcMenu> selectPermissionByUserId(@Param("userId") String userId);
}
```

2. 修改PasswordAuthServiceImpl

修改UserServiceImpl类的getUserPrincipal方法，查询权限信息

```java
//查询用户身份
public UserDetails getUserPrincipal(XcUserExt user){
    String password = user.getPassword();
    //查询用户权限
    List<XcMenu> xcMenus = menuMapper.selectPermissionByUserId(user.getId());
    List<String> permissions = new ArrayList<>();
    if(xcMenus.size()<=0){
        //用户权限,如果不加则报Cannot pass a null GrantedAuthority collection
        permissions.add("p1");
    }else{
        xcMenus.forEach(menu->{
            permissions.add(menu.getCode());
        });
    }
    //将用户权限放在XcUserExt中
    user.setPermissions(permissions);

    //为了安全在令牌中不放密码
    user.setPassword(null);
    //将user对象转json
    String userString = JSON.toJSONString(user);
    String[] authorities = permissions.toArray(new String[0]);
    UserDetails userDetails = User.withUsername(userString).password(password).authorities(authorities).build();
    return userDetails;
}
```

将xc_teachmanager_course_list权限分配给用户。

1）首先找到当前用户的角色

2）找到xc_teachmanager_course_list权限的主键

3）在角色权限关系表中添加记录

分配完权限需要重新登录

由于用户分配了xc_teachmanager_course_list权限，用户具有访问课程查询接口的权限。

## 细粒度授权

### **什么是细粒度授权**

什么是细粒度授权？

细粒度授权也叫数据范围授权，即不同的用户所拥有的操作权限相同，但是能够操作的数据范围是不一样的。一个例子：用户A和用户B都是教学机构，他们都拥有“我的课程”权限，但是两个用户所查询到的数据是不一样的。

本项目有哪些细粒度授权？

比如：

我的课程，教学机构只允许查询本教学机构下的课程信息。

我的选课，学生只允许查询自己所选课。

如何实现细粒度授权？

细粒度授权涉及到不同的业务逻辑，通常在`service`层实现，根据不同的用户进行校验，根据不同的参数查询不同的数据或操作不同的数据。

### 教学机构细粒度授权

教学机构在维护课程时只允许维护本机构的课程，教学机构细粒度授权过程如下：

1. 获取当前登录的用户身份

2. 得到用户所属教育机构的Id

3. 查询该教学机构下的课程信息

最终实现了用户只允许查询自己机构的课程信息。

根据公司Id查询课程，流程如下：

1. 教学机构用户登录系统，从用户身份中取出所属机构的id,在用户表中设计了company_id字段存储该用户所属的机构id.

2. 接口层取出当前登录用户的身份，取出机构id

3) 将机构id传入service方法。
4) service方法将机构id传入Dao方法，最终查询出本机构的课程信息。

代码实现如下：

```java
@ApiOperation("课程查询接口")
@PreAuthorize("hasAuthority('xc_teachmanager_course_list')")//拥有课程列表查询的权限方可访问
@PostMapping("/course/list")
public PageResult<CourseBase> list(PageParams pageParams, @RequestBody QueryCourseParamsDto queryCourseParams){
    //取出用户身份
    XcUser user = SecurityUtil.getUser();
    //机构id
    String companyId = user.getCompanyId();
    return courseBaseInfoService.queryCourseBaseList(Long.parseLong(companyId),pageParams,queryCourseParams);
}
```

Service层:

```java
@Transactional
@Override
public PageResult<CourseBase> queryCourseBaseList(Long companyId, PageParams pageParams, QueryCourseParamsDTO queryCourseParamsDto) {
    //构建查询条件对象
    LambdaQueryWrapper<CourseBase> queryWrapper = new LambdaQueryWrapper<>();
    //构建查询条件，根据课程名称查询
    queryWrapper.like(StringUtils.isNotEmpty(queryCourseParamsDto.getCourseName()), CourseBase::getName, queryCourseParamsDto.getCourseName());
    //构建查询条件，根据课程审核状态查询
    queryWrapper.eq(StringUtils.isNotEmpty(queryCourseParamsDto.getAuditStatus()), CourseBase::getAuditStatus, queryCourseParamsDto.getAuditStatus());
    //构建查询条件，根据课程发布状态查询
    queryWrapper.eq(StringUtils.isNotEmpty(queryCourseParamsDto.getPublishStatus()), CourseBase::getStatus, queryCourseParamsDto.getPublishStatus());
    //构建查询条件，根据课程所属机构查询
    queryWrapper.eq(CourseBase::getCompanyId, companyId);
    //分页对象
    Page<CourseBase> page = new Page<>(pageParams.getPageNo(), pageParams.getPageSize());
    // 查询数据内容获得结果
    Page<CourseBase> pageResult = courseBaseMapper.selectPage(page, queryWrapper);
    // 获取数据列表
    List<CourseBase> list = pageResult.getRecords();
    // 获取数据总数
    long total = pageResult.getTotal();
    // 构建结果集
    PageResult<CourseBase> courseBasePageResult = new PageResult<>(list, total, pageParams.getPageNo(), pageParams.getPageSize());
    return courseBasePageResult;
}
```

`启动后出现配置类重名情况`

原因:因为我前面没写工具类导致引入的工具类是其他包的工具类顺便在maven导入了其他模块进而导致了类名重复无法运行,下次可以先从maven依赖开始检查

# 找回密码实战

## 找回密码接口文档

**只做邮箱找回密码**

>- 需求：忘记密码需要找回，可以通过邮箱找回密码
>- 页面访问地址：localhost/findpassword.html

接口:

>邮箱验证码：/api/checkcode/phone?param1=电子邮箱地址
>
>找回密码：/api/auth/findpassword

请求:

```json
{
    cellphone:'',
    email:'',
    checkcodekey:'',
    checkcode:'',
    confirmpwd:'',
    password:''
}
```

响应：

200: 找回成功

其它：找回失败，失败原因使用统一异常处理返回的信息格式

执行流程

1. 校验验证码，不一致则抛出异常

2. 判断两次密码是否一致，不一致则抛出异常

3. 根据手机号和邮箱查询用户

4. 如果找到用户更新为新密码

## 找回密码代码开发

### 1. 安装相关依赖

邮箱相关依赖:

```xml
<!-- https://mvnrepository.com/artifact/javax.activation/activation -->
<dependency>
    <groupId>javax.activation</groupId>
    <artifactId>activation</artifactId>
    <version>1.1.1</version>
</dependency>
<!-- https://mvnrepository.com/artifact/javax.mail/mail -->
<dependency>
    <groupId>javax.mail</groupId>
    <artifactId>mail</artifactId>
    <version>1.4.7</version>
</dependency>
<!-- https://mvnrepository.com/artifact/org.apache.commons/commons-email -->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-email</artifactId>
    <version>1.4</version>
</dependency>
```

### 2. 编写邮箱工具类

```java
package com.xuecheng.checkcode.utils;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMessage.RecipientType;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Properties;

public class MailUtil {


    private MimeMessage mimeMsg; // 邮件对象
    private Multipart mp;// 附件添加的组件

    public static void main(String[] args) throws MessagingException {
        //可以在这里直接测试方法，填自己的邮箱即可
        sendTestMail("a1605691832@163.com", achieveCode());
    }

    /**
     * 发送邮件
     * @param email 收件邮箱号
     * @param code  验证码
     * @throws MessagingException 邮件异常
     */
    public static void sendTestMail(String email, String code) throws MessagingException {
        /* 创建Properties 类用于记录邮箱的一些属性
         * 1.邮件服务器
         * 2.发件人邮箱
         * 3.发件人的授权密码
         * 4.邮件主题
         * 5.收件人，多个收件人以半角逗号分隔
         * 6.抄送，多个抄送以半角逗号分隔
         * 7.正文，可以用html格式的哟
         */
        Properties props = new Properties();
        // 表示SMTP发送邮件，必须进行身份验证
        props.put("mail.smtp.auth", "true");
        //此处填写SMTP服务器
        props.put("mail.smtp.host", "smtp.163.com");
        //端口号，QQ邮箱端口587
        props.put("mail.smtp.port", "25");
        // 此处填写，写信人的账号
        props.put("mail.user", "a1605691832@163.com");
        // 此处填写16位STMP口令
        props.put("mail.password", "CZLXNYOVEHHUQRXB");
        // 构建授权信息，用于进行SMTP进行身份验证
        Authenticator authenticator = new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                // 用户名、密码
                String userName = props.getProperty("mail.user");
                String password = props.getProperty("mail.password");
                return new PasswordAuthentication(userName, password);
            }
        };
        // 使用环境属性和授权信息，创建邮件会话
        Session mailSession = Session.getInstance(props, authenticator);
        // 创建邮件消息
        MimeMessage message = new MimeMessage(mailSession);
        // 设置发件人
        InternetAddress from = new InternetAddress(props.getProperty("mail.user"));
        message.setFrom(from);
        // 设置收件人的邮箱
        InternetAddress to = new InternetAddress(email);
        message.setRecipient(RecipientType.TO, to);
        // 设置邮件标题
        message.setSubject("Wwhds 学成在线实战邮件测试");
        // 设置邮件的内容体
        message.setContent("尊敬的用户:你好!\n注册验证码为:" + code + "(有效期为一分钟,请勿告知他人)", "text/html;charset=UTF-8");
        // 最后当然就是发送邮件啦
        Transport.send(message);
    }

    /**
     *  生成验证码
     * @return 验证码
     */
    public static String achieveCode() {  //由于数字 1 、 0 和字母 O 、l 有时分不清楚，所以，没有数字 1 、 0
        String[] beforeShuffle = new String[]{"2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F",
                "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a",
                "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
                "w", "x", "y", "z"};
        List<String> list = Arrays.asList(beforeShuffle);//将数组转换为集合
        Collections.shuffle(list);  //打乱集合顺序
        StringBuilder sb = new StringBuilder();
        for (String s : list) {
            sb.append(s); //将集合转化为字符串
        }
        return sb.substring(3, 8);
    }
}
```

### 3. 发送验证码接口

**Controller层:**

```java
@ApiOperation(value = "发送邮箱验证码", tags = "发送邮箱验证码")
@PostMapping("/phone")
public void sendEMail(@RequestParam("param1") String email) throws MessagingException {
    String code = MailUtil.achieveCode();
    sendCodeService.sendCodeToEmail(email, code);
}
```

**Service接口:**

```java
public interface SendCodeService {

        /**
        * 发送验证码
        * @param email 目标邮箱
        * @param code 验证码
        */
        void sendCodeToEmail(String email,String code);
}
```

**Service实现类:**

```java
@Service
@Slf4j
public class SendCodeServiceImpl implements SendCodeService {

    @Autowired
    RedisTemplate<String, String> redisTemplate;

    @Override
    public void sendCodeToEmail(String email, String code) {
        log.info("发送验证码到邮箱：{}，验证码：{}", email, code);
        try {
            //1.发送邮件
            MailUtil.sendTestMail(email, code);
        } catch (MessagingException e) {
            log.info("发送验证码到邮箱失败：{}，验证码：{}", email, code);
            XueChengPlusException.cast("发送验证码到邮箱失败");
        }
        //2.将验证码存入redis
        long CODE_EXPIRE_TIME = 2 * 60L;
        redisTemplate.opsForValue().set(email, code, CODE_EXPIRE_TIME);
    }
}
```

### 4. 验证验证码接口

密码找回DTO类:

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FindPswDto {

    String cellphone;

    String email;

    String checkcodekey;

    String checkcode;

    String password;

    String confirmpwd;
}
```

**Controller层:**

```java
@ApiOperation(value = "验证验证码是否正确", tags = "验证验证码是否正确")
@PostMapping("/findpassword")
public void verifyCode(@RequestBody FindPswDto findPswDto) {
    log.info("验证验证码:{}", findPswDto);
    verifyService.findPassword(findPswDto);
}
```

**Service接口:**

```java
public interface VerifyService {
    void findPassword(FindPswDto findPswDto);
}
```

**Service实现类:**

```java
@Service
@Slf4j
public class VerifyServiceImpl implements VerifyService {

    @Autowired
    private RedisTemplate<String,String> redisTemplate;

    @Autowired
    private XcUserMapper userMapper;
    @Override
    public void findPassword(FindPswDto findPswDto) {
        //获取redis中的验证码
        String code = redisTemplate.opsForValue().get(findPswDto.getEmail());
        if (code == null) {
            log.info("验证码已过期");
            XueChengPlusException.cast("验证码已过期");
        }
        if (!code.equals(findPswDto.getCheckcode())) {
            log.info("验证码错误");
            XueChengPlusException.cast("验证码已过期");
        }
        String password = findPswDto.getPassword();
        String confirmpwd = findPswDto.getConfirmpwd();
        if (!password.equals(confirmpwd)) {
            log.info("两次密码不一致");
            XueChengPlusException.cast("两次密码不一致");
        }
        //修改密码
        LambdaQueryWrapper<XcUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(XcUser::getEmail,findPswDto.getEmail());
        wrapper.eq(XcUser::getCellphone,findPswDto.getCellphone());
        XcUser xcUser = userMapper.selectOne(wrapper);
        if (xcUser == null) {
            log.info("用户不存在");
            XueChengPlusException.cast("用户不存在");
        }
        xcUser.setPassword(new BCryptPasswordEncoder().encode(password));
        userMapper.updateById(xcUser);
    }
}
```

# 注册实战

## 注册接口文档

需求：为学生提供注册入口，通过此入口注册的用户为学生用户。

界面访问地址：http://www.51xuecheng.cn/register.html

![image-20240304222553158](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240304222553158.png)

接口：

手机验证码：/api/checkcode/phone?param1=手机号

注册：/api/auth/register

请求：

```json
{
    cellphone:'',
    username:'',
    email:'',
    nickname:'',
    password:'',
    confirmpwd:'',
    checkcodekey:'',
    checkcode:''
}
```

响应：

200: 注册成功

其它：注册失败，失败原因使用统一异常处理返回的信息格式

执行流程：

1. 校验验证码，如果不一致则抛出异常

2. 校验两次密码是否一致，如果不一致则抛出异常

3. 校验用户是否存在，如果存在则抛出异常

4. 向用户表、用户角色关系表添加数据。角色为学生角色。

## 代码开发

### 1. 准备DTO类接受注册参数

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterDto {

    private String cellphone;

    private String checkcode;

    private String checkcodekey;

    private String confirmpwd;

    private String email;

    private String nickname;

    private String password;

    private String username;
}
```

### 2. 注册接口

**Controller层:**

```java
@ApiOperation(value = "注册", tags = "注册")
@RequestMapping("/register")
public void register(@RequestBody RegisterDto registerDto) {
    verifyService.register(registerDto);
}
```

**Sevice接口:**

```java
public interface VerifyService {
    void register(RegisterDto registerDto);
}
```

**Service接口实现类:**

```java
@Override
@Transactional
public void register(RegisterDto registerDto) {
    String id = UUID.randomUUID().toString();
    String email = registerDto.getEmail();
    String password = registerDto.getPassword();
    String confirmpwd = registerDto.getConfirmpwd();
    String checkcode = registerDto.getCheckcode();
    Boolean verify = verify(email, checkcode);
    //验证码错误
    if ( !verify ) {
        throw new RuntimeException("验证码输入错误");
    }
    //两次密码不一致
    if ( !password.equals(confirmpwd) ) {
        throw new RuntimeException("两次密码不一致");
    }
    LambdaQueryWrapper<XcUser> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(XcUser::getEmail, email);
    XcUser xcUser = userMapper.selectOne(wrapper);
    if ( xcUser != null ) {
        throw new RuntimeException("邮箱已被注册,一个账号只能有一个用户");
    }
    XcUser user = new XcUser();
    BeanUtils.copyProperties(registerDto, user);
    user.setPassword(new BCryptPasswordEncoder().encode(password));
    user.setId(id);
    user.setUtype("101001");
    user.setStatus("1");
    user.setName(registerDto.getNickname());
    user.setCreateTime(LocalDateTime.now());
    user.setUpdateTime(LocalDateTime.now());
    int insert = userMapper.insert(user);
    if ( insert <= 0 ) {
        XueChengPlusException.cast("注册失败");
    }
    XcUserRole userRole = new XcUserRole();
    userRole.setUserId(id);
    userRole.setRoleId("17");
    userRole.setId(id);
    userRole.setCreateTime(LocalDateTime.now());
    int insert1 = userRoleMapper.insert(userRole);
    if ( insert1 <= 0 ) {
        XueChengPlusException.cast("注册失败");
    }
}
```

### 3. 问题整理

1. Spring Security问题:

```java
@ApiOperation(value = "修改密码", tags = "修改密码")
@RequestMapping("/findpassword")
public void verifyCode(@RequestBody FindPswDto findPswDto) {
    log.info("修改密码:{}", findPswDto);
    verifyService.findPassword(findPswDto);
}

@ApiOperation(value = "注册", tags = "注册")
@RequestMapping("/register")
public void register(@RequestBody RegisterDto registerDto) {
    verifyService.register(registerDto);
}
```

这部分api接口一开始发送请求无论何种内容均会被返回403(Forbidden)

原因和`Spring Security`有关

在WebSecurityConfig中

原安全拦截机制代码如下:

```java
//配置安全拦截机制
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
        .authorizeRequests()
        .antMatchers("/r/**").authenticated()//访问/r开始的请求需要认证通过
        .anyRequest().permitAll()//其它请求全部放行
        .and()
        .formLogin().successForwardUrl("/login-success");//登录成功跳转到/login-success
    http.logout().logoutUrl("/logout");//退出地址
}
```

修改后的安全拦截机制如下:

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
        .csrf().disable()
        .authorizeRequests()
        .anyRequest().permitAll()
        .and()
        .formLogin().successForwardUrl("/login-success");
}
```

可以看到`csrf().disable()`，我们让csrf失效使得注册和找回密码需求可以正常运行

2. redis缓存提前删除

```java
public Boolean verify(String email, String checkcode) {
    // 1. 从redis中获取缓存的验证码
    String codeInRedis = redisTemplate.opsForValue().get(email);
    // 2. 判断是否与用户输入的一致
    if ( codeInRedis != null && codeInRedis.equalsIgnoreCase(checkcode) ) {
        redisTemplate.delete(email);
        return true;
    }
    return false;
}
```

`redisTemplate.delete(email);`由于在调用`verify`方法的方法中后续插入数据库可能导致失败，但是这步却成功了，导致删除了验证码却无法成功注册，只能重新生成验证码，可以考虑在结尾删除验证码

3. SMTP泄露

首先感谢Git邮件提醒

![image-20240305091312405](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240305091312405.png)、

解决方法就是通过nacos发布配置替代硬编码

#### 3.1 在nacos发布配置

```yaml
spring:
  mail:
    host: smtp.**.com
    port: **
    username: *********@163.com
    password: CZL**********XNY
```

#### 3.2 设置配置读取配置类

```java
@Configuration
public class MailSendConfigProperties {


    @Value(value = "${spring.mail.host}")
    public String host;

    @Value(value = "${spring.mail.port}")
    public String port;

    @Value(value = "${spring.mail.username}")
    public String username;

    @Value(value = "${spring.mail.password}")
    public String password;
}
```

`@Configuration`即可，不用其他注解。

#### 3.3 工具类修改

```java
@Component
public class MailUtil {

    @Autowired
    private MailSendConfigProperties mailProperties;

    private static MailSendConfigProperties MailProperties;
    //提前读取配置文件
    @PostConstruct
    public void init(){
        //        System.out.println("mailProperties.host = " + mailProperties.host);
        //        System.out.println("mailProperties.port = " + mailProperties.port);
        //        System.out.println("mailProperties.username = " + mailProperties.username);
        //        System.out.println("mailProperties.password = " + mailProperties.password);
        MailProperties = mailProperties;
    }

    public static void main(String[] args) throws MessagingException {
        //可以在这里直接测试方法，填自己的邮箱即可
        sendTestMail(MailProperties.host, achieveCode());
    }
    ...
}
```

- 首先将工具类加入`@Component`使得其可以进行自动注入

- 然后注入配置类并设置一个静态配置类

- 设置`init()`方法然后加上`@PostConStruct`注解使得其能在静态方法前加载完成

- 用`@PostConStruct`一定要在`bootstrap.yml`文件开启配置

  ```yaml
  spring:
    main:
  	allow-bean-definition-overriding: true
  ```

  

