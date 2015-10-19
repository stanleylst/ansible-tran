Community Information & Contributing
社区信息与贡献
````````````````````````````````````
   
Ansible是一个开源项目,它被设计于让开发者和管理员在共同构建自动化解决方案的时候更好的合作.

你想要参与进来吗 -- 不论是问问题,帮助其它用户,像新人介绍ansible,或者帮助软件和文档的完善,我们都非常欢迎你对这个项目的贡献.

.. contents:: Topics

Ansible用户
=============

我有个问题
-------------------

我们很乐意帮助你！

Ansible问题最好在Ansible的google谈论组上面询问.`Ansible Google Group Mailing List <http://groups.google.com/group/ansible-project>`_.  

这里有非常多的回答问题的列表和分享的技巧.任何人都可以加入进来,如果你只想在线阅读的话,发送邮件是可选的.为了减少垃圾邮件,尽管投递很快就被批准,你的第一次投递还是可能比较慢.

在问问题的时候,确保让大家知道你运行的相关命令,输出内容,一些细节,和你使用的Ansible版本

在需要的使用实例场合,尽量链接到 github 上展示,而不是在邮件列表中发送附件.

推荐你在问问题之前使用 Google 搜索,查看是否相关问题已经被回答过了,但是如果在注释中发现时间很久了,相关主题可能不再回复.

在问问题之前,确保使用的是最新的稳定版本的 Ansible ,你可以通过对比命令 'ansible --version' 的输出和 `PyPi <https://pypi.python.org/pypi/ansible>` 上面的版本来进行检查.

同样,你可以加入 IRC 频道 - #ansible on irc.freenode.net .这也是一个很活跃的频道, 如果还没在邮件列表中没有找到你想要的答案,因为邮件是异步的,请暂停发送邮件,你的邮件可能会引起核心开发人员的注意.

我想跟上版本发布公告
----------------------------------------------

版本通知发布在 ansible 的项目上面,如果你不想跟上最新的邮件列表,你可以加入 Ansible 匿名邮件列表 `Ansible Announce Mailing List <http://groups.google.com/group/ansible-announce>`_

这是一个低流量的只读邮件列表,我们指挥在这里发布版本通知和 可选的通向到 Ansible 大事件的链接

我想帮助分享和改善Ansible
------------------------------------------

你可以通过告诉朋友和同事,写博客,来把 Ansible 分享给其它人,或者出现在用户讨论组上面(像 DevOps组,或者本地 LUG)

你可以注册一个免费的账户标记为 "Ansible",在 speakerdeck 上面分享你的幻灯片.在推特上,你可以和 ansible 一起分享,或者跟随我们  `follow us <https://twitter.com/ansible>`_.

我想让Ansible开发的更快
------------------------------------

如果你是一个开发者,最有价值的事情就是查看 github issue 列表,帮助修复 bug.我们总是在特性开发时,优先考虑修复 bug 问题,因此你可以做的最好的事情就是清楚 bug .

如果你不是开发者,帮助测试提交的 bug 修复问题,也是很有价值的.你可以检验 ansible,在主分支下,开一个测试分支,合并 github 上的问题,测试,然后在指定的 issue 上面注释.

我想报告 Bug
------------------------------------

Ansible实际使用中暴露的问题 -- 如果和安全相关,请发邮件到 `security@ansible.com <mailto:security@ansible.com>`,而不是发到 Google 讨论组上面 .

有关核心语言的 Bug 应该被报道到 `github.com/ansible/ansible <https://github.com/ansible/ansible>` .在报告一个 Bug 之前首先检查 bug/issue 查看有关 issue 是否被报告了.

模块相关的 Bugs 应该基于模块的分类发到 `ansible-modules-core <https://github.com/ansible/ansible-modules-core>` 或者  `ansible-modules-extras <https://github.com/ansible/ansible-modules-extras>` .这会被列到模块文档的底部.

当你填bug信息的时候,模块请使用 `issue template <https://github.com/ansible/ansible/raw/devel/ISSUE_TEMPLATE.md>` 提供所有相关的信息,不管你正在填什么类型的表格.
(When filing a bug, please use the `issue template <https://github.com/ansible/ansible/raw/devel/ISSUE_TEMPLATE.md>`_ to provide all relevant information, regardless of what repo you are filing a ticket against.)

知道你ansible的版本,和你运行的具体的命令,你期望什得到什么结果,将会帮助我们和每个人世间,更快的知道问题.

不要使用类似,"我如何做(how do I do this)" 类型的问题.这里都是 IRC 的参与者回答有用的问题,而不是讨论有什么问题的.学会提问.

尊重审稿人,使审稿人有时间帮助更多的忍,请提供 良好注释,语言简洁的playbook,包括playbook的片段和输出内容.有用的信息尽量提出来,省略无用的信息

当在 playbook 分享 YAML 时候,格式可以被保存通过使用 `code blocks <https://help.github.com/articles/github-flavored-markdown#fenced-code-blocks>`

