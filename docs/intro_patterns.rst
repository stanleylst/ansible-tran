Patterns
+++++++++

.. contents:: Topics

在Ansible中,Patterns 是指我们怎样确定由哪一台主机来管理. 意思就是与哪台主机进行交互. 但是在:doc:`playbooks` 中它指的是对应主机应用特定的配置或执行特定进程.

我们再来复习下:doc:`intro_adhoc` 章节中介绍的命令用法,命令格式如下::

    ansible <pattern_goes_here> -m <module_name> -a <arguments>

示例如下::

    ansible webservers -m service -a "name=httpd state=restarted"

一个pattern通常关联到一系列组(主机的集合) --如上示例中,所有的主机均在 "webservers" 组中.

不管怎么样,在使用Ansible前,我们需事先告诉Ansible哪台机器将被执行.
能这样做的前提是需要预先定义唯一的 host names 或者 主机组.

如下的patterns等同于目标为仓库(inventory)中的所有机器::

    all
    *

也可以写IP地址或系列主机名::

    one.example.com
    one.example.com:two.example.com
    192.168.1.50
    192.168.1.*

如下patterns分别表示一个或多个groups.多组之间以冒号分隔表示或的关系.这意味着一个主机可以同时存在多个组::

    webservers
    webservers:dbservers

你也可以排队一个特定组,如下实例中,所有执行命令的机器必须隶属 webservers 组但同时不在 phoenix组::

    webservers:!phoenix

你也可以指定两个组的交集,如下实例表示,执行命令有机器需要同时隶属于 webservers 和 staging 组.

    webservers:&staging

你也可以组合更复杂的条件::

    webservers:dbservers:&staging:!phoenix

上面这个例子表示"'webservers' 和 'dbservers' 两个组中隶属于 'staging' 组并且不属于 'phoenix' 组的机器才执行命令" ... 哟！唷! 好烧脑的说！

你也可以使用变量如果你希望通过传参指定group,ansible-playbook通过 "-e" 参数可以实现,但这种用法不常用::

    webservers:!{{excluded}}:&{{required}}

你也可以不必严格定义groups,单个的host names, IPs , groups都支持通配符::

    *.example.com
    *.com

Ansible同时也支持通配和groups的混合使用::

    one*.com:dbservers

在高级语法中,你也可以在group中选择对应编号的server::
   
    webservers[0]

或者一个group中的一部分servers::

    webservers[0-25]

大部分人都在patterns应用正则表达式,但你可以.只需要以 '~' 开头即可::

    ~(web|db).*\.example\.com

同时让我们提前了解一些技能,除了如上,你也可以通过 ``--limit`` 标记来添加排除条件,/usr/bin/ansible or /usr/bin/ansible-playbook都支持::

    ansible-playbook site.yml --limit datacenter2

如果你想从文件读取hosts,文件名以@为前缀即可.从Ansible 1.2开始支持该功能::

    ansible-playbook site.yml --limit @retry_hosts.txt

够简单吧. 为了更好的掌握该章节内容,可以先了解 :doc:`intro_adhoc` 再 :doc:`playbooks`

.. seealso::

   :doc:`intro_adhoc`
       Examples of basic commands
   :doc:`playbooks`
       Learning ansible's configuration management language
   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

