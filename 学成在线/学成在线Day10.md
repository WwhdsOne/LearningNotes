

# 学成在线Day10



# JWT

## 普通令牌的问题

客户端申请到令牌，接下来客户端携带令牌去访问资源，

到资源服务器将会校验令牌的合法性。

资源服务器如何校验令牌的合法性？

我们以OAuth2的密码模式为例进行说明：

![image-20240301171801030](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240301171801030.png)

从第4步开始说明：

1、客户端携带令牌访问资源服务获取资源。

2、资源服务远程请求认证服务校验令牌的合法性

3、如果令牌合法资源服务向客户端返回资源。

这里存在一个问题：

就是校验令牌需要远程请求认证服务，客户端的每次访问都会远程校验，执行性能低。

如果能够让资源服务自己校验令牌的合法性将省去远程请求认证服务的成本，提高了性能。如下图：

![image-20240301171855970](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240301171855970.png)

如何解决上边的问题，实现资源服务自行校验令牌。

令牌采用JWT格式即可解决上边的问题，用户认证通过后会得到一个JWT令牌，JWT令牌中已经包括了用户相关的信息，客户端只需要携带JWT访问资源服务，资源服务根据事先约定的算法自行完成令牌校验，无需每次都请求认证服务完成授权。

## 什么是JWT

JSON Web Token（JWT）是一种使用JSON格式传递数据的网络令牌技术，它是一个开放的行业标准（RFC 7519），它定义了一种简洁的、自包含的协议格式，用于在通信双方传递json对象，传递的信息经过数字签名可以被验证和信任，它可以使用HMAC算法或使用RSA的公钥/私钥对来签名，防止内容篡改。官网：https://jwt.io/

使用JWT可以实现无状态认证。

```java
package com.xuecheng.auth.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.provider.token.AuthorizationServerTokenServices;
import org.springframework.security.oauth2.provider.token.DefaultTokenServices;
import org.springframework.security.oauth2.provider.token.TokenEnhancerChain;
import org.springframework.security.oauth2.provider.token.TokenStore;
import org.springframework.security.oauth2.provider.token.store.InMemoryTokenStore;
import org.springframework.security.oauth2.provider.token.store.JwtAccessTokenConverter;
import org.springframework.security.oauth2.provider.token.store.JwtTokenStore;

import java.util.Arrays;

/**
 * @author Administrator
 * @version 1.0
 **/
@Configuration
public class TokenConfig {

    private String SIGNING_KEY = "mq123";

    @Autowired
    TokenStore tokenStore;

//    @Bean
//    public TokenStore tokenStore() {
//        //使用内存存储令牌（普通令牌）
//        return new InMemoryTokenStore();
//    }

    @Autowired
    private JwtAccessTokenConverter accessTokenConverter;

    @Bean
    public TokenStore tokenStore() {
        return new JwtTokenStore(accessTokenConverter());
    }

    @Bean
    public JwtAccessTokenConverter accessTokenConverter() {
        JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
        converter.setSigningKey(SIGNING_KEY);
        return converter;
    }

    //令牌管理服务
    @Bean(name="authorizationServerTokenServicesCustom")
    public AuthorizationServerTokenServices tokenService() {
        DefaultTokenServices service=new DefaultTokenServices();
        service.setSupportRefreshToken(true);//支持刷新令牌
        service.setTokenStore(tokenStore);//令牌存储策略

        TokenEnhancerChain tokenEnhancerChain = new TokenEnhancerChain();
        tokenEnhancerChain.setTokenEnhancers(Arrays.asList(accessTokenConverter));
        service.setTokenEnhancer(tokenEnhancerChain);

        service.setAccessTokenValiditySeconds(7200); // 令牌默认有效期2小时
        service.setRefreshTokenValiditySeconds(259200); // 刷新令牌默认有效期3天
        return service;
    }
}

```

申请令牌http测试：

```http
POST {{auth_host}}/oauth/token?client_id=XcWebApp&client_secret=XcWebApp&grant_type=password&username=zhangsan&password=123
```

## 测试资源服务校验令牌

拿到了jwt令牌下一步就要携带令牌去访问资源服务中的资源，本项目各个微服务就是资源服务

