---
title: iOS面试整理
date: 2018-05-24 18:44:52
tags: [杂谈, 技术]
category: 杂谈
toc: true
mathjax: true
---



## 面试知识点整理

### 1. 强连通分量（向量图相关）

涉及Tarjan算法，Kosaraju算法。

定义：

有向图强连通分量：

在有向图G中，如果两个顶点间至少存在一条路径，称两个顶点强连通（strongly connected）。

如果有向图G的每两个顶点都强连通，则称G是一个强连通图。

非强连通图有向图的极大强连通子图，成为强连通分量（strongly connected components）。

---

#### 2. TableView卡顿优化

1. Cell重用机制

2. 避免Cell重新布局

3. 提前计算，缓存Cell属性等

4. 减少Cell中控件数量

5. 局部更新

6. 避免透明颜色，圆角等离屏渲染

7. 不做多余的绘制工作：在实现drawRect:的时候，它的rect参数就是需要绘制的区域，这个区域之外的不需要进行绘制。例如上例中，就可以用CGRectIntersectsRect、CGRectIntersection或CGRectContainsRect判断是否需要绘制image和text，然后再调用绘制方法。

8. 预渲染图像。当新的图像出现时，仍然会有短暂的停顿现象。解决的办法就是在bitmap context里先将其画一遍，导出成UIImage对象，然后再绘制到屏幕；

---

#### 3. M、V、C相互通信规则

Controller 通知 Model 更新。View 从 Controller 获取数据展示（DataSource）。View 响应操作通知 Controller 更新Model （Delegate）

---

#### 4. NSTimer 准吗？如何实现一个精准的Timer？

不准。

原因：**NSTimer**是使用时，需要添加到 **MainRunLoop** 中，添加之后在会得到**RunLoop**的反复调用，但是在**RunLoop**中还有非常多的UI计算等等的操作，不能确保精准地调用到**NSTimer**。

并且添加**Timer**的时候还有选择**Mode**一说。不在对应的**Mode**下，**Timer**是不会被调用的。（ScrollView的TrackingModel）

如何实现一个精准的NSTimer：

方法1：添加到特定的Mode

方法2：在子线程中使用，每创建一个线程，都能获取到当前线程的RunLoop。子线程的RunLoop中的操作明显比MainRunLoop中的少，可以提高Timer的精度。

方法3：使用mach内核级的函数进行实现。

方法4：GCD替代。

---

#### 5. 编译过程做了什么事情？

复习编译过程！！！

1、C++，Objective-C都是编译语言，程序需要执行都需要经过编译过程生成对应的机器码，直接执行在对应的CPU上，执行效率极高。

2、编译过程中，不管是OC还是Swift，都是采用Clang作为编译前端，LLVM（Low-Level-Virtual-Machine）作为编译后端。

- 编译前端：编译前端的任务为：语义分析，语法分析，生成AST，中间代码（Intermediate Representation）。在这个过程中，会进行类型检查，同时报出相应的错误和警告。

- 编译器后端：编译器后端会进行相关的代码优化。

- LLVM优化器会进行BitCode的生成，链接期优化等等。根据不同的架构（i386，x86，arm64）生成对应不同的机器码。

3、执行一次xcode-build的流程：

1. 编译信息写入辅助文件，创建编译后的文件架构（xxx.app）

2. 处理打包信息，bundleid，证书信息之类的

3. 执行编译命令

---

#### 6. 字典的大致实现原理

字典底层使用的是哈希表实现的一个key-value的一个映射关系。

哈希的实现：假设有一个数组具备 n 个元素位置，计算 key 的hash值 （key % n）得到放在 第 i 个箱子内，如果该位置已经存在键值对了，则采用 **拉链法** 或者 **开放寻址法** 进行定位，解决冲突。

复习内容：开放寻址法，拉链法。

哈希表的一个重要属性 负载因子（Load factor，（键值对个数 / 箱子总数）），用来衡量哈希表的装载程度，一定程度上体现查询效率。

当达到某个程度时候（一般会以某个常量来表示，可能是1，或者0.75），哈希表会自动扩容，一般会是之前的2倍，扩容后，哈希表会对当前元素进行一次重新定位（rehash）这时候耗费的性能是比较大的。

---

#### 7. Block 和函数指针的理解

