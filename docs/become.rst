Ansible特权提升
++++++++++++++++++++++++++++

Ansible可以通过一个已存在的特权加强系统使一个用户以另外一个用户的身份去执行任务

.. contents:: Topics

Become
``````
Ansible 1.9之前主要允许用户使用sudo和有限的su命令来以不同用户的身份/权限远程登陆执行task,及创建资源. 在1.9版本中'become'取代了之前的sudo/su, 但是sudo/su依旧向后兼容. 这个新系统使得我们更加容易的增加其他的特权提升工具, 例如pbrun(Powerbroker), pfexec等.


新指令
--------------

become
    等同于添加 'sudo:' 或 'su:' (指令)去执行task/playbook, 将其设置为 'true'/'yes' 来激活特权提升

become_user
    等同于添加 'sudo_user:' 或 'su_user:' (指令)去执行task/playbook, 设置为拥有所渴望权限的用户

become_method
    运行task/playbook时的特权提升method, 覆盖ansible.cfg中的默认配置, 可以设置为'sudo'/'su'/'pbrun'/'pfexec'/'doas'


新的ansible\_ 变量
-----------------------
在每一个组或host中都允许你作为一项来设置

ansible_become
    等同于ansible_sudo或ansible_su, 设置为强制进行特权提升操作

ansible_become_method
    用来设置特权提升所使用的方法

ansible_become_user
    等同于ansible_sudo或ansible_su_user, 设置通过特权提升后的用户身份

ansible_become_pass
    等同于ansible_sudo_pass或ansible_su_pass, 设置通过特权提升的密码


新的命令行参数
------------------------

--ask-become-pass
    询问特权提升方法的密码

--become,-b
    指定运行的become(默认没有密码)

--become-method=BECOME_METHOD
    使用的特权提升方式(默认=sudo),
    可选的合法值: [ sudo | su | pbrun | pfexec | doas ]

--become-user=BECOME_USER
    指定运行的用户(默认=root)


sudo和su依旧可以工作
-----------------------

旧的playbooks不需要修改, 尽管我们不建议在使用之前的语法, sudo和su之类依然可以工作可是我们还是建议使用become将他们一次性替换. 因为你不能在同一个对象中混合使用这两种指令, 否则ansible将会引发异常.

如果sudo/su的配置或变量存在become将默认使用这些设置, 但是如果你指定任何一个配置都会将他们覆盖.



.. note:: 权限加固方法必须支持连接插件使用, 如果不支持将会引发警告, 大部分会时候会忽略它,因为这些操作会一直以root用户的身份去运行(jail, chroot, etc).

.. note:: 特权提升方法不能被重组, 你不能使用'sudo /bin/su -'来成为一个用户, 你需要运行的命令必须在能通过sudo或su指令来获得运行权限(这同样使用于pbrun, pfexec或其他方法)

.. note:: Privilege escalation permissions have to be general, Ansible does not always use a specific command to do something but runs modules (code) from a temporary file name which changes every time. So if you have '/sbin/sevice' or '/bin/chmod' as the allowed commands this will fail with ansible.
.. note:: 权限加固策略必须通用, Ansible并不是使用一个明确的命令去执行task, 它将通过一个临时的文件来运行模块(代码), 每运行一次命令这个临时文件的文件名就会发生一次变化. 所以如果你有 '/sbin/service' 或 '/bin/chmod' 作为允许的命令, 在ansible中可能会失败.

.. seealso::

   `Mailing List <http://groups.google.com/group/ansible-project>`_
       Questions? Help? Ideas?  Stop by the list on Google Groups
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