在内容管理服务的content-api工程中添加依赖

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-oauth2</artifactId>
</dependency>
```

http请求携带jwt令牌访问课程信息

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsi...
```

注意`Authorization: Bearer`是规定用来校验的字段，jwt令牌过长结尾省略

## 测试获取用户身份

```java
@ApiOperation("根据课程id查询课程基础信息")
@GetMapping("/course/{courseId}")
public CourseBaseInfoDto getCourseBaseById(@PathVariable("courseId") Long courseId){
    //取出当前用户身份
    //SecurityContextHolder底层就是ThreadLocal
    Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    System.out.println(principal);
    return courseBaseInfoService.getCourseBaseInfo(courseId);
}
```

# 网关认证

## 技术方案

到目前为止，测试通过了认证服务颁发jwt令牌，客户端携带jwt访问资源服务，资源服务对jwt的合法性进行验证。如下图：

![image-20240301180738561](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240301180738561.png)

仔细观察此图，遗漏了本项目架构中非常重要的组件：网关，加上网关并完善后如下图所示：

![image-20240301180755266](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240301180755266.png)

所有访问微服务的请求都要经过网关，在网关进行用户身份的认证可以将很多非法的请求拦截到微服务以外，这叫做网关认证。

下边需要明确网关的职责：

1、网站白名单维护

针对不用认证的URL全部放行。

2、校验jwt的合法性。

除了白名单剩下的就是需要认证的请求，网关需要验证jwt的合法性，jwt合法则说明用户身份合法，否则说明身份不合法则拒绝继续访问。

网关负责授权吗？

网关不负责授权，对请求的授权操作在各个微服务进行，因为微服务最清楚用户有哪些权限访问哪些接口。

## 实现网关认证

实现以下职责：

1、网站白名单维护

针对不用认证的URL全部放行。

2、校验jwt的合法性。

除了白名单剩下的就是需要认证的请求，网关需要验证jwt的合法性，jwt合法则说明用户身份合法，否则说明身份不合法则拒绝继续访问。