对于多文件的内容,推荐使用 gist.github.com. 在线 pastebin 内容可能会过期,因此如果他们被长时间的引用,最好时间放久一点.(For multiple-file content, we encourage use of gist.github.com.  Online pastebin content can expire, so it's nice to have things around for a longer term if they
are referenced in a ticket.)

如果你不确定你提供的是否为 bug,欢迎到 IRC 邮件列表提问一些相关的事情.

因为我们是一个大文献的项目,如果你确定你有一个 bug ,请确保你打开 issue ,确保我们有这个与你有关的issue记录.不要依靠社区的其他人代替你上传这个bug.

得到你的报告可能会花一些世间,具体信息查看下面的优先级标识.

我想帮助改善文档
-----------------------------------

ansible 的文档也是一个社区项目.

如果你想帮助改善文档,纠正错别字,或者改善一些章节,或者写一个新特性的文档, 提交一个 github pull 请求,代码位于“docsite/rst” 子目录,同样也有一个 "Edit On Github"连接到哪里的.

模块文档嵌入在源码模块的底部,模块可能是 ansible-modules-core 或者 ansible-modules-extra 取决于在github上的模块.关于这的信息一直列在网页文档的每个模块底部

除了模块,主文档也在重建文本格式.(Aside from modules, the main docs are in restructured text format.  )

如果你对新的重组的文本不满意,你可以在 github 上打开一个的标签,关于你发现的错误,或者你想添加的部分.更多的信息或者创建 pull 请求,请参考 `github help guide <https://help.github.com/articles/using-pull-requests>`_.

对当前和未来的开发人员
=======================================

我想学习如何在 Ansible 上开发
-------------------------------------------

如果你刚开始使用 Ansible,想弄明白 Ansible 内部的工作机制,停止 Ansible-devel 邮件列表,像我们打个招呼,我们会带你开始的.

一个好的开始方式可以是在模块网站上阅读一些开发文档,然后找到一个 bug 然后修复,或者添加一些新的小特性.

模块最容易开始地方.

贡献代码(特性或者修复bug)
----------------------------------------

Ansible 项目的源代码托管在 github 上 ,核心应用位于 `github.com/ansible/ansible <https://github.com/ansible/ansible>`_ ,还有两个模块相关的子项目  `github.com/ansible/ansible-modules-core <https://github.com/ansible/ansible-modules-core>`_. 如果你想知道一个模块是核心模块("core")还是额外模块("extras"),查阅那个模块的网页文档.

在提交代码之前,先到 ansible-devel 邮件列表讨论一下特性问题,这可以有效的避免后期重复的工作.如果你不确定一个新的特性是否合适,先去开发邮件列表讨论一下,这样相对后来不得不修改一个 pull 请求更容易一些.

提交补丁的时候,一定要先运行单元测试“make tests”, 有一些基本的测试会自动运行当创建PR时候. 有更多的深入测试在测试/集成目录,分为 destructive 和 non_destructive,运行这些如果他们属于你的修改.他们被设置了标签,这样你就可以运行子集,一些测试需要云凭证和只有他们提供的时候才会运行.当添加修复 bug 的新的特性的时候,最好添加新的测试防止后期重新回滚.

使用 "git rebase" vs "git merge"(让git pull 别名为git pull -rebase 是一个好主意) ,来避免合并提交.也有一些基础测试可以运行在 "test/integration" 目录

