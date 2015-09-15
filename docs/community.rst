Community Information & Contributing
社区信息与贡献
````````````````````````````````````
   
Ansible是一个开源项目，它被设计于让开发者和管理员在共同构建自动化解决方案的时候更好的合作。

你想要参与进来吗 -- 不论是问问题，帮助其它用户，像新人介绍ansible，或者帮助软件和文档的完善，我们都非常欢迎你对这个项目的贡献。

.. 内容:: 主题

Ansible用户
=============

我有个问题
-------------------

我们很乐意帮助你！

Ansible问题最好在Ansible的google谈论组上面询问。`Ansible Google Group Mailing List <http://groups.google.com/group/ansible-project>`_.  

这里有非常多的回答问题的列表和分享的技巧。任何人都可以加入进来，如果你只想在线阅读的话，发送邮件是可选的。为了减少垃圾邮件，尽管投递很快就被批准，你的第一次投递还是可能比较慢。

在问问题的时候，确保让大家知道你运行的相关命令，输出内容，一些细节，和你使用的Ansible版本

在需要的使用实例场合，尽量链接到 github 上展示，而不是在邮件列表中发送附件。

推荐你在问问题之前使用 Google 搜索，查看是否相关问题已经被回答过了，但是如果在注释中发现时间很久了，相关主题可能不再回复。

在问问题之前，确保使用的是最新的稳定版本的 Ansible ，你可以通过对比命令 'ansible --version' 的输出和 `PyPi <https://pypi.python.org/pypi/ansible>` 上面的版本来进行检查。

同样，你可以加入 IRC 频道 - #ansible on irc.freenode.net .这也是一个很活跃的频道， 如果还没在邮件列表中没有找到你想要的答案，因为邮件是异步的，请暂停发送邮件，你的邮件可能会引起核心开发人员的注意。

我想跟上版本发布公告
----------------------------------------------

版本通知发布在 ansible 的项目上面，如果你不想跟上最新的邮件列表，你可以加入 Ansible 匿名邮件列表 `Ansible Announce Mailing List <http://groups.google.com/group/ansible-announce>`_

这是一个低流量的只读邮件列表，我们指挥在这里发布版本通知和 可选的通向到 Ansible 大事件的链接

我想帮助分享和改善Ansible
------------------------------------------

你可以通过告诉朋友和同事，写博客，来把 Ansible 分享给其它人，或者出现在用户讨论组上面(像 DevOps组，或者本地 LUG)

你可以注册一个免费的账户标记为 "Ansible"，在 speakerdeck 上面分享你的幻灯片。在推特上，你可以和 ansible 一起分享，或者跟随我们  `follow us <https://twitter.com/ansible>`_.

我想让Ansible开发的更快
------------------------------------

如果你是一个开发者，最有价值的事情就是查看 github issue 列表，帮助修复 bug。我们总是在特性开发时，优先考虑修复 bug 问题，因此你可以做的最好的事情就是清楚 bug 。

如果你不是开发者，帮助测试提交的 bug 修复问题，也是很有价值的。你可以检验 ansible，在主分支下，开一个测试分支，合并 github 上的问题，测试，然后在指定的 issue 上面注释。

我想报告 Bug
------------------------------------

Ansible实际使用中暴露的问题 -- 如果和安全相关，请发邮件到 `security@ansible.com <mailto:security@ansible.com>`，而不是发到 Google 讨论组上面 。

有关核心语言的 Bug 应该被报道到 `github.com/ansible/ansible <https://github.com/ansible/ansible>` 。在报告一个 Bug 之前首先检查 bug/issue 查看有关 issue 是否被报告了。

模块相关的 Bugs 应该基于模块的分类发到 `ansible-modules-core <https://github.com/ansible/ansible-modules-core>` 或者  `ansible-modules-extras <https://github.com/ansible/ansible-modules-extras>` 。这会被列到模块文档的底部。

当你填bug信息的时候，模块请使用 `issue template <https://github.com/ansible/ansible/raw/devel/ISSUE_TEMPLATE.md>` 提供所有相关的信息，不管你正在填什么类型的表格。
(When filing a bug, please use the `issue template <https://github.com/ansible/ansible/raw/devel/ISSUE_TEMPLATE.md>`_ to provide all relevant information, regardless of what repo you are filing a ticket against.)

知道你ansible的版本，和你运行的具体的命令，你期望什得到什么结果，将会帮助我们和每个人世间，更快的知道问题。

不要使用类似，"我如何做(how do I do this)" 类型的问题。这里都是 IRC 的参与者回答有用的问题，而不是讨论有什么问题的。学会提问。

尊重审稿人，使审稿人有时间帮助更多的忍，请提供 良好注释，语言简洁的playbook，包括playbook的片段和输出内容。有用的信息尽量提出来，省略无用的信息

当在 playbook 分享 YAML 时候，格式可以被保存通过使用 `code blocks <https://help.github.com/articles/github-flavored-markdown#fenced-code-blocks>`

