条件选择
============

.. contents:: Topics


常常来说,一个play的结果经常取决于一个变量的值,事件（从远端系统得到事件）,
或者之前任务的结果.在有些情况下,这些变量的值也会取决于其他变量.
进而,可以建立多余的组基于这些主机是否符合某些条件来操控主机,
Ansible 提供了很多不同选项,来控制执行流. 
让我们详细看看这些都是啥. 

When 语句
``````````````````

有时候用户有可能需要某一个主机越过某一个特定的步骤.这个过程就可以简单的像在某一个特定版本的系统上
少装了一个包一样或者像在一个满了的文件系统上执行清理操作一样. 
这些操作在Ansible上,若使用`when`语句都异常简单.When语句包含Jinja2表达式(参见:doc:`playbooks_variables`). 
实际上真的很简单::

    tasks:
      - name: "shutdown Debian flavored systems"
        command: /sbin/shutdown -t now
        when: ansible_os_family == "Debian"

一系列的Jinja2 "过滤器" 也可以在when语句中使用, 但有些是Ansible中独有的.
比如我们想忽略某一错误,通过执行成功与否来做决定,我们可以像这样::

    tasks:
      - command: /bin/false
        register: result
        ignore_errors: True
      - command: /bin/something
        when: result|failed
      - command: /bin/something_else
        when: result|success
      - command: /bin/still/something_else
        when: result|skipped

我知道,在这里讨论'register'语句命令,有点过于超前,我们将会在本章稍后讨论. 

友情提示,如果想查看哪些事件在某个特定系统中时允许的,可以执行以下命令::

    ansible hostname.example.com -m setup

提示: 有些时候你得到一个返回参数的值是一个字符串,并且你还想使用数学操作来比较它,那么你可以执行一下操作:: 

    tasks:
      - shell: echo "only on Red Hat 6, derivatives, and later"
        when: ansible_os_family == "RedHat" and ansible_lsb.major_release|int >= 6

.. note:: 以上事例需要目标主机上安装lsb_release软件包,来返回ansible_lsb.major_release 事件. 

在playbooks 和 inventory中定义的变量都可以使用. 下面一个例子,就是基于布尔值来决定一个任务是否被执行:: 

    vars:
      epic: true

一个条件选择执行也许看起来像这样:: 

    tasks:
        - shell: echo "This certainly is epic!"
          when: epic

或者像这样:: 

    tasks:
        - shell: echo "This certainly isn't epic!"
          when: not epic

如果一个变量不存在,你可以使用Jinja2的`defined`命令跳过或略过.例如:: 

    tasks:
        - shell: echo "I've got '{{ foo }}' and am not afraid to use it!"
          when: foo is defined

        - fail: msg="Bailing out. this play requires 'bar'"
          when: bar is not defined

这个机制在选择引入变量文件时有时候特别有用,详情如下. 

note当同时使用`when`he`with_items` (详见:doc:`playbooks_loops`), note`when`语句对于不同项目将会单独处理.这个源于原初设计::

    tasks:
        - command: echo {{ item }}
          with_items: [ 0, 2, 4, 6, 8, 10 ]
          when: item > 5

加载客户事件
```````````````````````

加载客户自己的事件,事实上也很简单,将在:doc:`developing_modules` 详细介绍.只要调用客户自己的事件,进而把所有的模块放在任务列表顶端,
变量的返回值今后就可以访问了::

    tasks:
        - name: gather site specific fact data
          action: site_facts
        - command: /usr/bin/thingy
          when: my_custom_fact_just_retrieved_from_the_remote_system == '1234'
                   
在roles 和 includes 上面应用'when'语句
`````````````````````````````````````````

note,如果你的很多任务都共享同样的条件语句的话,可以在选择语句后面添加inlcudes语句,参见下面事例.
这个特性并不适用于playbook的inclues,只有task 的 includes适用.所有的task都会被检验,
选择会应用到所有的task上面:: 

    - include: tasks/sometasks.yml
      when: "'reticulating splines' in output"

或者应用于role:: 

    - hosts: webservers
      roles:
         - { role: debian_stock_config, when: ansible_os_family == 'Debian' }

在系统中使用这个方法但是并不能匹配某些标准时,你会发现在Ansible中,有很多默认'skipped'的结果.
详情参见:doc:`modules` 文档中的 'group_by' 模块, 你会找到更加赏心悦目的方法来解决这个问题. 

