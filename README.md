# Playing around with `async` Ruby

Based on https://brunosutic.com/blog/async-ruby

## Prerequisites:

* `rvm install 3.0.1`
* `rvm use 3.0.1`
* `bundle`
* bump max number of open file descriptors: ulimit -n 1000
* `brew install postgresql redis` (optional)
* set postgresql max_connections to 1000 (optional)

## Running

```
ruby async.rb [db_user, db_name]
```

