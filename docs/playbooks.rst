Playbooks
`````````
Playbooks 是 Ansible的配置,部署,编排语言.他们可以被描述为一个需要希望远程主机执行命令的方案,或者一组IT程序运行的命令集合.

如果 Ansible 模块你是工作室中的工具,那么 playbooks 就是你设置的方案计划.

作为最基本的应用, playbooks 可以用于远程主机的配置文件管理和应用部署.作为高级应用, (下面这段也没有看懂什么意思,不敢擅作揣测,有了解的朋友可以联系博主)At a more advanced level, they can sequence multi-tier rollouts involving rolling updates, and can delegate actions to other hosts, interacting with monitoring servers and load balancers along the way.    

虽然这里讲发很多,但是不需要立刻一次性全部学完.你可以从小功能开始,当你需要的时候再来这里找对应的功能即可. 

Playbooks 被设计的非常简单易懂和基于text language二次开发.有多种办法来组织 playbooks 和其附属的文件,同时我们也会提供一些关于学习 Ansible 的建议.

这里强烈建议在阅读的 playbook 文档的时候同步参阅 `Example Playbooks <https://github.com/ansible/ansible-examples>` 章节. 这些例子是最佳实战以及如何将各种概念灵活贯穿结合在一起.

.. toctree::
   :maxdepth: 1

   playbooks_intro
   playbooks_roles
   playbooks_variables
   playbooks_filters
   playbooks_conditionals
   playbooks_loops
   playbooks_best_practices