网关工程依赖：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-oauth2</artifactId>
</dependency>
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
</dependency>
```

配置白名单文件security-whitelist.properties

```properties
/**=\u4E34\u65F6\u5168\u90E8\u653E\u884C
/auth/**=\u8BA4\u8BC1\u5730\u5740
/content/open/**=\u5185\u5BB9\u7BA1\u7406\u516C\u5F00\u8BBF\u95EE\u63A5\u53E3
/media/open/**=\u5A92\u8D44\u7BA1\u7406\u516C\u5F00\u8BBF\u95EE\u63A5\u53E3
```

导入了四个文件，其中最重要的的是GatewayAuthFilter

其内部过滤器比较重要

过滤器代码

```java
@Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String requestUrl = exchange.getRequest().getPath().value();
        AntPathMatcher pathMatcher = new AntPathMatcher();
        //白名单放行
        for (String url : whitelist) {
            if (pathMatcher.match(url, requestUrl)) {
                return chain.filter(exchange);
            }
        }

        //检查token是否存在
        String token = getToken(exchange);
        if (StringUtils.isBlank(token)) {
            return buildReturnMono("没有认证",exchange);
        }
        //判断是否是有效的token
        OAuth2AccessToken oAuth2AccessToken;
        try {
            oAuth2AccessToken = tokenStore.readAccessToken(token);

            boolean expired = oAuth2AccessToken.isExpired();
            if (expired) {
                return buildReturnMono("认证令牌已过期",exchange);
            }
            return chain.filter(exchange);
        } catch (InvalidTokenException e) {
            log.info("认证令牌无效: {}", token);
            return buildReturnMono("认证令牌无效",exchange);
        }

    }
```

网关的三个主要功能：

1. 提供路由功能
2. 提供白名单
3. 校验jwt`合法性`

# 用户认证

## 需求分析

至此我们了解了使用Spring Security进行认证授权的过程，本节实现用户认证功能。

目前各大网站的认证方式非常丰富：账号密码认证、手机验证码认证、扫码登录等。

本项目也要支持多种认证

## 连接用户中心数据库

### 连接数据库认证

基于的认证流程在研究Spring Security过程中已经测试通过，到目前为止用户认证流程如下：

![image-20240302100509537](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240302100509537.png)

认证所需要的用户信息存储在用户中心数据库，现在需要将认证服务连接数据库查询用户信息。

在研究Spring Security的过程中是将用户信息硬编码

我们要认证服务中连接用户中心数据库查询用户信息。

如何使用Spring Security连接数据库认证吗？

前边学习Spring Security工作原理时有一张执行流程图，如下图：

![image-20240302100805726](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240302100805726.png)

用户提交账号和密码由DaoAuthenticationProvider调用UserDetailsService的loadUserByUsername()方法获取UserDetails用户信息。

UserDetailService是一个接口：

```java
package org.springframework.security.core.userdetails;

public interface UserDetailsService {
    UserDetails loadUserByUsername(String var1) throws UsernameNotFoundException;
}
```

UserDetails是用户信息接口:

```java
public interface UserDetails extends Serializable {
    Collection<? extends GrantedAuthority> getAuthorities();

    String getPassword();

    String getUsername();

    boolean isAccountNonExpired();

    boolean isAccountNonLocked();

    boolean isCredentialsNonExpired();

    boolean isEnabled();
}

```

我们只要实现UserDetailsService 接口查询数据库得到用户信息返回UserDetails 类型的用户信息即可,框架调用loadUserByUsername()方法拿到用户信息之后是如何执行的，见下图：

![image-20240302103505430](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240302103505430.png)

首先屏蔽原有的UserService

然后新建软件包写下如下内容:


```java
public class UserServiceImpl implements UserDetailsService {

    //用户中心dao层
    @Autowired
    XcUserMapper xcUserMapper;

    @Override
    public UserDetails loadUserByUsername(String s) throws UsernameNotFoundException {
        //查询数据库
        XcUser xcUser = xcUserMapper.selectOne(new LambdaQueryWrapper<XcUser>().eq(XcUser::getUsername, s));

        //查询用户不存在,返回null即可,spring security同时抛出异常提示用户不存在
        if ( xcUser == null ) {
            return null;
        }
        //如果查到了正确的用户拿到了正确的密码,返回UserDetails对象给spring security框架,由框架进行密码比对
        String password = xcUser.getPassword();
        //权限
        String[] authorities = {"test"};
        UserDetails userDetails = User
                .builder()
                .username(xcUser.getUsername())
                .password(password)
                .authorities(authorities).build();
        return userDetails;
    }
}
```

数据库中的密码加过密的，用户输入的密码是明文，我们需要修改密码格式器PasswordEncoder，原来使用的是NoOpPasswordEncoder，它是通过明文方式比较密码，现在我们修改为BCryptPasswordEncoder，它是将用户输入的密码编码为BCrypt格式与数据库中的密码进行比对。

```java
public static void main(String[] args) {
        String password = "123456";
        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        //生成密码
        for ( int i = 0; i < 5; i++ ) {
            String encode = passwordEncoder.encode(password);
            System.out.println(encode);
            System.out.println(passwordEncoder.matches(password, encode));
        }
    }
```

修改数据库中的密码为Bcrypt格式，并且记录明文密码，稍后申请令牌时需要。

由于修改密码编码方式还需要将客户端的密钥更改为Bcrypt格式.

在AuthorizationServer中修改

### **扩展用户身份信息**

我们需要扩展用户身份的信息，在jwt令牌中存储用户的昵称、头像、qq等信息。

如何扩展Spring Security的用户身份信息呢？

在认证阶段DaoAuthenticationProvider会调用UserDetailService查询用户的信息，这里是可以获取到齐全的用户信息的。由于JWT令牌中用户身份信息来源于UserDetails，UserDetails中仅定义了username为用户的身份信息，这里有两个思路：第一是可以扩展UserDetails，使之包括更多的自定义属性，第二也可以扩展username的内容 ，比如存入json数据内容作为username的内容。相比较而言，方案二比较简单还不用破坏UserDetails的结构，我们采用方案二。

```java
@Override
    public UserDetails loadUserByUsername(String s) throws UsernameNotFoundException {
        //查询数据库
        XcUser xcUser = xcUserMapper.selectOne(new LambdaQueryWrapper<XcUser>().eq(XcUser::getUsername, s));

        //查询用户不存在,返回null即可,spring security同时抛出异常提示用户不存在
        if ( xcUser == null ) {
            return null;
        }
        //如果查到了正确的用户拿到了正确的密码,返回UserDetails对象给spring security框架,由框架进行密码比对
        String password = xcUser.getPassword();
        //权限
        String[] authorities = {"test"};
        xcUser.setPassword(null);
        //将用户信息转json
        String userJson = JSON.toJSONString(xcUser);
        UserDetails userDetails = User
                .builder()
                .username(userJson)
                .password(password)
                .authorities(authorities).build();
        return userDetails;
    }
```

密码置空可以保证安全性

在资源服务中就可以通过`SecurityUtil`工具类获取用户信息

## 支持认证方式多样化

### 统一认证入口

目前各大网站的认证方式非常丰富：账号密码认证、手机验证码认证、扫码登录等。基于当前研究的Spring Security认证流程如何支持多样化的认证方式呢？

1、支持账号和密码认证

采用OAuth2协议的密码模式即可实现。

2、支持手机号加验证码认证

用户认证提交的是手机号和验证码，并不是账号和密码。

3、微信扫码认证

基于OAuth2协议与微信交互，学成在线网站向微信服务器申请到一个令牌，然后携带令牌去微信查询用户信息，查询成功则用户在学成在线项目认证通过。

 

目前我们测试通过OAuth2的密码模式，用户认证会提交账号和密码，由DaoAuthenticationProvider调用UserDetailsService的loadUserByUsername()方法获取UserDetails用户信息。

在前边我们自定义了UserDetailsService接口实现类，通过loadUserByUsername()方法根据账号查询用户信息。

而不同的认证方式提交的数据不一样，比如：手机加验证码方式会提交手机号和验证码，账号密码方式会提交账号、密码、验证码。

我们可以在loadUserByUsername()方法上作文章，将用户原来提交的账号数据改为提交json数据，json数据可以扩展不同认证方式所提交的各种参数。

首先创建一个DTO类表示认证的参数：

```java
@Data
public class AuthParamsDto {

    private String username; //用户名
    private String password; //域  用于扩展
    private String cellphone;//手机号
    private String checkcode;//验证码
    private String checkcodekey;//验证码key
    private String authType; // 认证的类型   password:用户名密码模式类型    sms:短信模式类型
    private Map<String, Object> payload = new HashMap<>();//附加数据，作为扩展，不同认证类型可拥有不同的附加数据。如认证类型为短信时包含smsKey : sms:3d21042d054548b08477142bbca95cfa; 所有情况下都包含clientId
}
```

UserServiceImpl修改如下：

```java
@Override
    public UserDetails loadUserByUsername(String s) throws UsernameNotFoundException {

        AuthParamsDto authParamsDto = null;
        try {
            //将认证参数转为AuthParamsDto类型
            authParamsDto = JSON.parseObject(s, AuthParamsDto.class);
        } catch (Exception e) {
            log.info("认证请求不符合项目要求:{}",s);
            throw new RuntimeException("认证请求数据格式不对");
        }
        //账号
        String username = authParamsDto.getUsername();
        XcUser user = xcUserMapper.selectOne(new LambdaQueryWrapper<XcUser>().eq(XcUser::getUsername, username));
        if(user==null){
            //返回空表示用户不存在
            return null;
        }
        //取出数据库存储的正确密码
        String password  =user.getPassword();
        //用户权限,如果不加报Cannot pass a null GrantedAuthority collection
        String[] authorities = {"p1"};
        //将user对象转json
        String userString = JSON.toJSONString(user);
        //创建UserDetails对象
        UserDetails userDetails = User.withUsername(userString).password(password).authorities(authorities).build();
        return userDetails;
    }
}
```

原来的DaoAuthenticationProvider 会进行密码校验，现在重新定义DaoAuthenticationProviderCustom类，重写类的additionalAuthenticationChecks方法。因为有一些方式，比如`微信扫码`和`手机验证码`**不需要校验密码**，所以我们自定义校验方式

```java
@Slf4j
@Component
public class DaoAuthenticationProviderCustom extends DaoAuthenticationProvider {


    @Autowired
    public void setUserDetailsService(UserDetailsService userDetailsService) {
        super.setUserDetailsService(userDetailsService);
    }


    //屏蔽密码对比
    protected void additionalAuthenticationChecks(UserDetails userDetails, UsernamePasswordAuthenticationToken authentication) throws AuthenticationException {


    }

}
```

在WebSecurityConfig中注入DaoAuthenticationProviderCustom

```java
@Autowired
DaoAuthenticationProviderCustom daoAuthenticationProviderCustom;


@Override
protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    auth.authenticationProvider(daoAuthenticationProviderCustom);
}

```

此时可以重启认证服务，测试申请令牌接口，传入的账号信息改为json数据，如下：

```http
################扩展认证请求参数后######################
###密码模式
POST {{auth_host}}/auth/oauth/token?client_id=XcWebApp&client_secret=XcWebApp&grant_type=password&username={"username":"stu1","authType":"password","password":"111111"}

```

定义统一认证接口

```java
public interface AuthService {

   /**
    * @description 认证方法
    * @param authParamsDto 认证参数
    * @return com.xuecheng.ucenter.model.po.XcUser 用户信息
    * @author Mr.M
    * @date 2022/9/29 12:11
   */
   XcUserExt execute(AuthParamsDto authParamsDto);

}
```

定义账号密码认证接口：

```java
@Service("password_authService")
public class PasswordAuthServiceImpl implements AuthService {
    @Override
    public XcUserExt execute(AuthParamsDto authParamsDto) {
        return null;
    }
}
```

定义微信扫码认证接口：

```java
@Service("wx_authService")
public class WxAuthServiceImpl implements AuthService {
    @Override
    public XcUserExt execute(AuthParamsDto authParamsDto) {
        return null;
    }
}
```

### 实现账号密码认证

账号密码实现类代码如下：

```java
@Override
    public XcUserExt execute(AuthParamsDto authParamsDto) {
        //账号
        String username = authParamsDto.getUsername();

        //验证码 TODO


        //查询数据库
        XcUser xcUser = xcUserMapper.selectOne(new LambdaQueryWrapper<XcUser>().eq(XcUser::getUsername, username));

        //查询用户不存在,返回null即可,spring security同时抛出异常提示用户不存在
        if ( xcUser == null ) {
            throw new RuntimeException("账号不存在");
        }
        //验证密码是否正确
        //如果查到了正确的用户拿到了正确的密码,返回UserDetails对象给spring security框架,由框架进行密码比对
        //数据库密码
        String passwordDB = xcUser.getPassword();
        //用户输入密码
        String passwordForm = authParamsDto.getPassword();

        boolean matches = passwordEncoder.matches(passwordForm, passwordDB);
        if ( !matches ) {
            throw new RuntimeException("账号或密码错误");
        }
        XcUserExt xcUserExt = new XcUserExt();
        BeanUtils.copyProperties(xcUser, xcUserExt);
        return xcUserExt;
    }
