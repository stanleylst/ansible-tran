Loops
循环
=====

Often you'll want to do many things in one task, such as create a lot of users, install a lot of packages, or
repeat a polling step until a certain result is reached.

通常你想在一个任务中干很多事，比如创建一群用户，安装很多包，或者重复一个轮询步骤直到收到一个确切的结果。

This chapter is all about how to use loops in playbooks.

本章都是关于如何在playbook中使用循环。

.. contents:: Topics

.. _standard_loops:

Standard Loops
标准循环
``````````````

To save some typing, repeated tasks can be written in short-hand like so::

为了保持简洁，可以以以下简写的方式来实现重复的任务::

    - name: add several users
      user: name={{ item }} state=present groups=wheel
      with_items:
         - testuser1
         - testuser2

If you have defined a YAML list in a variables file, or the 'vars' section, you can also do::

如果你在变量文件中或者`vars`区域定义了一组YAML列表，你也可以这样做::

    with_items: somelist

The above would be the equivalent of::

以上写法与下面是完全等同的::

    - name: add user testuser1
      user: name=testuser1 state=present groups=wheel
    - name: add user testuser2
      user: name=testuser2 state=present groups=wheel

The yum and apt modules use with_items to execute fewer package manager transactions.

yum和apt模块中使用with_items可以执行较少的包管理事务。

Note that the types of items you iterate over with 'with_items' do not have to be simple lists of strings.

请注意使用'with_items'用于迭代的条目类型不仅仅支持简单的字符串列表。

If you have a list of hashes, you can reference subkeys using things like::

如果你有一个哈希列表，那么你可以用以下方式来引用子项::

    - name: add several users
      user: name={{ item.name }} state=present groups={{ item.groups }}
      with_items:
        - { name: 'testuser1', groups: 'wheel' }
        - { name: 'testuser2', groups: 'root' }

.. _nested_loops:

Nested Loops
嵌套循环
````````````

Loops can be nested as well::

循环也可以嵌套::

    - name: give users access to multiple databases
      mysql_user: name={{ item[0] }} priv={{ item[1] }}.*:ALL append_privs=yes password=foo
      with_nested:
        - [ 'alice', 'bob' ]
        - [ 'clientdb', 'employeedb', 'providerdb' ]

As with the case of 'with_items' above, you can use previously defined variables. Just specify the variable's name without templating it with '{{ }}'::

和以上介绍的'with_items'一样，你也可以使用预定义变量。只需在指定变量名时不使用'{{ }}'模板化::

    - name: here, 'users' contains the above list of employees
      mysql_user: name={{ item[0] }} priv={{ item[1] }}.*:ALL append_privs=yes password=foo
      with_nested:
        - users
        - [ 'clientdb', 'employeedb', 'providerdb' ]

.. _looping_over_hashes:

