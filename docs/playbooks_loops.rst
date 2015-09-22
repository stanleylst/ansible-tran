循环
=====

通常你想在一个任务中干很多事,比如创建一群用户,安装很多包,或者重复一个轮询步骤直到收到某个特定结果.

本章将对在playbook中如何使用循环做全面的介绍.

.. contents:: Topics

.. _standard_loops:

标准循环
``````````````

为了保持简洁,重复的任务可以用以下简写的方式::

    - name: add several users
      user: name={{ item }} state=present groups=wheel
      with_items:
         - testuser1
         - testuser2

如果你在变量文件中或者 'vars' 区域定义了一组YAML列表,你也可以这样做::

    with_items: "{{somelist}}"

以上写法与下面是完全等同的::

    - name: add user testuser1
      user: name=testuser1 state=present groups=wheel
    - name: add user testuser2
      user: name=testuser2 state=present groups=wheel

yum和apt模块中使用with_items执行时会有较少的包管理事务.

请note使用 'with_items' 用于迭代的条目类型不仅仅支持简单的字符串列表.如果你有一个哈希列表,那么你可以用以下方式来引用子项::

    - name: add several users
      user: name={{ item.name }} state=present groups={{ item.groups }}
      with_items:
        - { name: 'testuser1', groups: 'wheel' }
        - { name: 'testuser2', groups: 'root' }


请note如果同时使用 `when` 和 `with_items` （或其它循环声明）,`when`声明会为每个条目单独执行.请参见 :ref:`the_when_statement` 示例.

.. _nested_loops:

嵌套循环
````````````

循环也可以嵌套::

    - name: give users access to multiple databases
      mysql_user: name={{ item[0] }} priv={{ item[1] }}.*:ALL append_privs=yes password=foo
      with_nested:
        - [ 'alice', 'bob' ]
        - [ 'clientdb', 'employeedb', 'providerdb' ]

和以上介绍的'with_items'一样,你也可以使用预定义变量.::

    - name: here, 'users' contains the above list of employees
      mysql_user: name={{ item[0] }} priv={{ item[1] }}.*:ALL append_privs=yes password=foo
      with_nested:
        - "{{users}}"
        - [ 'clientdb', 'employeedb', 'providerdb' ]

.. _looping_over_hashes:

对哈希表使用循环
``````````````````

.. versionadded:: 1.5

假如你有以下变量::

    ---
    users:
      alice:
        name: Alice Appleworth
        telephone: 123-456-7890
      bob:
        name: Bob Bananarama
        telephone: 987-654-3210

你想打印出每个用户的名称和电话号码.你可以使用 ``with_dict`` 来循环哈希表中的元素::

    tasks:
      - name: Print phone records
        debug: msg="User {{ item.key }} is {{ item.value.name }} ({{ item.value.telephone }})"
        with_dict: "{{users}}"

.. _looping_over_fileglobs:

对文件列表使用循环
``````````````````````

