https://github.com/taizilongxu/interview_python
1.函数参数传递
    参数顺序,参数类型(变长，关键),参数定义(一个变量),变量定义,
    对象引用,可变与不可变对象(备份与"指针"),浅拷贝与深拷贝
    参考资料：http://stackoverflow.com/questions/986006/how-do-i-pass-a-variable-by-reference

2.元类metaclass
    定义,作用,type,参数(4 or 3 ?),自定义(继承)
    (extra:我认为使用元类的原因和使用类的原因类似，在根本上保证其实例都具有同样的特性)
    参考资料:
    https://stackoverflow.com/questions/100003/what-are-metaclasses-in-python

3.类中的各种特殊变量 __xx__的由来以及super
    __setattr__/__getattr__
    __set__/__get__/__delete__ ~ property ~
    __iter__
    __getitem__/__setitem__
    ...
    __mro__
    super的定义以及作用
    使用super和直接使用类名的区别
    参考资料:
    https://pycoders-weekly-chinese.readthedocs.io/en/latest/issue6/a-guide-to-pythons-magic-methods.html

    https://python3-cookbook.readthedocs.io/zh_CN/latest/c08/p07_calling_method_on_parent_class.html

4.property 类装饰器的原理
    property 源码
    装饰器下的函数名称设计
    描述器是什么
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

9.鸭子类型


