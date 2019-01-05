翻译原文来自于https://stackoverflow.com/questions/100003/what-are-metaclasses-in-python 一个高赞回答

**

## 类是一种对象

**

在说明元类之前，我们需要先掌握什么是类。Python对于类的定义很特别，借鉴了smalltalk语言。
包括Python在内的大多数语言中，类只是一段描述如何创建对象的代码。

    class ObjectCreator(object):
        pass
    my_object = ObjectCreator()
    print(my_object)

事实上Python的类远不仅如此，类还是对象。

一旦使用class关键字，Python就会创建出一个对象，
下例代码：

    class ObjectCreator(object):
        pass

在内存中创建了一个名为ObjectCreator的对象。

这个对象可以用来创建对象，这也是为什么它是一个类。
本质上，类还是一个对象，因此：
 1. 可以将类赋值给一个变量
 2. 可以复制类
 3. 可以向类添加属性
 4. 可以把类作为参数传递给函数

例如：

    print(ObjectCreator)
    def echo(o):
        print(o)
    echo(ObjectCreator)
    print(hasattr(ObjectCreator, "new_attribute"))
    ObjectCreator.new_attribute = "foo"
    print(ObjectCreator.new_attribute)
    ObjectCreatorMirror = ObjectCreator
    print(ObjectCreatorMirror.new_attribute)
    print(ObjectCreatorMirror())

**

## 动态创建类

**

既然类属于对象，那么就可以随时创建了。
首先，使用class关键字创建一个类：

    def choose_class(name):
        if name == "foo":
            class Foo(object):
                pass
            return Foo
        else:
            class Bar(object):
                pass
            return Bar
    MyClass = choose_class("foo")
    print(MyClass)
    print(MyClass())

但是，这不算动态创建，因为我们仍然需要事先写下整个类。
既然类属于对象，那么它一定是被某样东西生成的。
当我们使用class关键字，Python就自动创建出了一个对象。事实上Python中的大多数东西，我们都可以手动来完成。

还记得 type 吗？这个函数能让你知道对象的类型是什么：

    print(type(1))
    print(type("1"))
    print(type(ObjectCreator()))

是的，type还有一种功能，它可以动态创建类。type接收class的相关描述作为参数，然后返回需要的class。
(我知道，Python中一个函数传入不同的参数便有不同的用法这种设计很不好，这个问题是Python向后兼容导致的。)

type的语法如下：

    type(name of the class,
        tuple of the baseClass,
        dictionary containing attributes names and values)

举个栗子：

    class MyShinyClass(Object):
        pass

上面的对象(类)可以通过手动方式创建：

    MyShinyClass = type("MyShinyClass", (), {})
    print(MyShinyClass)
    print(MyShinyClass())

你可能注意到了，这里的"MyShinyClass"这个类名和左侧的变量名一样。虽然它们可以不一样，但我们没有必要去复杂化事情。

type 第三个参数是一个字典类型，用来表示类的属性。比如：

    class Foo(object):
        bar = True

可以被表示为：

    Foo = type("Foo", (), {"bar":True})

使用起来没什么两样：

    print(Foo)
    print(Foo.bar)
    f =Foo()
    print(f)
    print(f.bar)

当然，这个类可以作为基类：

    class FooChild(Foo):
        pass
    FooChild = type("FooChild", (Foo,), {})
    print(FooChild)
    print(FooChild.bar)

我们还可以向类添加方法。定义一个正常的函数然后赋予类。

    FooChild = type("FooChild", (Foo,), {"echo_bar": lambda self: self.bar})
    hasattr(Foo, "echo_bar")
    hasattr(FooChild, "echo_bar")
    my_foo = FooChild()
    my_foo.echo_bar()

我们甚至可以在创建类以后，再添加方法，和平常没区别。

    FooChild.echo_bar_more = lambda self: "yet another method"
    hasattr(FooChild, "echo_bar_more")

你大概知晓了我们接下来要了解什么了：类属于一种对象，可以随时动态创建。
这就是我们使用class关键字时，Python所做的工作，使用元类metaclass来完成。

**

## 重点来了：什么是元类？

**