为了保证历史代码的整洁,和对新假如的代码做更好的审计,我们会要求那些包含合并注释的重新提交.使用"git pull --rebase" 而不是 "git pull" 和 "git rebase" 而不是 "git merge".同样确保有主要分支在使用其他的分支的时候,这样你才不会丢失注释信息.(Also be sure to use topic branches to keep your additions on different branches, such that they won't pick up stray commits later.)

如果你犯错了,你不需要关闭你的 PR ,创建一个清洁的本地分支然后推送到github上面使用 --force 选项,轻质覆盖已存在的分支(在没人使用哪个分支作为参考的情况下是允许的).代码注释不会丢失,他们只是不会连接到现有的分支

然后我们将审阅你的贡献和参与你的问题等等.

因为我们有一个非常大的和活跃的社区,我们可能需要一段时间才能看到你的贡献,看一下后面的优先级部分来了解一下我们的工作队列.要有耐心,你的要求可能不会马上合并,我们也让 devel 能够使用,因此我们需要小心的测试pull 请求,而这需要花费时间.

补丁应该一直在开发分支之上.

记住,小而专请求更容易检查和接受,如果有实例,会更加帮助我们理解 bug 修复的工具和新的特性.

贡献可以是新的特性,像模块,或者是修复一些你或其他人发现的 bug .如果你对写新模块感兴趣,请参考 `module development documentation <http://docs.ansible.com/developing_modules.html>`_.

Ansible的理念鼓励简单、可读的代码和 一致的,保守扩展, 向后兼容的改进.代码开发Ansible需要支持Python 2.6 +, 而代码模块运行需要在Python 2.4之上.请使用4个空格的缩进,而不是tab,(we do not enforce 80 column lines, we are fine with 120-140. We do not take 'style only' requests unless the code is nearly unreadable, we are "PEP8ish", but not strictly compliant.)

你也可以通过测试和修改其他请求贡献,特别是如果它是一个你用着有趣的东西.请保持你的评论清楚和中肯,礼貌的和有建设性的, ticket 不是一个好开始讨论的地方( ansible-devel 和 IRC 是专门为 tickets 的).

技巧：为了更容易的从一个分支运行,source "./hacking/env-setup" 就这样,不需要安装.

其它主题
============

Ansible 职员
-------------

Ansible 一家支持Ansible和基于 Ansible 构建额外的解决方案的公司.我们会服务和支持那些有趣的东西.我们还提供了一个企业 web 前端 Ansible(见下面的 Tower ).

我们最重要的任务是使 ansible 社区发生一些大事,包括组织Ansible的软件版本.想获取更多的信息,联系 info@ansible.com

在 IRC 上,你可以找到我们 jimi_c, abadger1999, Tybstar, bcoca.在邮件列表上,我们使用 @ansible.com 的地址发送.

邮件列表信息
------------------------

Ansible有一些邮件列表,因为审核的原因,你的第一次投递邮件可能时间稍长,请允许一天时间的延迟.

`Ansible Project List <https://groups.google.com/forum/#!forum/ansible-project>`_ 分享 Ansible的技巧,问题解答,用户讨论.

`Ansible Development List <https://groups.google.com/forum/#!forum/ansible-devel>`_ 学习如何在Ansible上开发,询问ansible未来的设计特性,讨论扩展ansible或者正在进行的ansible特性.

`Ansible Announce list <https://groups.google.com/forum/#!forum/ansible-announce>`_ 关于ansible版本号的只读共享信息,小频率的ansible事件信息.例如：通知AnsibleFest的出现.

`Ansible Lockdown List <https://groups.google.com/forum/#!forum/ansible-lockdown>`_ 关于ansible lockdown项目的所有信息,包括DISA STIG 自动化和 CIS Benchmarks

对于非google账户订阅一个组,你可以发送邮件到这订阅地址请求订阅,例如：ansible-devel+subscribe@googlegroups.com

版本号
-----------------

以 ".0" 结尾的版本是朱版本,同时将会有很多新的特性.以其他整数结尾的 ,像"0.X.1" 和 "0.X.2"是小版本,这些仅仅包含 bug 修复

通常来说,我们不会发布小版本号(保存用于大的项目),但是如果现在具体下次发布会有很长时间的话,偶尔可能决定去除包含大量修复的小版本.

版本号基于没有其他人使用 Van Halen 的歌曲命名.

Tower 支持问题
-----------------------

Ansible `Tower <http://ansible.com/tower>` 是一个对 ansible 提供的用户接口,服务,应用程序接口等等.

如果你有关于 tower的问题,发送邮件到 `support@ansible.com <mailto:support@ansible.com>` 而不是在IRC频道上,或者一般邮件列表上提问

IRC 频道
-----------

Ansible 有IRC 频道 #ansible on irc.freenode.net.

注意优先级的标识
-----------------------

在2013年,Ansible 位于 github 上开源软件的前 5 名,到目前为止,有 800 多个对此项目贡献者,更不用说一个非常大的用户社区,下载了这个应用超过一百万次了.因此,我们有将会有很多的活动.

下面,我们会告诉你如何处理新来的请求的.

在我们的 bug traker 中你会注意到一些标签- P1,P2,P3,P4和P5.这是我们的内部用于对提交的 bug 排序的.

除了一些例外,便于合并(比如文档类型), 我们都会首先花时间处理 P1 和 P2 item,包括 pull 请求.这些通常与重大的 bug 有关,同时影响大量的用户群里.因此,如果你看到一些 "P3 or P4 的分类,那些将不会得到立即的关注.

这些标签没有定义,它们只是简单的排序.然而,有些东西影响核心模块(yum,apt,等等)可能会有更高的优先级,相比那些影响少数用户的模块来说.

因为我们非常强调测试和代码审查,可能需要几个月的小功能合并.

但是不要担心,我们也会定期的给迪有限的队列做定期的清理,给予一些关注,由其在新模块的改变上面.因此,这不意味着我们把精力都花费在高优先级的东西上,而忽略了你的 请求(ticket)

任何努力都会有帮助的,如果你促进快P3的 pull request 特性 ,你可以做的最好的事情是帮助处理 P2 bug 报告.

社区代码和产品
-------------------------

社区欢迎所有类型的用户,什么背景,什么技术级别都可以.请尊敬其他人就像你想让其他人尊敬你一样,保持讨论的活跃氛围,不要产生冲突,避免各种歧视,亵渎,避免无用的争论(例如:vi和emace那个更好一样.)

在社区事件上面也是希望大家好好相处

邮件列表应该集中在IT自动化上面.滥用社区的指南将不会被容忍,后果是禁用社区资源

贡献执照许可
------------------------------

通过贡献,你被授予一个完整的,不可吊销的版权执照,依据这个项目的执照,这个执照对这个项目的所有用户和开发者都有效.