Looping over Hashes
对哈希表使用循环
```````````````````

.. versionadded:: 1.5

Suppose you have the following variable::

假如你有以下变量::

    ---
    users:
      alice:
        name: Alice Appleworth
        telephone: 123-456-7890
      bob:
        name: Bob Bananarama
        telephone: 987-654-3210

And you want to print every user's name and phone number.  You can loop through the elements of a hash using ``with_dict`` like this::

你想打印出每个用户的名称和电话号码。你可以使用``with_dict``来循环哈希项中的元素::

    tasks:
      - name: Print phone records
        debug: msg="User {{ item.key }} is {{ item.value.name }} ({{ item.value.telephone }})"
        with_dict: users

.. _looping_over_fileglobs:

Looping over Fileglobs

对文件列表使用循环
``````````````````````

``with_fileglob`` matches all files in a single directory, non-recursively, that match a pattern.  It can
be used like this::

``with_fileglob``可以以非递归的方式来模式匹配单个目录中的文件。如下面所示::

    ---
    - hosts: all

      tasks:

        # first ensure our target directory exists
        - file: dest=/etc/fooapp state=directory

        # copy each file over that matches the given pattern
        - copy: src={{ item }} dest=/etc/fooapp/ owner=root mode=600
          with_fileglob:
            - /playbooks/files/fooapp/*
            
.. note:: When using a relative path with ``with_fileglob`` in a role, Ansible resolves the path relative to the `roles/<rolename>/files` directory.

.. 注意:: 当在role中对``with_fileglob``使用相对路径时, Ansible会把路径映射到`roles/<rolename>/files`目录。

Looping over Parallel Sets of Data
对并行数据集使用循环
``````````````````````````````````

.. note:: This is an uncommon thing to want to do, but we're documenting it for completeness.  You probably won't be reaching for this one often.

.. 注意:: 这是一个不常见的使用方式，但为了文档完整性我们还是把它写出来。你可能不会经常使用这种方式。

Suppose you have the following variable data was loaded in via somewhere::

假设你通过某种方式加载了以下变量数据::

    ---
    alpha: [ 'a', 'b', 'c', 'd' ]
    numbers:  [ 1, 2, 3, 4 ]

And you want the set of '(a, 1)' and '(b, 2)' and so on.   Use 'with_together' to get this::

如果你想得到'(a, 1)'和'(b, 2)'之类的集合。可以使用'with_together'::

    tasks:
        - debug: msg="{{ item.0 }} and {{ item.1 }}"
          with_together:
            - alpha
            - numbers

Looping over Subelements

对子元素使用循环
````````````````````````

Suppose you want to do something like loop over a list of users, creating them, and allowing them to login by a certain set of
SSH keys. 

假设你想对一组用户做一些动作，比如创建这些用户，并且允许它们使用一组SSH key来登录。

How might that be accomplished?  Let's assume you had the following defined and loaded in via "vars_files" or maybe a "group_vars/all" file::

如何实现那? 现假设你有按以下方式定义的数据，可以通过"vars_files"或"group_vars/all"文件加载::

    ---
    users:
      - name: alice
        authorized: 
          - /tmp/alice/onekey.pub
          - /tmp/alice/twokey.pub
      - name: bob
        authorized:
          - /tmp/bob/id_rsa.pub

It might happen like so::

那么可以这样实现::

    - user: name={{ item.name }} state=present generate_ssh_key=yes
      with_items: users

    - authorized_key: "user={{ item.0.name }} key='{{ lookup('file', item.1) }}'"
      with_subelements:
         - users
         - authorized

Subelements walks a list of hashes (aka dictionaries) and then traverses a list with a given key inside of those
records.

subelements遍历一组hash表（也叫字典），然后根据这些记录中的一个指定键来遍历列表。

The authorized_key pattern is exactly where it comes up most.

这就是authorized_key模式的由来。


.. _looping_over_integer_sequences:

Looping over Integer Sequences
对数字序列使用循环
``````````````````````````````

``with_sequence`` generates a sequence of items in ascending numerical order. You
can specify a start, end, and an optional step value.

``with_sequence``可以以升序数字顺序生成一组序列。你可以指定起始值、终止值，以及一个可选的步长值。

Arguments should be specified in key=value pairs.  If supplied, the 'format' is a printf style string.

指定参数时也可以使用key=value这种键值对的方式。如果采用这种方式，'format'是一个可打印的字符串。

Numerical values can be specified in decimal, hexadecimal (0x3f8) or octal (0600).
Negative numbers are not supported.  This works as follows::

数字值可以被指定为10进制，16进制(0x3f8)或者八进制(0600)。复数则不受支持。请看以下示例::

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

Random Choices

随机选择
``````````````

The 'random_choice' feature can be used to pick something at random.  While it's not a load balancer (there are modules
for those), it can somewhat be used as a poor man's loadbalancer in a MacGyver like situation::

'random_choice'功能可以用来随机获取一些值。它并不是负载均衡器(以及有相关的模块了),它可以作为一个简化版的负载均衡器，比如在MacGyver中作为条件判断::

    - debug: msg={{ item }}
      with_random_choice:
         - "go through the door"
         - "drink from the goblet"
         - "press the red button"
         - "do nothing"

One of the provided strings will be selected at random. 

提供的字符串中的其中一个会被随机选中。 

At a more basic level, they can be used to add chaos and excitement to otherwise predictable automation environments.

还有一个基本的场景，该功能可用于在一个可预测的自动化环境中引入混乱和兴奋点。

.. _do_until_loops:

Do-Until Loops

Do-Until循环
``````````````

.. versionadded: 1.4

Sometimes you would want to retry a task until a certain condition is met.  Here's an example::

有时你想重试一个任务直到达到某个条件。比如下面这个例子::
   
    - action: shell /usr/bin/foo
      register: result
      until: result.stdout.find("all systems go") != -1
      retries: 5
      delay: 10

The above example run the shell module recursively till the module's result has "all systems go" in its stdout or the task has
been retried for 5 times with a delay of 10 seconds. The default value for "retries" is 3 and "delay" is 5.

上面的例子递归运行shell模块，直到模块结果中的stdout输出中包含"all systems go"字符串，或者该任务按照10秒的延迟重试超过5次。"retries"和"delay"的默认值分别是3和5。

The task returns the results returned by the last task run. The results of individual retries can be viewed by -vv option.
The registered variable will also have a new key "attempts" which will have the number of the retries for the task.

该任务返回最后一个任务返回的结果。单次重试的结果可以使用-vv选项来查看。
被注册的变量会有一个新的属性'attempts',值为该任务重试的次数。

.. _with_first_found:

Finding First Matched Files

查找第一个匹配的文件
```````````````````````````

