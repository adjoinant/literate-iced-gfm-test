
suppose that we have a (fake) oracle to which we can send out questions across the web:
    
```coffee-script

    oracle = (keyword, cb) -> 
      leng = Math.random(5)
      func = -> cb 
        results: ["the answer to " + keyword + " is more beer."]
        oracle_name: "Hypatia"
      setTimeout func, leng*1000
```
Then we can write a simple wrapper around that oracle to make it easy to get the answer to 
something. This is not doing anything fancy at this point.
    
```coffee-script

    search = (keyword,cb) ->
      twit = oracle
      await twit keyword, defer response
      cb response.results
```
Note we introduced the new iced-coffee-script keywords that are additions to basic coffee-script. 
The await, defer construct sets up a block which will not return until all defers within the await 
have completed. Thus we can create a parallel search as follows:
    
```coffee-script

    parallelSearch = (keywords,cb) ->
      out = []
      await
        for k,i in keywords
          search k, defer out[i]
      cb out
```
But look how easy it is to turn this in to a serial block instead, firing off only a single query 
at a time:
    
```coffee-script

    serialSearch = (keywords,cb) ->
      out = []
      for k,i in keywords
        await search k, defer out[i]
      cb out
```
Now to demonstrate what we have created, here is a simple set of questions to submit to the oracle.
We just print out the answers when they come back...
    
```coffee-script

    params = ["life","sadness","tiredness","work"]
    parallelSearch params, (answer) -> 
      console.log answer

    console.log "parallel query sent about " + params

    params = ["time","death","winter","work"]
    serialSearch params, (answer) -> 
      console.log answer

    console.log "serial query sent about " + params

```