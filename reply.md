https://github.com/taizilongxu/interview_python
1.函数参数传递
    参数顺序,参数类型(变长，关键),参数定义(一个变量),变量定义
        参数顺序：从左到右，优先级：位置参数>边长参数>关键字参数
        参数定义：将一个对象ins传递给函数，函数内部会新建一个引用copy
                ins性质可能是可变或不可变的:
                    不可变:在函数中操作copy完全不会影响到ins；
                    可变  :如果操作修改copy会改变外面的ins，但如果将copy指向其它对象，则ins不会被改变；
    对象引用,可变与不可变对象(备份与"指针"),浅拷贝与深拷贝
        不可变对象：一旦创建，就不能再修改(tuple, 1, 2, 3...)
        深拷贝：完全拷贝对象(克隆体)
        浅拷贝：只是拷贝地址(类似"指针")
    参考资料：http://stackoverflow.com/questions/986006/how-do-i-pass-a-variable-by-reference

2.元类metaclass
    定义,作用,type,参数(4 or 3 ?),自定义(继承)
        元类是一种类：用来创建类
        type()使用时参数为3个：
            name of class,
            tuple of class's parent,
            dict of class's attributes
        type的__new__方法参数为4个，多了第一个 cls
    自定义：
        py2: __metaclass__
        py3: metaclass 关键字
        (extra:我认为使用元类的原因和使用类的原因大致相同，在根本上保证其实例都具有同样的特性)
    参考资料:
    https://stackoverflow.com/questions/100003/what-are-metaclasses-in-python

3.类中的各种特殊变量 __xx__的由来以及super
    __setattr__/__getattr__
    __set__/__get__/__delete__ ~ property ~
    __iter__
    __getitem__/__setitem__
    ...
    __mro__
    这一系列方法都是Python的魔法方法，它们能让对象控制变得更加轻松

    super的定义以及作用
        super本身是一个元类，然后调用它可以获得父类然后借此调用父类方法
        super可以避免在钻石继承出现的情况下产生父类方法重复调用，super调用时是以mro为基准进行向上查找
    使用super和直接使用类名的区别
        仅仅在多继承情况下，直接使用类名会有重复调用情况发生。
    参考资料:
    https://pycoders-weekly-chinese.readthedocs.io/en/latest/issue6/a-guide-to-pythons-magic-methods.html

    https://python3-cookbook.readthedocs.io/zh_CN/latest/c08/p07_calling_method_on_parent_class.html

4.property 类装饰器的原理
    property 源码
        property实际上是一个描述器类(因为它定义了 __get__, __set__, __delete__)
        这个描述器类内部的核心是保存初始化时传入进来的获取、设置、删除函数，在操作描器时实际调用的是它们。
        class property(object):
            def __init__(self, fget=None, fset=None, fdel=None, doc=None):
                self.fget = fget
                self.fset = fset
                self.fdel = fdel
                self.__doc__ = doc
            def __set__(self, instance, name, v):
                if self.fset is not None:
                    self.fset(instance, name, v)
                raise Exception("not fset func")
            def __get__(self, instance, name):
                if self.fget is not None:
                    return self.fget(instance, name)
                raise Exception("not fget func")
            def __delete__(self, instance):
                if self.fdel is not None:
                    self.fdel(instance)
                raise Exception("not fdel func")
            def setter(self, func):
                self.fset = func
                return self
            def getter(self, func):
                self.fget = func
                return self
            def deleter(self, func):
                self.fdel = func
                return self

    描述器是什么?
        一个对象具有__get__/__set__/delete__方法中的一个即可称其为描述器
        仅定义了__get__的对象，成为非数据描述器，优先级低于数据描述器(额外定义了__set__),后者的检索优先级要高于前者。
    参考资料:
    https://pyzh.readthedocs.io/en/latest/Descriptor-HOW-TO-Guide.html (细读)

5.@staticmethod 和 @classmethod
    二者是都是非资料描述器，用于装饰方法
    实例对象和类都可以直接调用。
    静态方法在类中一般用来作为功能性方法，或者根本没有必要定义
    类方法，由于第一个参数是cls，因此可以通过类方法修改类状态(但实例方法实际也是可以修改的:self.__class__)

6.单下划线和双下划线
             <在类中>  <在模块代码中>
    __value  私有成员   约定不被导出
    _value   约定私有   约定不被导出

7.生成器和迭代器和可迭代对象
                        名字        生成器      迭代器      可迭代对象
    生成器(()&yieFunc)  generator     ==        can          can
    迭代器(next)        iterator      /          ==           /
    可迭代对象(for)     iterable       /        iter()        ==

8.装饰器
    本质,作用
        本质是一个高阶函数(接收函数作为参数)
        就如其名，是用来修改函数的，添加额外的东西
        
9.鸭子类型
    只要对象的行为可以满足要求即可(python中万物皆为对象)

10.__new__ 和 __init__
                方法类型     作用     执行顺序
    __new__       静态      构造       先
    __init__      实例      初始化      后
    __new__的第一个参数是cls，代表它需要接受这么一个参数，而并非因此应该是一个类方法

11.Python中的作用域
    Python遇到变量时的搜索顺序：Local->OutSide->Global->BuiltIn

12.闭包(closure)
    闭包需要满足三个条件：
    有一个函数A，且其内部定义了函数a；
    函数a引用了OutSide的变量(PS:引用的变量应该保证不被改变，否则使用时可能会出现非报错未知结果)；
    函数A返回了函数a；

13.谷歌语言规范了解一下
    尽可能使用字符串方法取代字符串模块. 使用函数调用语法取代apply(). 使用列表推导, for循环取代filter(), map()以及reduce().
    参考资料:
    https://zh-google-styleguide.readthedocs.io/en/latest/google-python-styleguide/python_language_rules

14.Python中的 is 和 ==
    is是对比地址,==是对比值 (当然存在这种情况：深拷贝时，地址相同，值也相同)



