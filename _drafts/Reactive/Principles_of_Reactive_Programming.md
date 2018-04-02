# Principles of Reactive Programming
- by Martin Odersky, Erik Meijer, Roland Kuhn
- [Coursera Link](https://class.coursera.org/reactive-002/auth)

# Week 1
### Collections
Translation of For:
1. map
```
for (x <- e1) yield e2
==>
e1.map(x => e2)
```
2. withFilter
```
for (x <- e1 if f; s) yield e2
==>
for (x <- e1.withFilter(x => f); s) yield e2
```
3. flatMap
```
for (x <- e1; y <- e2; s) yield e3
==>
e1.flatMap(x => for(y <- e2; s) yield e3)
```

### Functional Random Generators
Generator
```
trait Generator[+T] {
  def generate: T
}

val integers = new Generator[Int] {
  val rand = new java.util.Random
  def generate = rand.nextInt()
}

val booleans = new Generator[Boolean] {
  def generate = integers.generate > 0
}

val pairs = new Generator[(Int, Int)] {
  def generate = (integers.generate, integers.generate)
}
```

Streamlining
```
val booleans = for (x <- integers) yield x > 0
def pairs[T, U](t: Generator[T], u: Generator[U]) = for {
  x <- t
  y <- u
} yield (x, y)
```

Generator with map and flatMap
```
trait Generator[+T] {
  self =>
  def generate: T
  def map[S](f: T => S): Generator[S] = new Generator[S] {
    def generate = f(self.generate)
  }
  def flatMap[S](f: T => Generator[S]): Generator[S] = new Generator[S] {
    def generate = f(self.generate).generate
  }
}
```

### Monads
Monads定义:
```
trait M[T] {
def flatMap[U](f: T => M[U]): M[U]
}
def unit[T](x: T): M[T]
```

map定义:
```
m map f == m flatMap (x => unit(f(x)))
== m flatMap (f andThen unit)
```

Monads三大定律:
1. 结合律
```
m flatMap f flatMap g == m flatMap (x => f(x) flatMap g)
```
2. Left Unit
```
unit(x) flatMap f == f(x)
```
3. Right Unit
```
m flatMap unit == m
```

# Week 2
### Imperative Event Handling: The Observer Pattern
TODO

### Functional Reactive Programming
TODO

### A Simple FRP Implementation
TODO

# Week 3
### Monads and Effects
Try
```
abstract class Try[T] {
  def flatMap[S](f: T=>Try[S]): Try[S]
  def flatten[U <: Try[T]]: Try[U]
  def map[S](f: T=>S): Try[T]
  def filter(p: T=>Boolean): Try[T]
  def recoverWith(f: PartialFunction[Throwable,Try[T]]): Try[T]
}
case class Success[T](elem: T) extends Try[T]
case class Failure(t: Throwable) extends Try[Nothing]
```

Adventure
```
trait Adventure {
  def collectCoins(): Try[List[Coin]]
  def buyTreasure(coins: List[Coin]): Try[Treasure]
}
```

Dealing with failure explicitly
```
val adventure = Adventure()
val coins: Try[List[Coin]] = adventure.collectCoins()
val treasure: Try[Treasure] = coins match {
  case Success(cs) => adventure.buyTreasure(cs)
  case failure@Failure(e) => failure
}
```

Noise reduction: Flatmap
```
val adventure = Adventure()
val treasure: Try[Treasure] =
  adventure.collectCoins().flatMap { coins =>
  adventure.buyTreasure(coins)
}
```

Using comprehension syntax
```
val adventure = Adventure()
val treasure: Try[Treasure] = for {
  coins <- adventure.collectCoins()
  treasure <- buyTreasure(coins)
} yield treasure
```

### Latency as an Effect
Future
```
import scala.concurrent._
import scala.concurrent.ExecutionContext.Implicits.global
trait Future[T] {
def onComplete(callback: Try[T] ⇒ Unit)
    (implicit executor: ExecutionContext): Unit
}

object Future {
  def apply(body: =>T)
      (implicit context: ExecutionContext): Future[T]
}
```

### Combinator on Futures
Future
```
trait Awaitable[T] extends AnyRef {
  abstract def ready(atMost: Duration): Unit
  abstract def result(atMost: Duration): T
}
trait Future[T] extends Awaitable[T] {
  def filter(p: T=>Boolean): Future[T]
  def flatMap[S](f: T=>Future[S]): Future[U]
  def map[S](f: T=>S): Future[S]
  def recoverWith(f: PartialFunction[Throwable, Future[T]]): Future[T]
}
object Future {
  def apply[T](body : =>T): Future[T]
}
```

### Composing Futures
Comprehension
```
val socket = Socket()
val confirmation: Future[Array[Byte]] = for{
  packet <- socket.readFromMemory()
  confirmation <- socket.sendToSafe(packet)
} yield confirmation
```

Retry
```
def retry(noTimes: Int)(block: ⇒Future[T]): Future[T] = {
  if (noTimes == 0) {
    Future.failed(new Exception(“Sorry”))
  } else {
    block fallbackTo {
      retry(noTimes–1){ block }
    }
  }
}
```

foldRight & folderLeft
```
List(a,b,c).foldRight(e)(f) = f(a, f(b, f(c, e)))
List(a,b,c).foldLeft(e)(f)  = f(f(f(e, a), b), c)
```

Retrying to send using foldLeft
```
def retry(noTimes: Int)(block: =>Future[T]): Future[T] = {
  val ns = (1 to noTimes).toList
  val attempts = ns.map(_ => ()=>block)
  val failed = Future.failed(new Exception(“boom”))
  val result = attempts.foldLeft(failed)
  ((a,block) => a recoverWith { block() })
  result
}
```

Retrying to send using foldRight
```
def retry(noTimes: Int)(block: =>Future[T])= {
  val ns = (1 to noTimes).toList
  val attempts: = ns.map(_ => () => block)
  val failed = Future.failed(new Exception)
  val result = attempts.foldRight(() =>failed)
  ((block, a) => () => { block() fallbackTo { a() } })
  result ()
}
```

### Async Await
```
import scala.async.Async._
def async[T](body: =>T) (implicit context: ExecutionContext): Future[T]
def await[T](future: Future[T]): T
```

Reimplementing filter using await
```
def filter(p: T => Boolean): Future[T] = async {
  val x = await { this }
  if (!p(x)) {
    throw new NoSuchElementException()
  } else {
    x
  }
}
```

Reimplementing filter without await
```
def filter(pred: T => Boolean): Future[T] = {
  val p = Promise[T]()
  this onComplete {
    case Failure(e) => p.failure(e)
    case Success(x) =>
      if (!pred(x)) p.failure(new NoSuchElementException)
      else p.success(x)
  }
  p.future
}
```

### Promise, promises
Promises
```
trait Promise[T] {
  def future: Future[T]
  def complete(result: Try[T]): Unit
  def tryComplete(result: Try[T]): Boolean
}

trait Future[T] {
  def onCompleted(f: Try[T] => Unit): Unit
}

def success(value: T): Unit = this.complete(Success(value))

def failure(t: Throwable): Unit = this.complete(Failure(t))
```

Reimplementing zip using Promises
```
def zip[S, R](p: Future[S], f: (T, S) => R): Future[R] = {
  val p = Promise[R]()
  this onComplete {
    case Failure(e) ⇒ p.failure(e)
    case Success(x) ⇒ that onComplete {
      case Failure(e) ⇒ p.failure(e)
      case Success(y) ⇒ p.success(f(x, y))
    }
  }
  p.future
}
```

Reimplementing zip with await
```
def zip[S, R](p: Future[S], f: (T, S) => R): Future[R] = async {
  f(await { this }, await { that })
}
```

Implementing sequence
```
def sequence[T](fts: List[Future[T]]): Future[List[T]] = {
  fts match {
  case Nil => Future(Nil)
  case (ft::fts) => ft.flatMap(t =>
    sequence(fts).flatMap(ts => Future(t::ts)))
  }
}
```

Implementing sequence with await
```
def sequence[T](fs: List[Future[T]]): Future[List[T]] = async {
  var _fs = fs
  val r = ListBuffer[T]()
  while (_fs != Nil) {
    r += await { _fs.head }
    _fs = _fs.tail
  }
  r.toList
}
```

Implement sequence with Promise
```
def sequence[T](fs: List[Future[T]]): Future[List[T]] = {
  val p = Promise[List[T]]()
  ???
  p.future
}
```

# Week 4
### From Try to Future
Future[T] and Try[T] are dual
```
trait Future[T] {
  def onComplete(func: Try[T] => Unit)
  (implicit ex: ExecutionContext): Unit
}

Future[T]:    (Try[T] => Unit) => Unit

reverse:      Unit => (Unit => Try[T])
              () => (() => Try[T])
              Try[T]
```

### From Iterables to Observables
```
def Iteratable[T] { def iterator(): Iterator[T] }

def Iterator[T] { def hasNext: Boolean; def next(): T }
```

```
type Iteratable[T] = () => ( ()=>Try[Option[T]] )

type Observable[T] = (Try[Option[T]] => Unit) => Unit

```

# Week 5
### Why Actors?
- blocking synchronization introduces dead-locks
- blocking is bad for CPU utilization
- synchronous communication couples sender and receiver

### The Actor Model
```
type Receive = PartialFunction[Any, Unit]

trait Actor {
  implicit val self: ActorRef
  def sender: ActorRef
  implicit val context: ActorContext

  def receive: Receive
}

abstract class ActorRef {
  def !(msg: Any)(implicit sender: ActorRef = Actor.noSender): Unit
  def tell(msg: Any, sender: ActorRef) = this.!(msg)(sender)
}

trait ActorContext {
  def become(behavior: Receive, discardOld: Boolean = true): Unit
  def unbecome(): Unit
  def actorOf(p: Props, name: String): ActorRef
  def stop(a: ActorRef): Unit
}
```

### Message Passing Semantics
An actor is effectively single-threaded:
- messages are received sequentially
- behavior change is effective before processing the next message
- processing one message is the atomic unit of execution


# Week 6
### Failure Handling with Acots
### Lifecycle Monitoring and the Error Kernel
### Persistent Actor State


# Week 7
### Actors are Distributed
### Eventual Consistency
### Actor Composition
### Scalability
### Responsiveness