相同点：都是可以看做是一个代码片段，可以实现方法调用，预定义操作。

不同点：

- 函数指针是静态编译的，通过别的文件定义好，编译时期将确定好函数地址。只能访问全局变量以及传入的参数

- Block的本质是一个Objective-C对象，可以接受消息。还能访问当前堆栈的变量，如果通过__block修饰的变量，还具备修改能力。

---

#### 8. 一般一开始做一个项目，你的架构是如何思考的？

[参考文章](https://casatwy.com/iosying-yong-jia-gou-tan-viewceng-de-zu-zhi-he-diao-yong-fang-an.html)

##### 架构是什么

首先架构应该属于一个规范，它并不是一个具体代码集合，应该是开发人员的开发指导指南。它具备让开发人员更加高效，更加复合高内聚，低耦合的开发的能力。并且开发出来的代码应该具备可修改性，高可维护性。

##### 1、View 层结构

代码规范，生命周期等，是否需要基类等。

##### 2、 网络层

网络层基本是异步调用，考虑回调机制（block，delegate，notification，target-action）。

- block回调开发效率高，但是debug定位难度高。

- delegate回调开发效率有所降低，但是在架构设计层面应该使用delegate。

- target-action回调理论上本人认为和delegate几乎相同。

- notification回调不建议，充斥这大量的通知，影响范围不可控，理论上来说进程内都能监听。

网络层设计思想 **集约型** 还是 **离散型**

- 集约型设计让网络请求和业务回调集约，也就是说通常每个网络请求都会有不同的回调。通畅使用block实现

- 离散型设计让网络请求和业务回调分离，让代码更加简洁明了。

以什么形式交付数据给业务层

- 常见模式是把接受到的json数据直接转换成对应的Bean模型，

- 另一种是新增一种对象，此对象只接受网络回来的json对象，从而根据不同的应用场景，写对应的转换器。

网络缓存

##### 3、持久化层

数据存储方案（库实现）。

持久层与业务层交互方案（Service -> Dao 暴露友好接口）。

数据与服务器的同步方案（单向同步，双向同步）。

##### 4、组件化设计

推崇微服务设计。

生命周期分发，模块划分。

跨模块调用方案，路由设计。

业务结构分层。

辅助工具脚本。

---

#### 9. OC的锁相关问题

1、你了解的锁有那些（自旋锁，互斥锁），使用的注意点，如果自己实现，如何实现？

- OSSpinLock：不再安全。主要原因发生在低优先级线程拿到锁时，高优先级线程进入忙等(busy-wait)状态，消耗大量 CPU 时间，从而导致低优先级线程拿不到 CPU 时间，也就无法完成任务并释放锁。这种问题被称为优先级反转。

  ```c
    // 自己实现一个自旋锁，这个方法，会被编译成一行的汇编命令，所以是原子性的
  BOOL test_and_set(BOOL *lock) {
          BOOL temp = *lock;
      *lock = YES;
      return temp;
  }
  
  BOOL lock = NO;
  void test() {
          while (test_and_set(&lock)) {
      // let it spin
      }
      // do your business
      lock = NO;
  }
  ```

- dispatch_semaphore_t 信号量：由GCD实现调用 wait 和 signal 方法来控制线程。

- pthread_mutex互斥锁：实现与信号量相似，当时提供了recursive lock的机制。

- NSLock：内部封装了pthread_mutex。

- NSCondition：内部使用了pthread_cond_t，pthread\_cond\_t 需要和pthread_mutex_t 配合使用。

- NSConditionLock：

- NSRecursiveLock：

- @synchronized：通过后面的对象的hash值实现的。

自旋锁和互斥锁的区别：

- 自旋锁线程不会挂起，取而代之的是一直尝试去获取锁，当锁被释放了，马上能进入锁状态
- 互斥锁将线程挂起（睡眠），有等待唤起操作，性能比自旋锁慢

2、内存泄露可能会出现的几种原因，聊聊你的看法？

内存泄露的原因：

1. ARC下循环引用。

2. MRC下的未release，以及循环引用。

3. 非OC对象为指针未free。

4. NSTimer的强引用Target。

- 非OC对象如何处理？

- 地图内存若泄露，如何处理？

- 常用框架内存泄露，如何处理？

3、容错处理一般怎么做？如何防止拦截潜在的崩溃？
