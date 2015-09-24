Amazon Web Services Guide
=========================

.. _aws_intro:

简介
````````````

Ansible包含了大量的控制Amazon web service(AWS)模块.这个章节的目的是为了说明如何在AWS环境下组合ansible的模块使用ansible(The purpose of this
section is to explain how to put Ansible modules together (and use inventory scripts) to use Ansible in AWS context)
 
AWS模块的需求(requiement)是很少的

所有需要的模块以及被最近的 boto 版本测试过了.你需要这个模块安装在你的控制机器上面.boto 可以从linux发行版或者使用python的pip安装

然而典型的ansible执行任务,对多个主机进行循环(Whereas classically ansible will execute tasks in its host loop against multiple remote machines),大部分的云控制步骤发生在你的本地机器所关联的区域

在你的 playbook 步骤里,我们会使用下面的样式演示步骤::

    - hosts: localhost
      connection: local
      gather_facts: False
      tasks:
        - ...

.. _aws_authentication:

认证
``````````````
AWS 认证相关的模块通过指定访问密钥作为 ENV 的变量或者模块参数.

对于环境变量::

    export AWS_ACCESS_KEY_ID='AK123'
    export AWS_SECRET_ACCESS_KEY='abc123'

存储变量在一个 vars_file ,最好使用ansible-vault::

    ---
    ec2_access_key: "--REMOVED--"
    ec2_secret_key: "--REMOVED--"

.. _aws_provisioning:

供给(Provisioning)
````````````````````````

在EC2中提供和取消实例的ec2模块

一个确保只有5个实例标签为“Demo”的例子

在下面的例子里,"exact_count"实例被设置为了5,这意味着如果0个实例存在,将会创建5个.如果两个实例创建,将会创建三个,如果8个实例存在,将会终止3个.

指定"count_tag"参数的将被计数, "instance_tags" 参数用于给新创建的实例应用标签::

    # demo_setup.yml

    - hosts: localhost
      connection: local
      gather_facts: False

      tasks:

        - name: Provision a set of instances
          ec2: 
             key_name: my_key
             group: test
             instance_type: t2.micro
             image: "{{ ami_id }}"
             wait: true 
             exact_count: 5
             count_tag:
                Name: Demo
             instance_tags:
                Name: Demo
          register: ec2

有关实例被常见的数据被保存在通过 "register" 关键字设置的"ec2"变量

我们将会使用 add_host 模块动态的创建主机组组成新的实例.这将会在后来的任务里面立即执行这些配置文件::

    # demo_setup.yml

    - hosts: localhost
      connection: local
      gather_facts: False

      tasks:

        - name: Provision a set of instances
          ec2: 
             key_name: my_key
             group: test
             instance_type: t2.micro
             image: "{{ ami_id }}"
             wait: true 
             exact_count: 5
             count_tag:
                Name: Demo
             instance_tags:
                Name: Demo
          register: ec2
    
       - name: Add all instance public IPs to host group
         add_host: hostname={{ item.public_ip }} groups=ec2hosts
         with_items: ec2.instances

在主机组添加之后,规则剧本底部的第二个演出将会开始一些配置步骤::

    # demo_setup.yml

    - name: Provision a set of instances
      hosts: localhost
      # ... AS ABOVE ...

    - hosts: ec2hosts
      name: configuration play
      user: ec2-user
      gather_facts: true

      tasks:

         - name: Check NTP service
           service: name=ntpd state=started

.. _aws_host_inventory:

主机清单
``````````````

一旦你的节点开始运转起来了,你可能想去和它们通信.在云的配置下,最好不要维护静态的云主机名.最好的方式是使用ec2动态清单脚本来处理.

这将会动态的挑选节点甚至不是由Ansible创建的,同样允许Ansible管理它们.

阅读  doc:`aws_example` 查看如何使用,然后继续回到这个章节.

.. _aws_tags_and_groups:

标签,组和变量
`````````````````````````````

当使用ec2清单脚本的时候,主机基于它们如何在EC2里面的标签动态的出现在组里面

例如,如果一个主机给了 "class" 标签,同时给它"webserver"作为值,它会自动被动态组发现,就像这样::

   - hosts: tag_class_webserver
     tasks:
       - ping

这是很好的根据他们的性能划分系统的方式.

在这个例子里,如果我们想去定义自动应用每台机器上面的变量,同时 "webserver" 带有标签 "class" , 在ansible里面可以使用的"group_vars", 阅读:ref:`splitting_out_vars`.

对于区域和其它分类,相似的组是可用的,可以使用同一种机制分配相似的变量.(Similar groups are available for regions and other classifications, and can be similarly assigned variables using the same mechanism.)

.. _aws_pull:

使用Ansible Pull自动伸缩
`````````````````````````````

