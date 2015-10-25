常见问题
==========================

这是一些常见问题和回答

.. _set_environment:

我可以为一个任务(task)或剧本(playbook)设置 PATH 或者其它环境变量吗？
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

可以通过 `environment` 关键字设置环境变量，可以用在 task 或者 play 上
    
    environment:
      PATH: "{{ ansible_env.PATH }}:/thingy/bin"
      SOME: value



如何处理需要不同账户与端口登录的不同机器？
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

设置清单(inventory)文件是最简单的方式

例如，假设这些主机有不同的用户名和端口

    [webservers]
    asdf.example.com  ansible_ssh_port=5000   ansible_ssh_user=alice
    jkl.example.com   ansible_ssh_port=5001   ansible_ssh_user=bob

你也可以指定什么类型的连接。

    [testcluster]
    localhost           ansible_connection=local
    /path/to/chroot1    ansible_connection=chroot
    foo.example.com
    bar.example.com 

你可能想保存这些组变量，或者一些变量文件。 看剩余的文档获取更多有关如何组织变量的信息

.. _use_ssh:

如何让 ansible 重用连接，启用 Kerberized SSH，或者让Ansible 注意本地的 SSH config 文件。
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

转换默认连接类型，在配置文件里面设置为,'ssh'，或者使用 '-c ssh'选项使用OpenSSH连接，而不是python的paramiko库。在 Ansible 1.2.1之后，'ssh'会默认使用。

paramiko在刚开始的时候是不错的，但是OpenSSH提供更多的高级选项。如果你正在使用这种连接类型的话，你可能会想在一个支持 ControlPersist 的新机器上运行 Ansible。你同样可以管理老的客户端。如果你正在用 RHEL6，CentOS6，SLES 10或 SLES 11，OpenSSH的版本仍然有些过时，因此考虑使用Fedora或OpenSUSE客户端来管理节点，或者使用paramiko。

我们默认让paramiko作为默认选项，如果你第一次安装Ansible在一个EL box上，它提供了更好的用户体验。

.. _ec2_cloud_performance:

如何在EC2内加速管理？
++++++++++++++++++++++++++++++++++++++++

不要试着用你的笔记本电脑管理一群 EC2 机器。连接到EC2内的管理节点然后在里面运行Ansible

.. _python_interpreters:

如何处理远程机器上没有 /usr/bin/python 路径？
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

尽管你可以使用其他语言编写 Ansible 模块，但大部分 Ansible 模块是用 Python 写的 ，而且一些事非常重要的核心模块

默认情况下， Ansible 假定它可以在远程机器上找到 2.x版本以上的 /usr/bin/python ，指定为2.4或者更高的版本。

设置 inventory 变量 'ansible_python_interpreter' ，允许 Ansible自动替换掉默认的 python解释器。因此你可以指向任何版本的 python ，尽管/usr/bin/python不存在

一些 Linux 操作系统，例如 Arch 可能默认安装的是 Python 3. 这会让你在运行模块的时候出现语法错误信息。 Python 3和 Python 2 在本质上还是有些区别的。Ansible 当前需要支持哪些更老版本的 Python 用户，因此还没有支持 Python 3.0。这不是一个问题，只需要安装 Python2 就可以解决问题。

当 Ansible 或 Python3.0 后来变得更加主流的时候，会支持Python 3.0

不要替换 python 模块的 shebang 行，Ansible 在部署的时候会自动处理。

.. _use_roles:

让内容重用和重新分发的最好方式是什么？
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

如果你还没有做好， 请阅读 playbooks 文档的 "Roles" 部分。 这会让你更好的理解 playbook 的内容。(This helps you make playbook content self-contained, and works well with things like git submodules for sharing content with others.)

如果你对这些插件很陌生，查看 API 文档获取更多的有关扩展 Ansible 的细节信息
.. _configuration_file:

配置文件在那个地方，我如何配置它？
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

看 :doc:`intro_configuration`.

.. _who_would_ever_want_to_disable_cowsay_but_ok_here_is_how:

如何禁止 cowsay?
++++++++++++++++++++++++

如果你确定你想运行在没有cowsay的环境下，你可以卸载 cowsay，或者设置环境变量 

    export ANSIBLE_NOCOWS=1

.. _browse_facts:

How do I see a list of all of the ansible\_ variables?
如何查看所有的 ansible_variables?
++++++++++++++++++++++++++++++++++++++++++++++++++++++

默认情况下，Ansible 收集 有关机器的 "facts" ，这些 facts 可以被Playbook或templates访问。想要查看相关机器的所有的facts，运行 "setup" 模块。

    ansible -m setup hostname

这会打印指定主机上的所有的字典形式的facts。

.. _host_loops:

如何遍历某一组内的所有主机，在模板中？
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

一个通用的做法是遍历组内的所有主机，你可以访问 "$groups" 字典在模板中，就像这样

    {% for host in groups['db_servers'] %}
        {{ host }}
    {% endfor %}

如果你需要访问有关这些主机的 facts ，例如每个主机的IP地址，你需要确保 facts 已经被 populated 了。例如

    - hosts:  db_servers
      tasks:
        - # doesn't matter what you do, just that they were talked to previously.

然后你可以使用 facts 在模板里面，就像这样

    {% for host in groups['db_servers'] %}
       {{ hostvars[host]['ansible_eth0']['ipv4']['address'] }}
    {% endfor %}

