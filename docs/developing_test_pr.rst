帮助测试PR
```````````````````

作为一名开发者，最具能展现自我价值的事情就是在github上看讨论列表来帮助修复bug。我们通常在解决了bug之后再进行新功能的开发，因此解决bug将是一个非常有价值的事情。

即使你不是一个开发者，帮助测试bug的修复情况以及新功能还是非常有必要的。

这同样适用于测试新功能以及测试错误修正。

通常情况下，编码工作应当包含测试用例来保证编码的正确性，但这并不总能照顾到代码的方方面面，尤其在各平台下测试用户没有足够的访问权限，或者使用的是API或者web服务。

在这种情况下，在真实的环境下上线测试将会比自动测试更有价值。在任何情况下，都是应该进行一次人工测试。

幸运的是在你充分了解ansible的工作机制的情况下，帮助测试ansible是一件非常简单的事情。

开始测试
++++++++++++++++++++++++++++++++++

你可以在ansible主分支上切出一个分支来保持和主分支隔离，合并GitHub上的问题，测试，然后在GitHub对这一特定问题做一个回馈。具体方法如下：

.. note::
   帮助测试GitHub上那些提交合并请求的代码是否存在风险，这些风险可能包括存在错误或恶意代码。我们建议在虚拟机上测试，无论是云，或在本地。有些人喜欢Vagrant，或Docker，这是可以的，但我们并不推荐。 在不同的Linux系统环境下进行测试也是非常有意义的，因为某些功能（诸如APT和yum等包管理工具）专用于这些操作系统。

当然配置您的测试环境来运行我们的测试套件需要一系列工具。以下软件是必须的::

   git
   python-nosetests (sometimes named python-nose)
   python-passlib
   python-mock

如果你想运行完整的集成测试套件，你还需要安装以下软件包::

   svn
   hg
   python-pip
   gem 

当准备完以上环境后，您可以从github上拉取Ansible的原代码进行测试了::

   git clone https://github.com/ansible/ansible.git --recursive
   cd ansible/

.. note::
   如果您已经Fork了我们的代码，您就可以从你自己代码仓库里克隆了。

.. note::
   如果你打算更新你的仓库作为测试一些相关模块，请使用"git rebase origin/devel"，并且使用"git submodule update"更新子模块，如不更新，您将使用旧版本的模块。

使用开发环境
++++++++++++++++++++++++++++++

Ansible源代码包括一个脚本，可以让你直接使用Ansible从源代码，而无需完全安装，这对于的Ansible开发者来说十分便利。

使用以下命令进入开发环境，这主要针对的是Linux/Unix的终端测试环境::

   source ./hacking/env-setup

该脚本修改了PYTHONPATH（以及一些其他的东西），这仅仅对于当次shell 会话有效。

如果你想永久使测试环境生效，你可以将其放入开机启动脚本中（例如，`.bash_profile`）。

找到对应分支并测试
++++++++++++++++++++++++++++++++++++++++++++++++++++++

接下来，手动合并你想测试的提交请求，并且记录下源和仓库的信息。它会是这个样子::

   Someuser wants to merge 1 commit into ansible:devel from someuser:feature_branch_name

.. note::
   请务必将提交合并请求提交到ansible:devel分支，我们不会接受您提交到其他分支。版本的更新将由我们的工作人员手动进行。

用户名和分支名是十分重要的，这将显示在以下命令行中::

   git checkout -b testing_PRXXXX devel
   git pull https://github.com/someuser/ansible.git feature_branch_name

第一行命令表示在devel分支上新建一个新分支名叫testing_PRXXXX，而XXXX是实际合并请求申请的ID号（例如，1234），并切换到该分支下。第二行命令则表示拉取对应用户的对应分支的代码。

.. note::
   If the GitHub user interface shows that the pull request will not merge cleanly, we do not recommend proceeding if you
   are not somewhat familiar with git and coding, as you will have to resolve a merge conflict.  This is the responsibility of
   the original pull request contributor.

.. note::
   Some users do not create feature branches, which can cause problems when they have multiple, un-related commits in
   their version of `devel`. If the source looks like `someuser:devel`, make sure there is only one commit listed on
   the pull request.

For Those About To Test, We Salute You
++++++++++++++++++++++++++++++++++++++

At this point, you should be ready to begin testing!

If the PR is a bug-fix pull request, the first things to do are to run the suite of unit and integration tests, to ensure
the pull request does not break current functionality::

   # Unit Tests
   make tests

   # Integration Tests
   cd test/integration
   make

.. note::
   Ansible does provide integration tests for cloud-based modules as well, however we do not recommend using them for some users
   due to the associated costs from the cloud providers.  As such, typically it's better to run specific parts of the integration battery
   and skip these tests.

Integration tests aren't the end all beat all - in many cases what is fixed might not *HAVE* a test, so determining if it works means
checking the functionality of the system and making sure it does what it said it would do.

Pull requests for bug-fixes should reference the bug issue number they are fixing. 

We encourage users to provide playbook examples for bugs that show how to reproduce the error, and these playbooks should be used to verify the bugfix does resolve
the issue if available.  You may wish to also do your own review to poke the corners of the change.

Since some reproducers can be quite involved, you might wish to create a testing directory with the issue # as a sub-
directory to keep things organized::

   mkdir -p testing/XXXX # where XXXX is again the issue # for the original issue or PR
   cd testing/XXXX
   <create files or git clone example playbook repo>

While it should go without saying, be sure to read any playbooks before you run them.  VMs help with running untrusted content greatly,
though a playbook could still do something to your computing resources that you'd rather not like.

Once the files are in place, you can run the provided playbook (if there is one) to test the functionality::

   ansible-playbook -vvv playbook_name.yml

If there's not a playbook, you may have to copy and paste playbook snippets or run a ad-hoc command that was pasted in.

Our issue template also included sections for "Expected Output" and "Actual Output", which should be used to gauge the output
from the provided examples.

If the pull request resolves the issue, please leave a comment on the pull request, showing the following information:

    * "Works for me!"
    * The output from `ansible --version`.

In some cases, you may wish to share playbook output from the test run as well.  

Example!::

   Works for me!  Tested on `Ansible 1.7.1`.  I verified this on CentOS 6.5 and also Ubuntu 14.04.

If the PR does not resolve the issue, or if you see any failures from the unit/integration tests, just include that output instead::

   This doesn't work for me.

   When I ran this my toaster started making loud noises!

   Output from the toaster looked like this:

      ```
      BLARG
      StrackTrace
      RRRARRGGG
      ```

When you are done testing a feature branch, you can remove it with the following command::

   git branch -D someuser-feature_branch_name

We understand some users may be inexperienced with git, or other aspects of the above procedure, so feel free to stop by ansible-devel
list for questions and we'd be happy to help answer them.  