.. note:: This is an uncommon thing to want to do, but we're documenting it for completeness.  You probably won't be reaching for this one often.

This isn't exactly a loop, but it's close.  What if you want to use a reference to a file based on the first file found
that matches a given criteria, and some of the filenames are determined by variable names?  Yes, you can do that as follows::

    - name: INTERFACES | Create Ansible header for /etc/network/interfaces
      template: src={{ item }} dest=/etc/foo.conf
      with_first_found:
        - "{{ansible_virtualization_type}}_foo.conf"
        - "default_foo.conf"

This tool also has a long form version that allows for configurable search paths.  Here's an example::

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

Iterating Over The Results of a Program Execution
`````````````````````````````````````````````````

.. note:: This is an uncommon thing to want to do, but we're documenting it for completeness.  You probably won't be reaching for this one often.

Sometimes you might want to execute a program, and based on the output of that program, loop over the results of that line by line.
Ansible provides a neat way to do that, though you should remember, this is always executed on the control machine, not the local
machine::

    - name: Example of looping over a command result
      shell: /usr/bin/frobnicate {{ item }}
      with_lines: /usr/bin/frobnications_per_host --param {{ inventory_hostname }}

Ok, that was a bit arbitrary.  In fact, if you're doing something that is inventory related you might just want to write a dynamic
inventory source instead (see :doc:`intro_dynamic_inventory`), but this can be occasionally useful in quick-and-dirty implementations.

Should you ever need to execute a command remotely, you would not use the above method.  Instead do this::

    - name: Example of looping over a REMOTE command result
      shell: /usr/bin/something
      register: command_result

    - name: Do something with each result
      shell: /usr/bin/something_else --param {{ item }}
      with_items: command_result.stdout_lines

.. _indexed_lists:

Looping Over A List With An Index
`````````````````````````````````

.. note:: This is an uncommon thing to want to do, but we're documenting it for completeness.  You probably won't be reaching for this one often.

.. versionadded: 1.3

If you want to loop over an array and also get the numeric index of where you are in the array as you go, you can also do that.
It's uncommonly used::

    - name: indexed loop demo
      debug: msg="at array position {{ item.0 }} there is a value {{ item.1 }}"
      with_indexed_items: some_list

.. _flattening_a_list:

Flattening A List
`````````````````

.. note:: This is an uncommon thing to want to do, but we're documenting it for completeness.  You probably won't be reaching for this one often.

In rare instances you might have several lists of lists, and you just want to iterate over every item in all of those lists.  Assume
a really crazy hypothetical datastructure::

    ----
    # file: roles/foo/vars/main.yml
    packages_base:
      - [ 'foo-package', 'bar-package' ]
    packages_apps:
      - [ ['one-package', 'two-package' ]]
      - [ ['red-package'], ['blue-package']]

As you can see the formatting of packages in these lists is all over the place.  How can we install all of the packages in both lists?::

    - name: flattened loop demo
      yum: name={{ item }} state=installed 
      with_flattened:
         - packages_base
         - packages_apps

That's how!

.. _using_register_with_a_loop:

Using register with a loop
``````````````````````````

When using ``register`` with a loop the data structure placed in the variable during a loop, will contain a ``results`` attribute, that is a list of all responses from the module.

Here is an example of using ``register`` with ``with_items``::

    - shell: echo "{{ item }}"
      with_items:
        - one
        - two
      register: echo

This differs from the data structure returned when using ``register`` without a loop::

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

Subsequent loops over the registered variable to inspect the results may look like::

    - name: Fail if return code is not 0
      fail:
        msg: "The command ({{ item.cmd }}) did not have a 0 return code"
      when: item.rc != 0
      with_items: echo.results

.. _writing_your_own_iterators:

Writing Your Own Iterators
``````````````````````````

While you ordinarily shouldn't have to, should you wish to write your own ways to loop over arbitrary datastructures, you can read :doc:`developing_plugins` for some starter
information.  Each of the above features are implemented as plugins in ansible, so there are many implementations to reference.

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


