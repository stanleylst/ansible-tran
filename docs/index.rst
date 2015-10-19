Ansible 文档
=====================

有关Ansible
`````````````

欢迎来到Ansible文档。

Ansible是一个IT自动化工具。它可以配置系统，开发软件，或者编排高级的IT任务，例如持续开发或者零宕机滚动更新。

Ansible的主要目标是简单易用。它也同样专注安全性和可靠性，最小化的移动部件，使用Openssh传输(有加速socket模式和同样可用拉取模式)，易于人类阅读的语言--尽管不熟悉编程人也可以看得懂。

我们相信简单在所有环境中都有用，因此我们设计服务忙碌的用户:开发者，系统管理员，版本工程，IT管理员，或者其中的每个人。Ansible适用于管理所有类型的环境，从随手可安装的实例，到企业级别的成千上万个实例都可行。

Ansible 管理机器使用无代理的方式。更新远端服务进程或者因为服务未安装导致的问题在 Ansible 里面从来不会发生。因为 Openssh 是很流行的开源组件，安全为题大大降低了。Ansible 是非中心化的,它依赖于现有的操作系统凭证来访问控制远程机器。如果需要的话, Ansible 可以使用 Kerberos , LDAP 和其他集中式身份验证管理系统。

这个文档覆盖当前的版本 Ansible 1.9.1 和一些开发版本特性(2.0)。对于最新的特性，我们注意在版本的每个部分添加特性

Ansible。每两个月发布一次主版本号。核心应用程序的开发有些保守,重视语言的简单设计和设置。然而,周围的社区新模块和插件开发和移动非常快,通常在每个版本中添加20个左右的新模块。

.. _an_introduction:

.. toctree::
   :maxdepth: 1

   intro
   quickstart
   playbooks
   playbooks_special_topics
   modules
   modules_by_category
   guides
   developing
   tower
   community
   galaxy
   test_strategies
   faq
   glossary
   YAMLSyntax