``with_fileglob`` 可以以非递归的方式来模式匹配单个目录中的文件.如下面所示::

    ---
    - hosts: all

      tasks:

        # first ensure our target directory exists
        - file: dest=/etc/fooapp state=directory

        # copy each file over that matches the given pattern
        - copy: src={{ item }} dest=/etc/fooapp/ owner=root mode=600
          with_fileglob:
            - /playbooks/files/fooapp/*
            
.. note:: 当在role中对 ``with_fileglob`` 使用相对路径时, Ansible会把路径映射到`roles/<rolename>/files`目录.

对并行数据集使用循环
``````````````````````````````````

.. note:: 这是一个不常见的使用方式,但为了文档完整性我们还是把它写出来.你可能不会经常使用这种方式.

假设你通过某种方式加载了以下变量数据::

    ---
    alpha: [ 'a', 'b', 'c', 'd' ]
    numbers:  [ 1, 2, 3, 4 ]

如果你想得到'(a, 1)'和'(b, 2)'之类的集合.可以使用'with_together'::

    tasks:
        - debug: msg="{{ item.0 }} and {{ item.1 }}"
          with_together:
            - "{{alpha}}"
            - "{{numbers}}"

对子元素使用循环
````````````````````````

假设你想对一组用户做一些动作,比如创建这些用户,并且允许它们使用一组SSH key来登录.

如何实现那? 先假设你有按以下方式定义的数据,可以通过"vars_files"或"group_vars/all"文件加载::

    ---
    users:
      - name: alice
        authorized:
          - /tmp/alice/onekey.pub
          - /tmp/alice/twokey.pub
        mysql:
            password: mysql-password
            hosts:
              - "%"
              - "127.0.0.1"
              - "::1"
              - "localhost"
            privs:
              - "*.*:SELECT"
              - "DB1.*:ALL"
      - name: bob
        authorized:
          - /tmp/bob/id_rsa.pub
        mysql:
            password: other-mysql-password
            hosts:
              - "db1"
            privs:
              - "*.*:SELECT"
              - "DB2.*:ALL"

那么可以这样实现::

    - user: name={{ item.name }} state=present generate_ssh_key=yes
      with_items: "{{users}}"

    - authorized_key: "user={{ item.0.name }} key='{{ lookup('file', item.1) }}'"
      with_subelements:
         - users
         - authorized

根据mysql hosts以及预先给定的privs subkey列表,我们也可以在嵌套的subkey中迭代列表::

    - name: Setup MySQL users
      mysql_user: name={{ item.0.user }} password={{ item.0.mysql.password }} host={{ item.1 }} priv={{ item.0.mysql.privs | join('/') }}
      with_subelements:
        - users
        - mysql.hosts


Subelements walks a list of hashes (aka dictionaries) and then traverses a list with a given key inside of those
records.

你也可以为字元素列表添加第三个元素,该元素可以放置标志位字典.现在你可以加入'skip_missing'标志位.如果设置为True,那么查找插件会跳过不包含指定子键的列表条目.如果没有该标志位,或者标志位值为False,插件会产生错误并指出缺少该子键.

这就是authorized_key模式中key的获取方式.


.. _looping_over_integer_sequences:

对整数序列使用循环
``````````````````````````````

``with_sequence`` 可以以升序数字顺序生成一组序列.你可以指定起始值、终止值,以及一个可选的步长值.

指定参数时也可以使用key=value这种键值对的方式.如果采用这种方式,'format'是一个可打印的字符串.

数字值可以被指定为10进制,16进制(0x3f8)或者八进制(0600).负数则不受支持.请看以下示例::

    ---
    - hosts: all

      tasks:

        # create groups
        - group: name=evens state=present
        - group: name=odds state=present

        # create some test users
        - user: name={{ item }} state=present groups=evens
          with_sequence: start=0 end=32 format=testuser%02x

        # create a series of directories with even numbers for some reason
        - file: dest=/var/stuff/{{ item }} state=directory
          with_sequence: start=4 end=16 stride=2

        # a simpler way to use the sequence plugin
        # create 4 groups
        - group: name=group{{ item }} state=present
          with_sequence: count=4

.. _random_choice:

随机选择
``````````````

'random_choice'功能可以用来随机获取一些值.它并不是负载均衡器(已经有相关的模块了).它有时可以用作一个简化版的负载均衡器,比如作为条件判断::

    - debug: msg={{ item }}
      with_random_choice:
         - "go through the door"
         - "drink from the goblet"
         - "press the red button"
         - "do nothing"

提供的字符串中的其中一个会被随机选中. 

还有一个基本的场景,该功能可用于在一个可预测的自动化环境中添加混乱和兴奋点.

.. _do_until_loops:

Do-Until循环
``````````````

.. versionadded: 1.4

有时你想重试一个任务直到达到某个条件.比如下面这个例子::
   
    - action: shell /usr/bin/foo
      register: result
      until: result.stdout.find("all systems go") != -1
      retries: 5
      delay: 10

上面的例子递归运行shell模块,直到模块结果中的stdout输出中包含"all systems go"字符串,或者该任务按照10秒的延迟重试超过5次."retries"和"delay"的默认值分别是3和5.

该任务返回最后一个任务返回的结果.单次重试的结果可以使用-vv选项来查看.
被注册的变量会有一个新的属性'attempts',值为该任务重试的次数.

.. _with_first_found:

查找第一个匹配的文件
``````````````````````````

.. note:: 这是一个不常见的使用方式,但为了文档完整性我们还是把它写出来.你可能不会经常使用这种方式.

这其实不是一个循环,但和循环很相似.如果你想引用一个文件,而该文件是从一组文件中根据给定条件匹配出来的.这组文件中部分文件名由变量拼接而成.针对该场景你可以这样做::

    - name: INTERFACES | Create Ansible header for /etc/network/interfaces
      template: src={{ item }} dest=/etc/foo.conf
      with_first_found:
        - "{{ansible_virtualization_type}}_foo.conf"
        - "default_foo.conf"

该功能还有一个更完整的版本,可以配置搜索路径.请看以下示例::

    - name: some configuration template
      template: src={{ item }} dest=/etc/file.cfg mode=0444 owner=root group=root
      with_first_found:
        - files:
           - "{{inventory_hostname}}/etc/file.cfg"
          paths:
           - ../../../templates.overwrites
           - ../../../templates
        - files:
            - etc/file.cfg
          paths:
            - templates

.. _looping_over_the_results_of_a_program_execution:

迭代程序的执行结果
`````````````````````````````````````````````````

.. note:: 这是一个不常见的使用方式,但为了文档完整性我们还是把它写出来.你可能不会经常使用这种方式.

有时你想执行一个程序,而且按行循环该程序的输出.Ansible提供了一个优雅的方式来实现这一点.但请记住,该功能始终在控制机上执行,而不是本地机器::

    - name: Example of looping over a command result
      shell: /usr/bin/frobnicate {{ item }}
      with_lines: /usr/bin/frobnications_per_host --param {{ inventory_hostname }}

好吧,这好像有点随意.事实上,如果你在做一些与inventory有关的事情,比如你想编写一个动态的inventory源(参见 :doc:`intro_dynamic_inventory`),那么借助该功能能够快速实现.

如果你想远程执行命令,那么以上方法则不行.但你可以这样写::

    - name: Example of looping over a REMOTE command result
      shell: /usr/bin/something
      register: command_result

    - name: Do something with each result
      shell: /usr/bin/something_else --param {{ item }}
      with_items: "{{command_result.stdout_lines}}"

.. _indexed_lists:

使用索引循环列表
`````````````````````````````````

.. note:: 这是一个不常见的使用方式,但为了文档完整性我们还是把它写出来.你可能不会经常使用这种方式.

.. versionadded: 1.3

如果你想循环一个列表,同时得到一个数字索引来标明你当前处于列表什么位置,那么你可以这样做.虽然该方法不太常用::

    - name: indexed loop demo
      debug: msg="at array position {{ item.0 }} there is a value {{ item.1 }}"
      with_indexed_items: "{{some_list}}"

.. _using_ini_with_a_loop:

循环配置文件
``````````````````````````
.. versionadded: 2.0

ini插件可以使用正则表达式来获取一组键值对.因此,我们可以遍历该集合.以下是我们使用的ini文件::

    [section1]
    value1=section1/value1
    value2=section1/value2

    [section2]
    value1=section2/value1
    value2=section2/value2

以下是使用 ``with_ini`` 的例子::

    - debug: msg="{{item}}"
      with_ini: value[1-2] section=section1 file=lookup.ini re=true

以下是返回的值::

    {
          "changed": false, 
          "msg": "All items completed", 
          "results": [
              {
                  "invocation": {
                      "module_args": "msg=\"section1/value1\"", 
                      "module_name": "debug"
                  }, 
                  "item": "section1/value1", 
                  "msg": "section1/value1", 
                  "verbose_always": true
              }, 
              {
                  "invocation": {
                      "module_args": "msg=\"section1/value2\"", 
                      "module_name": "debug"
                  }, 
                  "item": "section1/value2", 
                  "msg": "section1/value2", 
                  "verbose_always": true
              }
          ]
      }


.. _flattening_a_list:

扁平化列表
`````````````````

.. note:: 这是一个不常见的使用方式,但为了文档完整性我们还是把它写出来.你可能不会经常使用这种方式.

在罕见的情况下,你可能有几组列表,列表中会嵌套列表.而你只是想迭代所有列表中的每个元素.比如有一个非常疯狂的假定的数据结构::

    ----
    # file: roles/foo/vars/main.yml
    packages_base:
      - [ 'foo-package', 'bar-package' ]
    packages_apps:
      - [ ['one-package', 'two-package' ]]
      - [ ['red-package'], ['blue-package']]

你可以看到列表中的包到处都是.那么如果想安装两个列表中的所有包那?::

    - name: flattened loop demo
      yum: name={{ item }} state=installed 
      with_flattened:
         - packages_base
         - packages_apps

这就行了！

.. _using_register_with_a_loop:

循环中使用注册器
``````````````````````````

当对处于循环中的某个数据结构使用 ``register`` 来注册变量时,结果包含一个 ``results`` 属性,这是从模块中得到的所有响应的一个列表.

以下是在 ``with_items`` 中使用 ``register`` 的示例::

    - shell: echo "{{ item }}"
      with_items:
        - one
        - two
      register: echo

返回的数据结构如下,与非循环结构中使用 ``register`` 的返回结果是不同的::

    {
        "changed": true,
        "msg": "All items completed",
        "results": [
            {
                "changed": true,
                "cmd": "echo \"one\" ",
                "delta": "0:00:00.003110",
                "end": "2013-12-19 12:00:05.187153",
                "invocation": {
                    "module_args": "echo \"one\"",
                    "module_name": "shell"
                },
                "item": "one",
                "rc": 0,
                "start": "2013-12-19 12:00:05.184043",
                "stderr": "",
                "stdout": "one"
            },
            {
                "changed": true,
                "cmd": "echo \"two\" ",
                "delta": "0:00:00.002920",
                "end": "2013-12-19 12:00:05.245502",
                "invocation": {
                    "module_args": "echo \"two\"",
                    "module_name": "shell"
                },
                "item": "two",
                "rc": 0,
                "start": "2013-12-19 12:00:05.242582",
                "stderr": "",
                "stdout": "two"
            }
        ]
    }

随后的任务可以用以下方式来循环注册变量,用来检查结果值::

    - name: Fail if return code is not 0
      fail:
        msg: "The command ({{ item.cmd }}) did not have a 0 return code"
      when: item.rc != 0
      with_items: "{{echo.results}}"

.. _writing_your_own_iterators:

自定义迭代
``````````````````````````

虽然你通常无需自定义实现自己的迭代,但如果你想按你自己的方式来循环任意数据结构,你可以阅读:doc:`developing_plugins` 来作为开始.以上的每个功能都以插件的方式来实现,所以有很多的实现可供引用.

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