对于多文件的内容，推荐使用 gist.github.com. 在线 pastebin 内容可能会过期，因此如果他们被长时间的引用，最好时间放久一点。(For multiple-file content, we encourage use of gist.github.com.  Online pastebin content can expire, so it's nice to have things around for a longer term if they
are referenced in a ticket.)

如果你不确定你提供的是否为 bug，欢迎到 IRC 邮件列表提问一些相关的事情。

因为我们是一个大文献的项目，如果你确定你有一个 bug ，请确保你打开 issue ，确保我们有这个与你有关的issue记录。不要依靠社区的其他人代替你上传这个bug。

得到你的报告可能会花一些世间，具体信息查看下面的优先级标识。

我想帮助改善文档
-----------------------------------

ansible 的文档也是一个社区项目。

如果你想帮助改善文档，纠正错别字，或者改善一些章节，或者写一个新特性的文档， 提交一个 github pull 请求，代码位于“docsite/rst” 子目录，同样也有一个 "Edit On Github"连接到哪里的。

模块文档嵌入在源码模块的底部，模块可能是 ansible-modules-core 或者 ansible-modules-extra 取决于在github上的模块。关于这的信息一直列在网页文档的每个模块底部

除了模块，主文档也在重建文本格式。(Aside from modules, the main docs are in restructured text format.  )

如果你对新的重组的文本不满意，你可以在 github 上打开一个的标签，关于你发现的错误，或者你想添加的部分。更多的信息或者创建 pull 请求，请参考 `github help guide <https://help.github.com/articles/using-pull-requests>`_.

对当前和未来的开发人员
=======================================

我想学习如何在 Ansible 上开发
-------------------------------------------

If you're new to Ansible and would like to figure out how to work on things, stop by the ansible-devel mailing list
and say hi, and we can hook you up.

A great way to get started would be reading over some of the development documentation on the module site, and then
finding a bug to fix or small feature to add.

Modules are some of the easiest places to get started.

Contributing Code (Features or Bugfixes)
----------------------------------------

The Ansible project keeps its source on github at `github.com/ansible/ansible <https://github.com/ansible/ansible>`_ for
the core application, and two sub repos `github.com/ansible/ansible-modules-core <https://github.com/ansible/ansible-modules-core>`_
and `ansible/ansible-modules-extras <https://github.com/ansible/ansible-modules-extras>`_ for module related items.
If you need to know if a module is in 'core' or 'extras', consult the web documentation page for that module.

The project takes contributions through `github pull requests <https://help.github.com/articles/using-pull-requests>`_.

It is usually a good idea to join the ansible-devel list to discuss any large features prior to submission,
and this especially helps in avoiding duplicate work or efforts where we decide, upon seeing a pull request
for the first time, that revisions are needed. (This is not usually needed for module development, but can be nice for large changes).

Note that we do keep Ansible to a particular aesthetic, so if you are unclear about whether a feature
is a good fit or not, having the discussion on the development list is often a lot easier than having
to modify a pull request later.

When submitting patches, be sure to run the unit tests first “make tests” and always use, these are the same basic
tests that will automatically run on Travis when creating the PR. There are more in depth tests in the tests/integration
directory, classified as destructive and non_destructive, run these if they pertain to your modification. They are setup
with tags so you can run subsets, some of the tests requrie cloud credentials and will only run if they are provided.
When adding new features of fixing bugs it would be nice to add new tests to avoid regressions.

Use  “git rebase” vs “git merge” (aliasing git pull to git pull --rebase is a great idea) to avoid merge commits in
your submissions.  There are also integration tests that can be run in the "test/integration" directory.

In order to keep the history clean and better audit incoming code, we will require resubmission of pull requests that
contain merge commits.  Use "git pull --rebase" vs "git pull" and "git rebase" vs "git merge". Also be sure to use topic
branches to keep your additions on different branches, such that they won't pick up stray commits later.

If you make a mistake you do not need to close your PR, create a clean branch locally and then push to github
with --force to overwrite the existing branch (permissible in this case as no one else should be using that
branch as reference). Code comments won't be lost, they just won't be attached to the existing branch.

We’ll then review your contributions and engage with you about questions and  so on.

As we have a very large and active community, so it may take awhile to get your contributions
in!  See the notes about priorities in a later section for understanding our work queue.
Be patient, your request might not get merged right away, we also try to keep the devel branch more
or less usable so we like to examine Pull requests carefully, which takes time.

Patches should always be made against the 'devel' branch.

Keep in mind that small and focused requests are easier to examine and accept, having example cases
also help us understand the utility of a bug fix or a new feature.

Contributions can be for new features like modules, or to fix bugs you or others have found. If you
are interested in writing new modules to be included in the core Ansible distribution, please refer
to the `module development documentation <http://docs.ansible.com/developing_modules.html>`_.

Ansible's aesthetic encourages simple, readable code and consistent, conservatively extending,
backwards-compatible improvements.  Code developed for Ansible needs to support Python 2.6+,
while code in modules must run under Python 2.4 or higher.  Please also use a 4-space indent
and no tabs, we do not enforce 80 column lines, we are fine with 120-140. We do not take 'style only'
requests unless the code is nearly unreadable, we are "PEP8ish", but not strictly compliant.