元类就是创建出类的东西。
我们定义一个类是为了创建对象，对吗？
但我们知道类也是对象。
是的，元类就是创建这些类的东西。它们就是类对象的类，可以这样想象：

    MyClass = MetaClass()
    my_object = MyClass()

我们已经知道type可以：

    MyClass = type("MyClass", (), {})

这是因为我们以为的函数type实际上是一个可调用的元类，type就是Python在屏幕后面用来创建所有类的元类。

现在你是否很好奇type首字母没有大写呢？
嗯...我猜这是为了和str，int 保持一致性，后两者分别创建string对象和integer对象，而type创建出所有的类对象。
我们可以看下它的__class_属性。
Python中的一切都是对象。比如ints，strings，functions，classes。这些都是通过类创建出来的：

    number = 520
    number.__class__
    name = "haoke"
    name.__class__
    def foo(): pass
    foo.__class__
    class Bar(object): pass
    b = Bar()
    b._class__

那么，上面这些_class__的__class__是什么呢？

    number.__class__.__class__
    name.__class__.__class__
    foo.__class__.__class__
    b.__class__.__class__

(上面的结果在Python3中都是<class 'type'>)
没错，元类就是用来创建类的东西。
你可以把元类当成是"类工厂"。
type是Python内置的元类，我们也可以创建自己的元类。

py2的__metaclass__属性和py3的metaclass关键字

下面一一道来。
Python2：
    在定义类的时候，我们可以添加一个__metaclass__属性：
    class Foo(object):
        __metaclass__ = something...
        [...]
    这样写，Python会使用元类来创建这个这个Foo类。
    但要小心，这不简单。
    虽然已经写了class Foo(object)，但Foo类此时还未创建。
    Python会先检查类是否定义了__metaclass__，如果有，它就会用指定的元类来创建这个类Foo。但若没有，就使用默认的type来创建类Foo。

    多看几次：
    class Foo(Bar, Rab):
        pass
    Python会做如下操作：
    1.Foo中定义了__metaclass_属性吗？
    2.定义了的话，就使用指定的元类的创建这个类。
    3.如果没有定义，Python就会在当前模块中查找，然后重新进行 属性定义 判断(但只适用于不继承任何东西的类，基本上是老式类)。
    4.如果Python没有找到任何关于__metaclass__的显式定义，它就会使用第一个父类(Bar)的元类(可能是默认值type)来创建这个类。
    注意，__metaclass__属性不会被继承，但父类(Bar.__class__)的元类会被继承。如果Bar使用__metaclass__属性，该属性使用type()(而不是type.__new__())创建Bar，那么子类将不会继承该行为。
    (这段问答来自于回答下方：
        Be careful here that the __metaclass__ attribute will not be inherited, the metaclass of the parent (Bar.__class__) will be. If Bar used a __metaclass__ attribute that created Bar with type() (and not type.__new__()), the subclasses will not inherit that behavior. Can someone please explain this a little bit deeper? Would really appreciate some help here. – Deep Jun 25 '17 at 14:43 
        
        @Deep: The actual metaclass of a class is specified in .__class__, whereas .__metaclass__ specifies which callable should be used to alter the class during creation. If for example .__metaclass__ contains a function foo_bar() that uses type(x,y,z) to alter the class, then you will have .__metaclass__ = foo_bar which will not be inherited but .__class__ will be type, because that's what was used to create the new altered class. Read this a few times. I am 99% sure I haven't made a mistake ;) – Philip Stark Aug 16 '17 at 9:17
    )
    
现在有一个很大的问题摆在这：我们可以向__metaclass__属性**赋什么值**呢？
答案是：能创建类的东西，type或其子类。

Python3:
    class Foo(object, metaclass=something):
        [...]
    在3中，__metaclass__属性已经不再使用了，但作用表现上大致相同。

**

## 自定义元类