```

## 验证码服务

### 验证码作用

在认证时一般都需要输入验证码，验证码有什么用？

验证码可以防止恶性攻击，比如：XSS跨站脚本攻击、CSRF跨站请求伪造攻击，一些比较复杂的图形验证码可以有效的防止恶性攻击。

为了保护系统的安全在一些比较重要的操作都需要验证码。

### **验证码接口测试**

验证码服务对外提供的接口有：

1、生成验证码

2、校验验证码。

如下：

![image-20240302122054930](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240302122054930.png)

验证码服务如何生成并校验验证码？

拿图片验证码举例：

1、先生成一个指定位数的验证码，根据需要可能是数字、数字字母组合或文字。

2、根据生成的验证码生成一个图片并返回给页面

3、给生成的验证码分配一个key，将key和验证码一同存入缓存。这个key和图片一同返回给页面。

4、用户输入验证码，连同key一同提交至认证服务。

5、认证服务拿key和输入的验证码请求验证码服务去校验

6、验证码服务根据key从缓存取出正确的验证码和用户输入的验证码进行比对，如果相同则校验通过，否则不通过。

![image-20240302122129225](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240302122129225.png)

1、生成验证码接口

```http
### 申请验证码
POST {{checkcode_host}}/checkcode/pic
```

2、校验验证码接口

根据生成验证码返回的key以及日志中输出正确的验证码去测试。

```http
### 校验验证码
POST {{checkcode_host}}/checkcode/verify?key=checkcode4506b95bddbe46cdb0d56810b747db1b&code=70dl
```

