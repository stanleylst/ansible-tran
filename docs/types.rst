types test
#######################
单星号
***************************************
单星号:*单星号斜体强调测试*

双星号
***************************************
双星号:**双星号加粗测试**

反引号
***************************************
反引号: ``text #!/bin/bash``

列表标记
*********************
* 一个有序列表1
* 一个有序列表2
* 一个有序列表3

  * 嵌套有序列表1
  * 嵌套有序列表2
  * 嵌套有序列表3

* 父有序列表4
* 父有序列表5


有序列表标记
*********************
#. 一个有序列表1
#. 一个有序列表2
#. 一个有序列表3

  * 嵌套有序列表1
  * 嵌套有序列表2
  * 嵌套有序列表3

#. 父有序列表4
#. 父有序列表5

代码段文字测试
**********************
Next, install the dependencies using ``pip`` (included with virtualenv_)::

    cd readthedocs.org
    pip install -r pip_requirements.txt

表格测试
**********************
+------------------------+------------+----------+----------+
| Header row, column 1   | Header 2   | Header 3 | Header 4 |
| (header rows optional) |            |          |          |
+========================+============+==========+==========+
| body row 1, column 1   | column 2   | column 3 | column 4 |
+------------------------+------------+----------+----------+
| body row 2             | ...        | ...      |          |
+------------------------+------------+----------+----------+


链接测试
******************
First, obtain Python_ and virtualenv_ if you do not already have them. Using a
virtual environment will make the installation easier, and will help to avoid
clutter in your system-wide libraries. You will also need Git_ in order to
clone the repository.

.. _Python: http://www.python.org/
.. _virtualenv: http://pypi.python.org/pypi/virtualenv
.. _Git: http://git-scm.com/



#标题测试
首先做个声明：此次教程里为了快速完成，借用了一些网上已有教程的图文，不是剽窃，只图方便。另外，因为汉化版本可能功能名称等略有差别，请自行理解。

章节
********

线框图：一般就是指产品原型，比如：把线框图尽快画出来和把原型尽快做出来是一个意思

小章节
=============

axure元件：也叫axure组件或axure部件，系统自带了一部分最基础常用的，网上也有很多别人做好的，软件使用到一定阶段可以考虑自己制作元件，以便提高产品原型的制作速度

子章节
------------

生成原型：是指把绘制好的原型通过axure rp生成静态的html页面，检查原型是否正确，同时，方便演示。建议生成时选择用谷歌浏览器打开（第一次会有提示安装相关插件），ie会每次都有安全提示，不如谷歌浏览器方便。

子章节的子章节
^^^^^^^^^^^^^^^^^^^^^^^

1-主菜单工具栏：大部分类似office软件，不做详细解释，鼠标移到按钮上都有对应的提示。
2-主操作界面：绘制产品原型的操作区域，所有的用到的元件都拖到该区域。
3-站点地图：所有页面文件都存放在这个位置，可以在这里增加、删除、修改、查看页面，也可以通过鼠标拖动调整页面顺序以及页面之间的关系

段落
"""""""""""""""

Axure rp的界面就介绍到这里，界面中的各个区域基本上在做产品原型的过程中，使用都很频繁，所以建议不要关闭任何一个区域。如果不小心关闭了，可以通过主菜单工具栏—视图—重置视图来找回。



显式标记
******************
note
======================
.. note::

    For production environments, you'll want to run Solr in a more permanent
    servelet container, such as Tomcat or Jetty. Ubuntu distributions include
    prepackaged Solr installations. Try ``aptitude install solr-tomcat`` or 
    ``aptitude install solr-jetty.``

danger
=============
.. danger::

   danger for everyone

attention
=============
.. attention::

   this is attention for you test


hint
=============

.. hint::

   this is hint ,haha

.. function:: foo(x)
                 foo(y, z)
   :module: some.module.name

image
=====================

.. image:: ../images/docker-pic.png 


尾注
***************************
.. rubric:: Footnotes
.. [#f1] 第一条尾注的文本.
.. [#f2] 第二条尾注的文本.