**
（这部分代码是针对Python2.x的)
一个元类的作用是自动改变将被创建出来的类。
想象一个简单的场景，你想某个模块下的所有类都应该大写化它们的属性名。这有许多种方法来完成，但其中有一种是在模块中定义__metaclass__属性。
这种情况下，这个模块下的所有类都会使用这个指定的元类来创建。
我们要告诉元类所有的类属性都应该大写化，幸好，__metaclass__实际上是可以被调用的，其值不一定非要是类。

    def upper_attr(futture_class_name, future_class_parents, future_class_attr):
        '''return a class object, with the list of its attribute turned intor uppercase'''
        # pick up any attribute that does not start with "__" and uppercase it
        uppercase_attr = {}
        for name, val in future_class_attr.items():
            if not name.startswith("__"):
                uppercase_attr[name.upper()] = val
            else:
                uppercase_attr[name] = val
        # let "type" do the class creation
        return type(future_class_name, future_class_parents, uppercase_attr)
    
    __metaclass__ = upper_attr # this will affect all classes in the module
    
    class Foo(): # global __metaclass__ won't work with "object" though.
        # but we can define __metaclass__ here instead to affect only this class.
        # and this will work  with "object" children.
        bar = "bip"
    
    print(hasattr(Foo, "bar")
    print(hasattr(Foo, "BAR"))
    f = Foo()
    print(f.BAR)

现在，让我们使用真正的元类来做同样的事情
记住：‘type'实际上是一个类似str和int的类，仅仅没有大写开头。
   
    class UpperAttrMetaClass(type):
        # __new__ 是要先于 __init__ 被调用
        # 它是类的构造方法，会返回一个实例
        # 而 __init__ 只是在之后对实例进行初始化操作。
        # 你几乎用不到 __new__ 方法，除非你想控制实例的创建过程
        # 在这里，创建的实例是类，我们想自定义它，
        # 所以 我们需要覆盖 __new__
        # 有些人会选择覆盖__call__方法来达到同样的效果，但我们在这不会这样做
        def __new__(upperattr_metaclass, future_class_name,
                    future_class_parents, future_class_attr):
            uppercase_attr = {}
            for name, val in future_class_attr.items():
                if not name.startswith("__"):
                    uppercase_attr[name.upper()] = val
                else:
                uppercase_attr[name] = val
            return type(future_class_name, future_class_parents, future_class_attr)
    
   

 但上面的代码并不OOP，我们直接调用的type，我们没有调用其父类的__new__方法：
    
    class UpperAttrMetaclass(type):
        def __new__(upperattr_metaclass, future_class_name,
                    future_class_parents, future_class_attr):
            uppercase_attr = {}
            for name, val in future_class_attr.items():
                if not name.startswith('__'):
                    uppercase_attr[name.upper()] = val
                else:
                    uppercase_attr[name] = val
            return type.__new__(upperattr_metaclass, future_class_name,
                                future_class_parents, uppercase_attr)

你可能注意到了upperattr_metaclass这个额外的参数。这没有什么特别的：
__new__ 总是会收到定义的这个类作为第一个参数，就像普通的实例方法中有self参数一样，它接收的是一个实例，
类方法中的cls参数一样，接收的是一个类。
简化下上面的代码：

    class UpperAttrMetaclass(type):
        def __new__(cls, clsname, bases, dct):
            uppercase_attr = {}
            for name, val in dct.items():
                if not name.startswith('__'):
                    uppercase_attr[name.upper()] = val
                else:
                    uppercase_attr[name] = val
            return type.__new__(cls, clsname, bases, uppercase_attr)

我们可以使用super来使其更加正确，super会保证继承正确化(防止钻石继承的出现，防止继承查找没有按照mro来进行)：

    class UpperAttrMetaclass(type):
        def __new__(cls, clsname, bases, dct):
            uppercase_attr = {}
            for name, val in dct.items():
                if not name.startswith('__'):
                    uppercase_attr[name.upper()] = val
                else:
                    uppercase_attr[name] = val
            return super(UpperAttrMetaclass, cls).__new__(cls, clsname, bases, uppercase_attr)

这就是元类的所有了。

真的，元类对于创建"黑魔法"真的很有用，但会复杂化事情。就其本身而言，还是很简单的：
    * **拦截(类的创建)**
    * **修改(类)**
    * **返回(修改后的类)**
    
再精简一点就是：钩子、修改