You can also contribute by testing and revising other requests, specially if it is one you are interested
in using. Please keep your comments clear and to the point, courteous and constructive, tickets are not a
good place to start discussions (ansible-devel and IRC exist for this).

Tip: To easily run from a checkout, source "./hacking/env-setup" and that's it -- no install
required.  You're now live!

其它主题
============

Ansible Staff
Ansible 职员
-------------

Ansible, Inc is a company supporting Ansible and building additional solutions based on
Ansible.  We also do services and support for those that are interested. We also offer an
enterprise web front end to Ansible (see Tower below).

Our most important task however is enabling all the great things that happen in the Ansible
community, including organizing software releases of Ansible.  For more information about
any of these things, contact info@ansible.com

On IRC, you can find us as jimi_c, abadger1999, Tybstar, bcoca, and others.   On the mailing list,
we post with an @ansible.com address.

邮件列表信息
------------------------

Ansible有一些邮件列表，因为审核的原因，你的第一次投递邮件可能时间稍长，请允许一天时间的延迟。

`Ansible Project List <https://groups.google.com/forum/#!forum/ansible-project>`_ 分享 Ansible的技巧，问题解答，用户讨论。

`Ansible Development List <https://groups.google.com/forum/#!forum/ansible-devel>`_ 学习如何在Ansible上开发，询问ansible未来的设计特性，讨论扩展ansible或者正在进行的ansible特性。

`Ansible Announce list <https://groups.google.com/forum/#!forum/ansible-announce>`_关于ansible版本号的只读共享信息，小频率的ansible事件信息。例如：通知AnsibleFest的出现。

`Ansible Lockdown List <https://groups.google.com/forum/#!forum/ansible-lockdown>`_ 关于ansible lockdown项目的所有信息，包括DISA STIG 自动化和 CIS Benchmarks

对于非google账户订阅一个组，你可以发送邮件到这订阅地址请求订阅，例如：ansible-devel+subscribe@googlegroups.com

版本号
-----------------

以 ".0" 结尾的版本是朱版本，同时将会有很多新的特性。以其他整数结尾的 ，像"0.X.1" 和 "0.X.2"是小版本，这些仅仅包含 bug 修复

通常来说，我们不会发布小版本号(保存用于大的项目)，但是如果现在具体下次发布会有很长时间的话，偶尔可能决定去除包含大量修复的小版本。

版本号基于没有其他人使用 Van Halen 的歌曲命名。

Tower 支持问题
-----------------------

Ansible `Tower <http://ansible.com/tower>` 是一个对 ansible 提供的用户接口，服务，应用程序接口等等。

如果你有关于 tower的问题，发送邮件到 `support@ansible.com <mailto:support@ansible.com>` 而不是在IRC频道上，或者一般邮件列表上提问

IRC 频道
-----------

Ansible 有IRC 频道 #ansible on irc.freenode.net.

Notes on Priority Flags
注意优先级的标识
-----------------------

Ansible was one of the top 5 projects with the most OSS contributors on GitHub in 2013, and has over 800 contributors
to the project to date, not to mention a very large user community that has downloaded the application well over a million
times.

As a result, we have a LOT of incoming activity to process.

In the interest of transparency, we're telling you how we sort incoming requests.

In our bug tracker you'll notice some labels - P1, P2, P3, P4, and P5.  These are our internal
priority orders that we use to sort tickets.

With some exceptions for easy merges (like documentation typos for instance),
we're going to spend most of our time working on P1 and P2 items first, including pull requests.
These usually relate to important bugs or features affecting large segments of the userbase.  So if you see something categorized
"P3 or P4", and it's not appearing to get a lot of immediate attention, this is why.

These labels don't really have definition - they are a simple ordering.  However something
affecting a major module (yum, apt, etc) is likely to be prioritized higher than a module
affecting a smaller number of users.

Since we place a strong emphasis on testing and code review, it may take a few months for a minor feature to get merged.

Don't worry though -- we'll also take periodic sweeps through the lower priority queues and give
them some attention as well, particularly in the area of new module changes.  So it doesn't necessarily
mean that we'll be exhausting all of the higher-priority queues before getting to your ticket.

Every bit of effort helps - if you're wishing to expedite the inclusion of a P3 feature pull request for instance, the best thing you can do
is help close P2 bug reports.

社区代码和产品
-------------------------

社区欢迎所有类型的用户，什么背景，什么技术级别都可以。请尊敬其他人就像你想让其他人尊敬你一样，保持讨论的活跃氛围，不要产生冲突，避免各种歧视，亵渎，避免无用的争论(例如:vi和emace那个更好一样。)

在社区事件上面也是希望大家好好相处

邮件列表应该集中在IT自动化上面。滥用社区的指南将不会被容忍，后果是禁用社区资源

贡献执照许可
------------------------------

通过贡献，你被授予一个完整的，不可吊销的版权执照，依据这个项目的执照，这个执照对这个项目的所有用户和开发者都有效。
