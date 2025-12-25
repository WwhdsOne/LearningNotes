### Git统计所有提交的代码增删总量(含所有分支)

```bash
git log --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "新增代码行数: %s\n删除代码行数: %s\n净增代码行数: %s\n", add, subs, loc }'
```

