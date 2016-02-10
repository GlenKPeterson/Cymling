# Rippl
Robust, Immutable, Powerful, Programming Language

# Rippl Programming Language
*INCOMPLETE*

RIPPL stands for Robust, Immutable, Powerful, Programming Language.  You can tell that to your non-programmer boss while you envision concentric waves on an otherwise still pond.  I hope to have a Rippl REPL soon (your non-programmer boss doesn't need to know that).

##Design Goals
 - Immutability is the default
 - Applicative Order by default (eager)
 - Static Type checking with inference everywhere except function parameters and return types.
 - Regular (lisp-like) syntax with very few infix operators
 - No primitives.  Built-in and user-defined data behave the same.
 - Interfaces over objects.
 - Evaluative (everything is an expression – no return statements)
 - Built-in data types: Record (hetero-list): `(a b c)`, Map: `{ a=b c=d e=f }`, Vector (homo-list): `[a b c]`, Set: `#{a b c}` - like Clojure except the fundamental unit is a Record instead of a linked list.

##Syntax
The syntax is a combination of Clojure (Lisp), ML, and Java.

###Comments
Single-line comments are preceded by a semicolon.  Multi-line comments start with 3 or more semicolons and end with the same:

```
; single line comment
;; A more-visible single-line comment

;*
Multi-line comment
Still in a multi-line comment...
Comment ends here: *;

;**
Multi-line RipplDoc comment
*;
```

###Commas
Commas are whitespace (like Clojure).  Add them when it helps you, but the compiler treats them as spaces.

###Functions vs. Record literals
Lisp puts the the function name to the right of the parenthesis, which causes plain lists to require quoting:
```
(func arg1 arg2)
'(“Marge” 37 16.24)
```

Instead, Rippl will put the function to the left and literal records (not lists) will not require quotes:
```
func(arg1 arg2)    ; function application
(“Marge” 37 16.24) ; record/tuple
```

##Operators
Infix operators allow very Natural-Language friendly syntax, but can quickly lead to confusion with precedence, overriding, and other nightmares.  So there will only be three in this language.  One is the dot operator as described above.  The other two are the Colon (to introduce a type) and the Equals Sign (to associate keys with values).  The precedence is dot first, equals second.  Colons introduce types which are evaluated at compile time, not runtime.

###Dot Operator
Instead of the usual Lisp convention of reading code inside out:
```
(third (second (first arg1) arg2) arg3)
```
We borrow the “dot operator” from C-style languages to enable a “Fluent Interface” type style:
```
first(arg1).second(arg2)
           .third(arg3)
           
```

##Records
Data definition and function application are borrowed primarily from ML's records.  Thus a data definition looks like this:
```
defType(Person
        { name:String
          age:Int
          height:Float })
```

Or maybe with the over-all type name at the end?:
```
{ name:String
  age:Int
  height:Float }:Person
```

An instance of that definition using names:
```
Person{ name=“Marge” age=37 height=16.24 }
```

The same using indices instead of names:
```
Person(“Marge” 37 16.24)
```

Both of the above examples compile to something like Java objects of an appropriate type with getter methods (but no setter methods):
```
name():String
age():Int
height():Float

;; Record definition with some defaults and inferred types (name:String and Height:Float)
;; Note that position matters (all Person's will be defined in the order: name, age, height).
defType(Person {name=“Marge” age:Int height=16.24})

;; Instantiation:
let( { marge=Person{age=37}
       fred=Person{name="Fred" age=35}
       sally=Person("Sally" 15 12.2)} ;; Defined using record syntax instead of map syntax (like ML)

     marge.height() ;; returns 16.24:Float
     fred.age()) ;; returns 35:Int which is also the return for the entire let block.
```

##Interfaces
Interfaces (not objects) can extend the functionality of records in a pseudo-Object-Oriented way.  When creating data that you intend to treat as implementing an interface, simply attach the name of the interface to the data to give it a type when you construct it:
TODO: Pick one:
A.
```
Person{name=“Marge” age=37 height=16.24}
```
B.
```
{name=“Marge” age=37 height=16.24}:Person
```

##Lambdas
Anonymous functions are defined with their arguments followed by the statements to be executed when they are called.  The defn() built-in functions are used to create them.
```
defn({} "" print(“hello!”))
defn({name:String}
   print(“Hello ” name “,”)
   print(“Pleased to meet you!”)
   Nil)
```
Or:
```
print(defn({name:String}
         cat(“Hello ” name “,\n” “Pleased to meet you!”))
      .apply(“Glen”))
```

##Other Operators
All other (non-infix) operators have syntax like other functions.  Because they are functions, they can be lazily evaluated:

```
if(a                 ;; test clause
   then(print(“a”))        ;; lazily-evaluated then clause
   else(println(“not a”))) ;; lazily-evaluated else clause
```
TODO: How does elseif work?
```
if(a                 ;; test clause
   then(print(“a”))        ;; lazily-evaluated then clause
   elsif(b then(print(“b”)))
   elsif(c then(print(“c”)))
   else(println(“not a, b, or c”))) ;; lazily-evaluated else clause
```

TODO: Cond has a variable number of conditions.  Do we handle that with multiple “overridden” function definitions?  Or do we implement varargs?  Or do we have a built-in list data type (an array or linked list) to use in these cases?
```
cond(eq(a "Sq") concat("product: " times(a a))
     eq(a "Pl") concat("sum: " plus(a a))
     t() fn({} a))
```

That example is deceptively simple.  The signature of cond could be overloaded (though in Java this makes IDE's slow - I don't know about runtime speed):
```
cond(if:Fn0<Bool> then:Fn0<T>):T
cond(if:Fn0<Bool> then:Fn0<T>
     if2:Fn0<Bool> then2:Fn0<T>):T
cond(if:Fn0<Bool> then:Fn0<T>
     if2:Fn0<Bool> then2:Fn0<T>
     if3:Fn0<Bool> then3:Fn0<T>):T
...
```

Or cond could be a vargarg method where each argument is a record (pair) of zero-argument functions.  Treating functions as first class (like Clojure) builds delayed evaluation right in.  
```
cond[(if:Fn0<Bool> then:Fn0<T>)]:T
```

That would yield many more parens:
```
cond[(eq(a "Sq") concat("product: " times(a a)))
     (eq(a "Pl") concat("sum: " plus(a a)))
     (t() fn({} a))]
```

Hmmm... Not sure about that.  Do we need to make passing functions explicit somehow like the "pass-by-reference" operator in C?


##Type System

Java Generics, p. 16 by Naftalin/Wadler has an example that shows why mutable collections cannot safely be covariant.  Some day I'll copy it to this document.  In any case, immutable collections *can* be covariant because of their nesting properties.  You can have a `ImList<Int>` and add a `Double` to it and you'll get back either the union type `ImList<Int|Double>` which can then be safely cast to a `ImList<Number>` (`Number` is the most specific common ancestor of both `Int` and `Double`).  If the List were mutable, you'd have to worry about other pointers to the same list still thinking it was a `List<Int>`, but immutable collections solve that problem.

Hmm... That paragraph assumes inheritance.  Maybe you have to declare `defType Number = Int | Double` instead?

Therefore, the type system needs some indication of what's immutable (grows by nesting like Russian Dolls) and what's not (changes in place).  Since imutability is the default, there should be an `@Mutable` or similar annotation required in order to update data in place.  Probably a second annotation `@MutableNotThreadSafe` should be required for people who really want to live dangerously.  Without such annotations, your class/interface cannot do any mutation.

There may come a time when the type system needs to choose between being mathematically sound and being lenient.  I am not committed to soundness in the strict sense.  I require a type system to prevent-known-bad, but that's weaker than most type systems which have an allow-known-good outlook.  My experience with Java is that sooner or later you have to cast somewhere in your API.  That seems just a little too strict for me, but this paragraph exceeds the limits of my competence, so basically, I don't know.

##Defining Types
At least to start, all types must be named – no anonymous instances of types.  Thus to make a person, you need:
```
defType(Person             ; start defining a type called “Person”
        { name:String      ; The expected methods are name():String
          age:Int          ;                          age():Int
          height:Float })  ;                      and height():Float
```

Note: If we want inheritance, second line *could* include:
```
        extends(Nameable)  ; Extends and implements are the same
```

Here is a let block that performs some pretty simple logic on some people (fred is declared, but never used):

```
let( { marge={name=“Marge” age=37 height=16.24}
       fred:Person={name=“Fred” age=39 height=15.5} 
       sarah:Person=(”Sarah” 35 17.0) }
     if(gt(marge.height() sarah.height())
           println(“Marge is taller than Sarah”)
           println(“Marge is not taller than Sarah”)))
```

Pretty soon, we're going to need parameterized types.  This definitely needs more thought...

```
defType(List<T>             ; Define a type called “List” with type param T
        fns(get(i:Long):T = ...
            cons(item:U):List<T|U> = ...
        ))  ;                  
```


Main Method
```
main({args:List<String>}
     print(“Hello “ args.getOrElse(1 “World”) “!”)
     1)
```

Let's look at if() for a moment.  It takes at least a then() or else() function for lazy evaluation

```
defType(Then<T>
        { apply():T })

defType(Else<T>
        { apply():T })

defType(If<T>
        { condition:Bool
          then:Then<T>=Nil
          else:Else<T>=Nil })

defType(ElsIf<T>
        extends(Else<T> If<T>)
        { condition:Bool
          then:Then<T>=Nil
          else:Else<T>=Nil })
```

##Strings
*Wish List:*
I'd love to have Str8 (pronounced “Straight”) to be native support for UTF8, have all serialization use UTF8, and give Str8 a .to16() method to convert to Java style strings.  This would require a bunch of work that I don't want to do up front, but over time I think it would be a big win.  Also, it would be good to rewrite the regular expressions library to use this and use it quickly.  When people use emoji, we don't want to be counting “code points” as opposed to characters the way you have to in Java.  UTF8 seems to be the new world standard...

##Pattern Matching
*Wish List:*
```
match(item
      Person{n:name a:age h:height} println(“Person: ” n)
      Car(license year)             println(“Car: ” license)
      default                       println(“Default”))
```

Note: Enums values may have to be sub-classes of the Enum they belong to for pattern matching to work.

##Types
Any is the progenitor super-type
Nil is a sub-type of most things
Nothing might be a sub-type of Nil indicating that no valid type can be used?

##Union Types
Are available.  String-or-null is:
```
middleName:or(String Nil)
;; or maybe like Ceylon:
middleName:String?
```

Similar syntax could be used to indicate optional parameters.
```
foo({first:String
     middle:default(String “”)
     last:String}
     cat(“Hello “ first middle last))
```

Union types are available:
```
defType(Suit
        or(Clubs Diamonds Hearts Spades))

defEnum(FaceCard
        or(Jack Queen King Ace))

;; Type alias:
defAlias(Num Int)

;; A Rank could be either a face card or a Num (int):
defType(Rank
        or(FaceCard Num))

;; A card is a combination of a suit and a rank:
defType(Card
        suit:Suit
        rank:Rank
        toString=fn({} cat(suit “ “ rank)) ;; a function?
)
```

Function within the current namespace:
```
defFunc(printCard                       ; function name
        {card:Card}                     ; arguments form a record
        print(card.suit “ “ card.rank)) ; body
```

Might be better on card        
```
defType('name=Card
        'data={ suit:Suit rank:Rank }
        printCard=println(cat(card.suit “ “ card.rank)))
```
Here we extend a type:
```
defType('name=CardWithBack
        'extends=Card
        showBack=println(“*****”))
```

A poker chip:
```
defType('name=Color
        'symVals=(Red Green Blue Yellow))

defType('name=Chip
        'data={color:Color value:Int})

defType('name=PlayItem
        'union=(Chip CardWithBack))
```

Now when you use a PlayItem, you have to destructure it:
```
printCard(item:PlayItem) = 
    case(item Chip chip println(cat(“Chip: “ chip.color))
              CardWithBack card println(cat(“Card: “ card.printCard))))
```

##Additional Ideas
From Josh Bloch: https://youtu.be/EduWekviwRg

 - Maybe auto-promote variables from a Record to a Map with Assoc, and let the type-system handle that.
 - Type system must handle nulls (Nil).  Any time you start a function by checking basic attributes of arguments is a missed opportunity for the type system to help you out.
 - Make it easier to write immutable, private code.
 - Friend classes/packages?  So you can share certain internals only with certain other classes/packages?

#License

Copyright 2015 Glen K. Peterson

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
