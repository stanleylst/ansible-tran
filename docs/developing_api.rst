Python API
==================

.. contents:: Topics

本章将展示几种有趣的Ansible API调用方式.你可以使用Ansible的Python API来管理节点,可以通过扩展Ansible来响应大量的Python事件,你可以写各种的插件,并且,你可以通过插件来调取外部数据源.本文主要向读者简单介绍一下 Runner 和 Playbook 的API.

如果你想使用除Python的其他方法调用Ansible,使用其异步回调事件,或者访问控制,日志管理,可以访问 :doc:`tower`,它提供了非常丰富的 REST API.

此外,Ansible本身也是基于他本身的API来实现的,所以你将拥有足够的权限来进行二次封装.本章将讨论Python API的使用.

.. _python_api:

Python API
--------------

Ansible的Python API 功能十分强大,它造就了ansible CLI和ansible-playbook.

以下是一个简单调用的例子::

    import ansible.runner

    runner = ansible.runner.Runner(
       module_name='ping',
       module_args='',
       pattern='web*',
       forks=10
    )
    datastructure = runner.run()


该方法将返回每个host主机是否可以被ping通.返回类型详情请参阅 :doc:`modules`.::

    {
        "dark" : {
           "web1.example.com" : "failure message"
        },
        "contacted" : {
           "web2.example.com" : 1
        }
    }


每个模型均可以返回任意JSON格式数据,所以Ansible可以作为一个框架被封装在各种应用程序和脚本之中.

.. _detailed_api_example:

更具体的例子
`````````````````````

以下的脚本将打印出所有机器的运行时间和系统负载信息::

    #!/usr/bin/python

    import ansible.runner
    import sys

    # 构造ansible runner 并且开启10个线程向远程主机执行uptime命令
    results = ansible.runner.Runner(
        pattern='*', forks=10,
        module_name='command', module_args='/usr/bin/uptime',
    ).run()

    if results is None:
       print "No hosts found"
       sys.exit(1)

    print "UP ***********"
    for (hostname, result) in results['contacted'].items():
        if not 'failed' in result:
            print "%s >>> %s" % (hostname, result['stdout'])

    print "FAILED *******"
    for (hostname, result) in results['contacted'].items():
        if 'failed' in result:
            print "%s >>> %s" % (hostname, result['msg'])

    print "DOWN *********"
    for (hostname, result) in results['dark'].items():
        print "%s >>> %s" % (hostname, result)


高级的开发人员可能会去阅读ansible的源码,但使用 Runner() API （使用它能提供的选项）可以增强命令行执行 ``ansible`` 和 ``ansible-playbook`` 的功能.

.. seealso::

   :doc:`developing_inventory`
       Developing dynamic inventory integrations
   :doc:`developing_modules`
       How to develop modules
   :doc:`developing_plugins`
       How to develop plugins
   `Development Mailing List <http://groups.google.com/group/ansible-devel>`_
       Mailing list for development topics
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel

