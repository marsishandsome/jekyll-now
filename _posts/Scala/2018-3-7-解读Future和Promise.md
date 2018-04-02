---
layout: post
title: 解读Future和Promise
category: Scala
---
Future和Promise的概念早在1977年就已经提出来了。

Future是一个只读的占位符，它的值在未来某个时刻会被计算出来；
Promise是一个可写的容器，可以设置Future的值  。

### Future in Java
Future最早出现在Java5中，这个Future功能非常简单，只能通过轮询的方式进行查询；
Google Guava中实现了ListenableFuture，提供addListener和addCallback的方式进行回调；
Java8中实现了CompletableFuture，提供了比较完整的Future支持。

##### Java5: Future
- [api](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html)

Java5中的Future只提供了主动查询的接口，功能非常弱。
```java
interface Future<V> {
  boolean cancel(boolean mayInterruptIfRunning);
  boolean isCancelled();
  boolean isDone();
  V get() throws InterruptedException, ExecutionException;
}
```

##### Guava: ListenableFuture
- [guava](https://code.google.com/p/guava-libraries/wiki/ListenableFutureExplained)
- [api](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/util/concurrent/ListenableFuture.html)

Guava的ListenableFuture继承自Future，可以通过addListener函数添加Listener。

```java
interface ListenableFuture<V> extends Future<V> {
  void addListener(Runnable listener, Executor executor);
}
```

Guava还提供了一些Future的Util函数:
- addCallback: 可以在ListenerFuture上添加Callback
- transform:   可以把一个ListenerFuture通过一个Function变成另外一个ListenerFuture

```java
class Futures {
  public static <V> void addCallback(ListenableFuture<V> future,
                   FutureCallback<? super V> callback);

  public static <I,O> ListenableFuture<O> transform(ListenableFuture<I> input,
                   Function<? super I,? extends O> function);
  ...
}
```

Promise在Guava中对应于SettableFuture，可以通过set和setException函数设置Future的值

```java
class SettableFuture<V> implements ListenableFuture<V> {
  public boolean set(@Nullable V value);
  public boolean setException(Throwable throwable)
}
```


##### Java8: CompletableFuture
- [jdk1.8](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html)

Java8中新增了CompletableFuture，是Future和Promise的结合：
- 生产者可以通过complete和completeExceptionally函数设置Future的值
- 消费者可以通过addListener函数添加Listener

CompletableFuture还提供一些方便使用的函数：
- thenApply:     当Future执行完成后，调用后续的Future
- thenCombine:   合并两个Future
- exceptionally: 当Future的执行抛出异常时，调用函数fn

```java
class CompletableFuture<T> {
  public boolean complete(T value);

  public boolean completeExceptionally(Throwable ex)

  public <U> CompletableFuture<U> thenApply(Function<? super T,? extends U> fn);

  public <U,V> CompletableFuture<V> thenCombine(CompletionStage<? extends U> other,
                                BiFunction<? super T,? super U,? extends V> fn)

  public CompletableFuture<T> exceptionally(Function<Throwable,? extends T> fn)
  ...
}
```

### Future In Scala
- [future api](http://www.scala-lang.org/api/current/#scala.concurrent.Future)
- [promise api](http://www.scala-lang.org/api/current/#scala.concurrent.Promise)
- [Futures and Promises](http://docs.scala-lang.org/overviews/core/futures.html)

Scala中的Future和Promise是分开实现，提供的接口非常丰富。

```scala
trait Future[T] {
  //轮询接口
  def isCompleted: Boolean

  //回调函数接口
  def onComplete(callback: Try[T] => Unit)(implicit executor: ExecutorContext): Unit
  def onSuccess[U](pf: PartialFunction[T, U])(implicit executor: ExecutionContext): Unit
  def onFailure[U](pf: PartialFunction[Throwable, U])(implicit executor: ExecutionContext): Unit

  //andThen接口
  def andThen[U](pf: PartialFunction[Try[T], U])(implicit executor: ExecutionContext): Future[T]

  //transform接口
  def filter(p: T => Boolean): Future[T]
  def flatMap[U](f: T => Future[S]): Future[S]
  def map[U](f: T => U): Future[U]

  //错误处理接口
  def recoverWith(f: PartialFunction[Throwable, Future[T]]): Future[T]
}

trait Promise {
  def future: Future[T]

  def complete(result: Try[T]): Unit
  def tryComplete(result: Try[T]): Boolean
  def success(value: T): Unit
  def failure(t: Throwable): Unit
}
```

### Future In C++11
- [future api](http://en.cppreference.com/w/cpp/thread/future)
- [promise api](http://en.cppreference.com/w/cpp/thread/promise)

C++11中的future非常简单，和java5中的Future类似，只能轮询或者阻塞等待，没有提供回调函数：

```cpp
template<class T> class future {
  T get();
  bool valid() const;
  void wait() const;
  ...
}
```

C++11中的promise比较完整（因为promise本身比较简单）：

```cpp
template< class R > class promise {
  std::future<T> get_future();
  void set_value( const R& value );
  void set_exception( std::exception_ptr p );
  ...
}
```

### References
- [Wikipedia](https://en.wikipedia.org/wiki/Futures_and_promises)
- [深入浅出Future Pattern](http://www.wuzesheng.com/?p=2485)
- [Java8 中的纯异步编程](http://www.tuicool.com/articles/ABVV3q)
- [Java中使用CompletableFuture处理异步超时](http://www.xker.com/page/e2015/06/198145.html)
- [Scalable Component Abstractions](http://lampwww.epfl.ch/~odersky/papers/ScalableComponent.pdf)
- [RxScala Github](https://github.com/ReactiveX/RxScala)
- [Twitter: Concurrent Programming with Futures](http://twitter.github.io/finagle/guide/Futures.html)
- [Twitter: Effective Scala](http://twitter.github.io/effectivescala/index.html)
