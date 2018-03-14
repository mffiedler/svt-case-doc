# OSE build

## Does my current pkg contain the fix of the bz?

For example, we have [bz 1537236](https://bugzilla.redhat.com/show_bug.cgi?id=1537236)
where the fix is [origin/pull/18544](https://github.com/openshift/origin/pull/18544).

I am using this pkg:

```sh
# yum list installed | grep openshift
atomic-openshift.x86_64         3.9.7-1.git.0.e1a30c3.el7
```

How can we know whether or not the fix/pr is included in the pkg?

From the above pr UI, we know its commit is `15c1c88b6bef9a437fed960822f203f0620b9074`.

```sh
# go get github.com/openshift/ose
# cd ~/go/src/github.com/openshift/ose/

# git tag --contains 15c1c88b6bef9a437fed960822f203f0620b9074
...
v3.9.7-1
...

# git rev-list -n 1  v3.9.7-1
e1a30c3f321a9c6809f53bd4467d6442e92522c4
```

_So in this particular case, the answer is YES (the pkg contains the pr/fix)._

Understand the version name of the pkg: 3.9.7-1.git.0.e1a30c3.el7

* 3.9.7-1: git tag
* git: constant?
* 0: #build?
* e1a30c3: git commit (first 7 digits)
* el7: os version?

? above means I am not sure.