Amazon有基于负载自动的增加和减少容量的特性. 在 cloud 文档里,也有一些 Ansible 模块可以配置自动伸缩策略.

  
当节点在线的时候,可能没有足够的时间等待下一个周期来临,让ansible命令配置那个节点.

为了这么做,(To do this, pre-bake machine images which contain the necessary ansible-pull invocation.).Ansible-pull 是从git服务器上面抓取playbook在本地运行的一个命令行工具.

这种方式的一个挑战在于在自动伸缩的环境里面需要一个中心化的方式存取 pull 命令的数据.因为这个原因,下面提供自动伸缩解决方案更好一些.

阅读 :ref:`ansible-pull` 在pull-node playbook 获取更多的信息

.. _aws_autoscale:

使用Asnible Tower自动伸缩
``````````````````````````````

:doc:`tower` 同样包含了一个非常好的特性来自动伸缩.在这种方式下,简单的curl脚本可以调用定义的URL,服务器也会对请求"dial out"和配置正在运行的实例.这是一个很好的方式重新配置生存周期短暂的节点.阅读Tower安装和产品文档获取更多的信息.

在Tower使用回收机制有个好处是,任务结果仍然是中心化的,但是和远程主机分享更少的信息(A benefit of using the callback in Tower over pull mode is that job results are still centrally recorded and less information has to be shared
with remote hosts.)

.. _aws_cloudformation_example:

Ansible云构造
````````````````````````````````````````

云构造是一个Amazon的技术,让云栈作为JSON文档

Ansible摸块提供了一个比云构造更容易的接口,不需要定义复杂的JSON文档.这是推荐用户使用的.

然而,当用户决定使用云构造,也有 Ansible 模块可以应用于云构造模板.

当使用Ansible配合云构造的时候,Ansible通常使用一个工具像 Packer 来构建镜像,CloudFormation 运行这些镜像, 或者通过用户数据,一旦镜像上线,ansible会被激发.(When using Ansible with CloudFormation, typically Ansible will be used with a tool like Packer to build images, and CloudFormation will launch
those images, or ansible will be invoked through user data once the image comes online, or a combination of the two.)

请阅读ansible云构造的例子获取更多的细节.

.. _aws_image_build:

使用Ansible 构造AWS镜像
```````````````````````````````

Many users may want to have images boot to a more complete configuration rather than configuring them entirely after instantiation.  To do this,
one of many programs can be used with Ansible playbooks to define and upload a base image, which will then get its own AMI ID for usage with
the ec2 module or other Ansible AWS modules such as ec2_asg or the cloudformation module.   Possible tools include Packer, aminator, and Ansible's
ec2_ami module.  

许多用户想去开机启动更完整的配置而不是安装之后配置.为了这样做,许多程序可以用于ansible playbook定义和上传基本的镜像,这让他们使用 ec2 模块后得到自己的AMI ID,或者其它的Ansible AWS模块例如ec2_asg 或者cloudformation 模块.可能的工具包含 Packer,aminator,和Ansible's ec2_ami 模块

总的来说,我们发现许多用户使用Packer

Ansible Packer的文档可以在这里找到 `<https://www.packer.io/docs/provisioners/ansible-local.html>`_.

如果你想采用Packer这时,配置一个基本的镜像使用Ansible在规则之后是可以接受的.

.. _aws_next_steps:

下一步:探索模块
```````````````````````````

Ansible附带许多模块来配置许多EC2服务.浏览 模块的 "Cloud" 目录查看完整的列表

.. seealso::

   :doc:`modules`
       All the documentation for Ansible modules
   :doc:`playbooks`
       An introduction to playbooks
   :doc:`playbooks_delegation`
       Delegation, useful for working with loud balancers, clouds, and locally executed steps.
   `User Mailing List <http://groups.google.com/group/ansible-devel>`_
       Have a question?  Stop by the google group!
   `irc.freenode.net <http://irc.freenode.net>`_
       #ansible IRC chat channel


