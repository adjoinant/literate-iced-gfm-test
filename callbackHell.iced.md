    Routing = 
=============

# Here is some example code taken from the node-mong0db-native package - a MongoDb driver for Node.
# It is here just as an example of callback horror:

# ```javascript

# var p_client = new Db('integration_test_20', 
#   new Server('127.0.0.1', 27017, {}), 
#   { 'pk': CustomPKFactory });

# p_client.open(function(err,p_client) {
#   p_client.dropDatabase(function(err,done) {
#     p_client.createCollection('test_custom_key',function(err,collection) {
#       collection.insert({'a': 1}, function(err,docs) {
#         collection.find({'_id': new ObjectID("aaaaaaaaa")}, function(err,cursor) {
#           cursor.toArray(function(err,items) {
#             test.assertEquals(1,items.length);   
#             p_client.close();  
#           });
#         });
#       });  
#     });
#   });  
# });

# ```

# This is obviously not a great looking bit of code. Lets start by coffee-ifying it:

# ```coffee

# p_client = new Db('integration_test_20', 
#   new Server('127.0.0.1', 27017, {}), 
#   { 'pk': CustomPKFactory })

# p_client.open (err,p_client) ->
#   p_client.dropDatabase (err,done) ->
#     p_client.createCollection 'test_custom_key', (err,collection) ->
#       collection.insert {'a': 1}, (err,docs) ->
#         collection.find {'_id': new ObjectID("aaaaaaaaa")}, (err,cursor) ->
#           cursor.toArray (err,items) ->
#             test.assertEquals 1, items.length
            
#             p_client.close()
# ```

# So the syntax has been cleaned a little, but it is still not great - there is that huge walk to
# the right of the page occurring. Let's introduce some iced...

# ```coffee
        
# p_client = new Db('integration_test_20', 
#   new Server('127.0.0.1', 27017, {}), 
#   { 'pk': CustomPKFactory })

# await p_client.open defer(err,p_client)
# await p_client.dropDatabase defer (err,done)
# await p_client.createCollection 'test_custom_key', defer(err,collection)
# await collection.insert {'a': 1}, defer (err,docs)
# await collection.find {'_id': new ObjectID("aaaaaaaaa")}, defer(err,cursor)
# await cursor.toArray defer(err,items)
# test.assertEquals 1, items.length
# p_client.close()
# ```

Now let's grow our own, working example of the above:

```coffee

    server1 = (word,cb) ->
      await setTimeout defer(), 4000 * Math.random()
      err = if word is 'everything' then 'no-one knows the answer to everything!' else null
      cb err,42

    server2 = (word,autocb) ->
      await setTimeout defer(), 300
      return 'The answer to ' + word + ' is 24'

    doCall1 = (word,cb) ->
      console.log 'server1 called with ' + word
      await server1 word, defer err, answer1
      if err 
        console.log "server1 responded with err: " + err
      else 
        console.log "server1 responded with 'answer to " + word + ' is: ' + answer1 + "'"
      cb err,answer1

    doCall2 = (word, answer, autocb) ->
      console.log 'server2 called with ' + word
      await server2 answer, defer answer2
      console.log "server2 responded with '" + answer2 + "'" + " to call with " + word

    doPair = (word,autocb) ->
      await doCall1 word, defer err, answer1
      if err
        console.log 'calls finished unhappily for ' + word
        return err
      await doCall2 word, answer1, defer()
      console.log 'calls finished happily for ' + word

    doAll = (ws) ->
      await 
        for w in ws
          doPair w, defer()
        console.log 'loop finished.'
      console.log 'all calls completed'

    doAll [ 'life', 'universe', 'everything' ]
    
    console.log 'all calls made.'
```   


