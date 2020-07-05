---
title: git配置与使用教程
date: 2019-05-04 22:23:02
tags: [git]
category: git
---

## 1. git配置
放在~/.gitconfig文件中
```ini
[user]
  name = victor.dong
  email = dxs_uestc@163.com
[color]
  ui = auto
[alias]
  st = status
  co = checkout
  ci = commit
  br = branch
  df = diff
  dfn = diff --name-only
  dfs = diff --staged
  dft = difftool
  dfts = difftool --staged
  mr = merge
  mrt = mergetool
  last = log -1 HEAD
  amend = commit -C HEAD -a --amend
  lg = log --color --graph --pretty=format:'%C(yellow)%h%C(reset) - %C()%cd%C(reset) %C()<%an>%C(reset)%C(red)%d%C(reset) %C(ul)%s%C(reset)' --abbrev-commit --date=format:'%y/%m/%d %H:%M:%S'
  ls = log --name-only --color --graph --pretty=format:'%C(yellow)%h%C(reset) - %C()%cd%C(reset) %C()<%an>%C(reset)%C(red)%d%C(reset) %C(ul)%s%C(reset)' --abbrev-commit --date=format:'%y/%m/%d %H:%M:%S'

#not show log in new page
[core]
	pager =

#diff tool use beyond compare
[diff]
  tool = bcomp
[difftool "bcomp"]
  cmd = \"/usr/bin/bcompare\" \"$LOCAL\" \"$REMOTE\"
[difftool]
  prompt = false

#merge tool use beyond compare
[merge]
  tool = bcomp
[mergetool "bcomp"]
  cmd = \"/usr/bin/bcompare\" \"$LOCAL\" \"$REMOTE\" \"$BASE\" \"$MERGED\"
[mergetool]
  prompt = false
```

<!-- more -->
