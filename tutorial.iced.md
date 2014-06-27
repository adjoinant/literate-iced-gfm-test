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