# Quick Tutorial and Examples

Here is a simple example that print "hello" 10 times, with 100ms delay slots in between:
```coffee

    # A basic serial loop    
    for i in [0..10]
      await setTimeout(defer(), 100)
      console.log "hello"
```

There is one new language addition here, the `await ...` block (or expression), and also one new 
primitive function, `defer`. The two of them work in concert. A function must "wait" at the close 
of a `await` block until all `defer`rals made in that `await` block are fulfilled. The function `defer` 
returns a callback, and a callee in an `await` block can fulfill a deferral by simply calling the 
callback it was given. In the code above, there is only one deferral produced in each iteration 
of the loop, so after it's fulfilled by `setTimer` in 100ms, control continues past the `await` block, 
onto the log line, and back to the next iteration of the loop. The code looks and feels like 
threaded code, but is still in the asynchronous idiom (if you look at the rewritten code output by
the coffee compiler).

This next example does the same, while showcasing power of the `await..` language addition. In the 
example below, the two timers are fired in parallel, and only when both have fulfilled their 
deferrals (after 100ms), does progress continue...
```coffee

    for i in [0..10]
      await 
        setTimeout defer(), 100
        setTimeout defer(), 10
      console.log "hello"
```

Now for something more useful. Here is a parallel DNS resolver that will exit as soon as the last
of your resolutions completes:
```coffee

    dns = require 'dns'
    do_one = (cb, host) -> 
      await dns.resolve host, "A", defer(err,ip)
      msg = if err then "ERROR! #{err}" else "#{host} -> #{ip}"
      console.log msg
      cb()

    do_all = (hs) ->
      await 
        for h in hs 
          do_one defer(), h

    do_all process.argv[2..]
```

You can run this on the command line like so:
```coffee
iced -l tutorial.iced.md yahoo.com google.com nytimes.com tinyurl.com
```

And you will get a response:
```sh
yahoo.com -> 206.190.36.45,98.139.183.24,98.138.253.109
google.com -> 173.194.112.14,173.194.112.3,173.194.112.8,173.194.112.7,173.194.112.1,173.194.112.0,
173.194.112.4,173.194.112.5,173.194.112.6,173.194.112.2,173.194.112.9
```

If you want to run these DNS resolutions in serial (rather than in parallel), then the change 
from the above is trivial: just switch the order of the `await` and `for` statements above:
```coffee
do_all (hs) ->
  for h in hs
    await 
      do_one defer(), h
```

## Composing Serial and Parallel Patterns

In ICS, arbitrary composition of serial and parallel control flows is possible with just normal
functional decomposition. Therefore, we don't allow direct `await` nesting. With inline anonymous
Coffeescript functions, you can concisely achieve interesting patterns. The code below launches
10 parallel computations, each of which must complete two serial actions before finishing:
```coffee
    
    f = (n, cb) ->
      await
        for i in [0..n]
          ((cb) ->
            await setTimeout defer(), 5 * Math.random()
            await setTimeout defer(), 4 * Math.random()
            cb()
          )(defer())
      cb()
```
## autocb

Most of the time, an iced function will call its callback and return at the same time. To get this
behaviour "for free", you can simply name this callback `autocb` and it will fire whenever your iced
function returns. For instance, the above example could be equivalently written as:
```coffee
  
    f = (n, autocb) ->
      await
        for i in [0..n]
          ((autocb) ->
            setTimeout defer(), 5 * Math.random()
            setTimeout defer(), 4 * Math.random()
          )(defer())
```
In the first example, recall, you call cb() explicitly. In this example, because the callback is
named `autocb`, it's fired automatically when the iced function returns.

If you callback needs to fulfill with a value, then you can pass that value via return. Consider
the following function, that waits for a random number of seconds between 0 and 4. After waiting, 
it then fulfills its callback `cb` with the amount of time it waited:
```coffee

    rand_wait = (cb) ->
      time = Math.floor Math.random() * 5
      if time is 0 
        cb(0)
        return 
      await setTimeout defer(), time
      cb(time)
```
This function can be written equivalently with `autocb` as:
```coffee

    rand_wait = (autocb) ->
      time = Math.floor Math.random * 5
      return 0 if time if 0
      await setTimeout defer(), time
      return time
```
Implicitly, `return 0` is mapped by the Coffeescript compiler to `autocb(0); return`.