条件导入
```````````````````

.. note:: 这是一个很高级但是却被经常使用的话题.当然你也可以跳过这一节.

基于某个特定标准,又是你也许在一个playbook中你想以不同的方式做同一件事.
在不同平台或操作系统上使用同一个playbook就是一个很好的例子. 

举个例子,名字叫做Apache的包,在CentOS 和 Debian系统中也许不同, 
但是这个问题可以一些简单的语法就可以被Ansible Playbook解决::

    ---
    - hosts: all
      remote_user: root
      vars_files:
        - "vars/common.yml"
        - [ "vars/{{ ansible_os_family }}.yml", "vars/os_defaults.yml" ]
      tasks:
      - name: make sure apache is running
        service: name={{ apache }} state=running

.. note:: 'ansible_os_family' 已经被导入到为vars_files定义的文件名列表中了. 

提醒一下,很多的不同的YAML文件只是包含键和值:: 

    ---
    # for vars/CentOS.yml
    apache: httpd
    somethingelse: 42

这个具体事怎么工作的呢？ 如果操作系统是'CentOS', Ansible导入的第一个文件将是'vars/CentOS.yml',紧接着
是'/var/os_defaults.yml',如果这个文件不存在.而且在列表中没有找到,就会报错.
在Debian,最先查看的将是'vars/Debian.yml'而不是'vars/CentOS.yml', 如果没找到,则寻找默认文件'vars/os_defaults.yml'
很简单.如果使用这个条件性导入特性,你需要在运行playbook之前安装facter 或者 ohai.当然如果你喜欢,
你也可以把这个事情推给Ansible来做:: 

    # for facter
    ansible -m yum -a "pkg=facter state=present"
    ansible -m yum -a "pkg=ruby-json state=present"

    # for ohai
    ansible -m yum -a "pkg=ohai state=present"

Ansible 中的设置方式———— 从任务中把参数分开,这样可避免代码中有太多丑陋嵌套if等复杂语句.
这样可以使得配置条目更加的流畅的赏心悦目———— 特别是因为这样可以尽量减少决定点

基于变量选择文件和模版
````````````````````````````````````````````````

.. note:: 这是一个经常用到的高级话题.也可以跳过这章.  

有时候,你想要复制一个配置文件,或者一个基于参数的模版. 
下面的结构选载选第一个宿主给予的变量文件,这些可以比把很多if选择放在模版里要简单的多. 
下面的例子展示怎样根据不同的系统,例如CentOS,Debian制作一个配置文件的模版::

   - name: template a file
      template: src={{ item }} dest=/etc/myapp/foo.conf
      with_first_found:
        - files: 
           - {{ ansible_distribution }}.conf
           - default.conf
          paths:
           - search_location_one/somedir/
           - /opt/other_location/somedir/

注册变量
``````````````````

经常在playbook中,存储某个命令的结果在变量中,以备日后访问是很有用的.
这样使用命令模块可以在许多方面除去写站（site）特异事件,举个例子
你可以检测某一个特定程序是否存在

这个 'register' 关键词决定了把结果存储在哪个变量中.结果参数可以用在模版中,动作条目,或者 *when* 语句. 像这样（这是一个浅显的例子）:: 

    - name: test play
      hosts: all

      tasks:

          - shell: cat /etc/motd
            register: motd_contents

          - shell: echo "motd contains the word hi"
            when: motd_contents.stdout.find('hi') != -1

就像上面展示的那样,这个注册后的参数的内容为字符串'stdout'是可以访问. 
这个注册了以后的结果,如果像上面展示的,可以转化为一个list（或者已经是一个list）,就可以在任务中的"with_items"中使用.
"stdout_lines"在对象中已经可以访问了,当然如果你喜欢也可以调用 "home_dirs.stdout.split()" , 也可以用其它字段切割::

    - name: registered variable usage as a with_items list
      hosts: all

      tasks:

          - name: retrieve the list of home directories
            command: ls /home
            register: home_dirs

          - name: add home dirs to the backup spooler
            file: path=/mnt/bkspool/{{ item }} src=/home/{{ item }} state=link
            with_items: home_dirs.stdout_lines
            # same as with_items: home_dirs.stdout.split()


.. seealso::

   :doc:`playbooks`
       An introduction to playbooks
   :doc:`playbooks_roles`
       Playbook organization by roles
   :doc:`playbooks_best_practices`
       Best practices in playbooks
   :doc:`playbooks_conditionals`
       Conditional statements in playbooks
   :doc:`playbooks_variables`
       All about variables
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