.. _programatic_access_to_a_variable:

如何以编程方式访问变量名
+++++++++++++++++++++++++++++++++++++++++++++++++

可能出现这种情况,我们需要一个任意的ipv4地址接口,同时这个接口是通过角色提供参数或其他输入提供的。变量名可以通过组合字符串来构建，就像这样::

    {{ hostvars[inventory_hostname]['ansible_' + which_interface]['ipv4']['address'] }}

这个遍历主机变量的技巧是必要的，因为它是一变量名称扣减的字典。'inventory_hostname' 是一个神奇的变量，因为它告诉你你在主机组循环中当前的主机是谁。

.. _first_host_in_a_group:

如何访问组内第一个主机的变量？
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

如果我们想要在 webservers 组内的第一个 webserver 的 ip 地址怎么办？我们可以这么做。注意如果再使用动态 inventory ， 'first' 的主机可能不会一致 ，因此你不希望这样，除非你耳朵 inventory 是静态。(如果你在用 :doc:`tower`,它会使用数据库指令，因此这不是个问题尽管你正在使用基于云环境的 inventory 脚本)

这里是技巧：

    {{ hostvars[groups['webservers'][0]]['ansible_eth0']['ipv4']['address'] }}

注意我们如何获得 webserver 组内的第一台机器的主机名的。如果你也在在模板中这么做，你可以用 Jinja2 "#set" 指令来简化这，或者在一个基本中，你也可以设置 fact

    - set_fact: headnode={{ groups[['webservers'][0]] }}
 
    - debug: msg={{ hostvars[headnode].ansible_eth0.ipv4.address }}

注意我们如何交换花括号的语法点(Notice how we interchanged the bracket syntax for dots)。

.. _file_recursion:

如何递归的宝贝文件到目标主机上?
+++++++++++++++++++++++++++++++++++++++++++++++++++

"copy" 模块有递归的参数，如果你想更加高徐璈的处理大量的文件，看一下 "synchronize"模块，封装了rsync。自行看一些模块索引获取一些他们的信息。

.. _shell_env:

如何查看 shell 环境变量？
++++++++++++++++++++++++++++++++++++++++++++

如果是只是想看看，使用 `env` 查看。例如，如果想查看在管理机器上 HOME 环境变量的值。
   ---
   # ...
     vars:
        local_home: "{{ lookup('env','HOME') }}"

如果你是想设置环境变量，查看高级的有关环境的 Playbook 部分。

Ansible 1.4 will also make remote environment variables available via facts in the 'ansible_env' variable::
Ansible1.4也会让远程的环境变量可用通过 facts 在 'ansible_env' 变量。
   {{ ansible_env.SOME_VARIABLE }}

.. _user_passwords:

如何为用户模块生成加密密码？
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

mkpasswd工具在大多数linux系统上都可以使用，是一个不错的选项

    mkpasswd --method=SHA-512

如果这个工具在你系统上面没安装，你可以简单的通过 Python 生成密码。首先确保 `Passlib <https://code.google.com/p/passlib/>`_ 密码哈西库已经安装了。

    pip install passlib

一旦库准备好了，SHA512密码值可以被生成通过下面命令生成。

    python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())"

.. _commercial_support:

如何获得Ansible培训到商业支持？
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Yes！ 看我们的 `services page <http://www.ansible.com/services>`_  获得更多的信息关于我们的服务和培训服务。支持也包含在 :doc:`tower` 。发邮件到`info@ansible.com <mailto:info@ansible.com>`_ 获取更深的细节。

我们也会提供免费的培训课程在基础上。 看  `webinar page <http://www.ansible.com/webinars-training>`_ 获得更多信息在下面的研讨会上。

.. _web_interface:

有网络接口  / REST API / etc? 
++++++++++++++++++++++++++++++++++++++++++

Yes！Ansible 做了很好的产品让 Ansible 更加的强大容器使用，看 :doc:`tower`

.. _docs_contributions:

如何提交文档改变信息？
++++++++++++++++++++++++++++++++++++++++++++++

不错的问题！ Ansible 文档保存在主项目git 源下面，指导贡献可以在 docs README `viewable on GitHub <https://github.com/ansible/ansible/blob/devel/docsite/README.md>`_找到。谢谢！

.. _keep_secret_data:

如何加密我的剧本数据？
+++++++++++++++++++++++++++++++++++++++++

如果你想加密数据，仍然想要在源码控制上分享给大家。看 :doc:`playbooks_vault`.

.. _i_dont_see_my_question:

在 Ansible 1.8后，如果你有一个任务，你不想显示结果，或者给了命令 -v 选项，下面的例子很有用

    - name: secret task
      shell: /usr/bin/do_something --value={{ secret_value }}
      no_log: True

这个对保持详细的输出，但是从其他人那里隐藏了敏感的信息。

no_log属性也可以应用在整个 play 里面。

    - hosts: all
      no_log: True


尽管这回让play很难调试。推荐使用这个应用到单一任务上。

在这里我没看到我的问题
++++++++++++++++++++++++++++

请看下面的部分链接到 IRC 和 Google Group，你可以在那里提问你的问题。

.. seealso::

   :doc:`index`
       The documentation index
   :doc:`playbooks`
       An introduction to playbooks
   :doc:`playbooks_best_practices`
       Best practices advice
   `User Mailing List <http://groups.google.com/group/ansible-project>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel



