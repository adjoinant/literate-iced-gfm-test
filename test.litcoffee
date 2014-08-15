# Testing out Literate Coffeescript

Here is an introductory paragraph to explain somthing or other.

It might contain information such as a list of things:

+ item 1
+ item 2
+ item 3
  + sub-item 1
  + sub-item 2
  
## Now to get on with something

Finally, let's write some code

    doSomething = (x) ->
      a = somethingElse x
      b = somethingElse 10
      c = 1
      for i in [1..10]
        c = somthingElse i
      
      a + b + c
