# Cymling Programming Language
(Formerly called RIPPL)

*Design Unfinished: Comments Welcome!*

 - Nearly homoiconic (like a lisp, with it's own JSON-like data definition syntax)
 - Functional (first class functions, immutability is assumed/easier/preferred)
 - Type-safe (with type aliases like ML, not Object Oriented)

Cymling is a rarely used word for a pattypan squash.  It's also one of the few short words in the English language that have the letters ML in them ("Cy***ML***ing") which is a nod to the ML programming language.  ML because it showed me that static typing does not need to be Object Oriented.  I could have nodded to Clojure, JSON, and Java too, but ML was the final missing piece for me.

##Design Goals
 - Immutability is the default.
 - Applicative Order by default (eager, not like Haskell)
 - Static Type checking, but in a way that doesn't preclude writing functions first and defining complex data types later.
 - Type inference everywhere except function parameters and return types (the only place type safety is proven to improve comprehension).
 - Regular (lisp-like) syntax with very few infix operators for basic language
 - Traditional algebraic syntax for types
 - Where practical, the language should be homoiconic because this leads to a consistency of concept and syntax that is very appealing (like Lisp).
 - No primitives (int, float, etc.).  Built-in and user-defined data behave the same.
 - Types are related using aliases and set theory (like ML), not necessarily through object hierarchies.
 - Evaluative (everything is an expression – no return statements)
 - Built-in data types like Clojure (or JSON) except the fundamental unit is a Record instead of a linked list.  Default implementations of these can be found in [UncleJim/Paguro](https://github.com/GlenKPeterson/UncleJim) - a Java library that seeks to make the Clojure collections suitable for use in type-safe languages.  Here are the built-in types:
   - Record (tuple / heterogenious map): `(a b c)`
   - Map (homogenous): `{ a=b c=d e=f }`
   - List: `[a b c]`
   - Set: `#{a b c}`
 - Angle brackets are used for parameterized types: `List<String>`

##Syntax
The syntax is a combination of Clojure (Lisp) and ML, with maybe a sprinkling of Java (or not).

###Commas
Commas are whitespace (like Clojure).  Add them when it helps you, but the compiler treats them as spaces.

###Comments

In order to leave the division symbol for division (and as a grateful to nod to Lisp), a semicolon is substituted for the otherwise C-style comment syntax.  Single-line comments are preceded by a semicolon `;`. Multi-line comments start with a semi-star `;*` and end with a star-semi `*;`. Cym-doc comments are multi-line with an extra beginning *:

```
; single line comment
;; A more-visible single-line comment

;*
Multi-line comment
Still in a multi-line comment...
Comment ends here: *;

;**
Multi-line CymlingDoc comment
*;
```

###Functions vs. Record literals
**Lisp** puts the the function name to the right of the parenthesis, which causes plain lists to require quoting:
```
(func arg1 arg2)    ; call/apply funct with arguments arg1 and arg2.
'(“Marge” 37 16.24) ; a literal list of 3 items.
```

**Cymling** puts the function to the left and literal Records (not lists) will not require quoting:
```
func(arg1 arg2)    ; function application
(“Marge” 37 16.24) ; record/tuple of 3 items with types String, Int and Float
```

##Operators
Infix operators allow very Natural-Language friendly syntax, but can quickly lead to confusion with precedence and overriding.  So there will be very few operators in this language, mostly for the type system.

Operators (in precedence order):
 - `.` for function application
 - `=` associates keys with values in records/maps.

Type operators (in precedence order):
 - `<T>` Defines a symbol (in this case, the letter `T` to be used as a parameterized type.
 - `:` Defines a type (TODO: return type, or just plain type?).
 - `|` ("or") for union types, `&` ("and") for intersection types

###Dot Operator
Instead of the usual Lisp convention of reading code inside out:
```
(third (second (first arg1) arg2) arg3)
```
We borrow the “dot operator” from C-style languages to enable a “Fluent Interface” style:
```
first(arg1).second(arg2)
           .third(arg3)
```

##Records
Data definition and function application are borrowed primarily from ML's records.  Thus a data definition looks like this (using the built-in type keyword):
```
type Person = (name:String?
               age:Int = 0
               height:Float?)
```

An instance of that definition is declared using Record syntax.  Parameters can be determined due to order, or optional names may be used for clarity.
```
;; Each line produces a Person instance.
(“Marge” 37 16.24):Person
(name=“Fred” age=23 height=17.89):Person
(“Little Margo” height=3.14):Person ;; Note: This person gets the default age=0.
```

Both of the above examples compile to something like Java objects of type Person (specifically a sub-class of [Tuple3](https://github.com/GlenKPeterson/UncleJim/blob/master/src/main/java/org/organicdesign/fp/tuple/Tuple3.java) with getter methods and a constructor, but no setter methods:
```
name():String
age():Int
height():Float

;; Record definition with some defaults and inferred types (name:String and Height:Float32)
;; Note that position matters (all Person's will be defined in the order: name, age, height).
type Person = (name=“Marge” age:Int height=16.24)

;; Instantiation:
let( (marge=(age=37):Person
      fred=(name="Fred" age=35):Person
      sally=("Sally" 15 12.2):Person);; end declaration part of let block

     marge.height() ;; returns 16.24:Float32
     fred.age()) ;; returns 35:Int which is also the return for the entire let block.
```

##Interfaces
Interfaces (not objects) can extend the functionality of records in a pseudo-Object-Oriented way.  When creating data that you intend to treat as implementing an interface, simply attach the name of the interface to the data to give it a type when you construct it:
TODO: Pick one:
A. (This cannot be used with union or intersection types)
```
Person(name=“Marge” age=37 height=16.24)
```
B. (This will work with union or intersection types)
```
(name=“Marge” age=37 height=16.24):Person
(name=“Marge” age=37 height=16.24):Person|Employee
```

##Functions
Functions are first class.  To name a function, simply assign it to a variable, like any other value.

Anonymous functions are defined with their arguments followed by the statements to be executed when they are called.  `λ<T>(args:Record body:T):T` is a built-in function used to create them.  A zero-arg sugary short-form is available as well without any parens: `λ<T>body:T`.  This uses the Lambda character (commonly used to mean, "anonymous function," which is unicode U+03BB.  To type this on Ubuntu (there is no need to type leading zeros) `CTRL-SHIFT-u` `3` `b` `b` `RETURN`.  We might use `^`, `#`, `&`, or `@` instead of `λ`, but for now we're using what's easiest to read.

```
val myFn = λ“hello!” ;; or, more formally: λ(() "hello!")
;; defined myFn:Fn0<String>

myFn() ;; Apply the function
;; "hello!"

val myFn2 = λ( (name:String)
               "Hello $name$. Pleased to meet you!")
;; defined myFn2:Fn1<String,String>

myFn2("Kelly")
;; "Hello Kelly. Pleased to meet you!"
```

##Other Operators
All other (non-infix) operators have syntax like other functions.  Because they are functions, they can be lazily evaluated:

```
cond(a    λ“a”          ;; eager if, followed by lazy then
     [(λb λ“b”)         ;; list of lazily evaluated if/then clauses.
      (λc λ“c”)]
     λ“otherwise”) ;; lazily-evaluated else clause
```

The generated byte code "unwraps" the thunks to be if/then/else statements.  Why show the thunks?  Because they are there.  Lazy evaluation is a very useful and common programming technique.  The syntax is closer to how you'd define such a function manually.
```
cond<T> = Fn4(if:Bool                then:Fn0<T>    ;; Eager "if", lazy "then"
              elseifs:[(if:Fn0<Bool> then:Fn0<T>>)] ;; A list of lazy "if/then"'s
              else:Fn0<T>):T                        ;; A lazy "else"
;; defined cond:Fn4<Bool,Fn0<T>,List<Tuple2<Fn0<T>,Fn0<T>>>,Fn0<T>,T>
```

The cond built-in is overloaded with a second definition that leaves out the elseifs:
```
cond = Fn3(if:Bool then:Fn0<T> else:Fn0<T>):T
;; defined cond:Fn3<Bool,Fn0<T>,Fn0<T>,T>
```
There is no "if" without an "else" because such a statement would lack a return type for the false condition.

##Type System

Java Generics, p. 16 by Naftalin/Wadler has an example that shows why mutable collections cannot safely be covariant.  *Immutable* collections *can* be covariant because of their nesting properties.  You can have a `ImList<Int>` and add a `Float` to it and you'll get back the union type `ImList<Int|Float>` which can then be safely cast to a `ImList<Number>` (`Number` is the most specific common ancestor of both `Int` and `Float`).  If the List were mutable, you'd have to worry about other pointers to the same list still thinking it was a `List<Int>`, but immutable collections solve that problem.

That paragraph assumes inheritance and, for Java compatibility, it makes sense.  Cymling's view of Java's inheritance in this case is: `type Number = Int | Float` where `Int` and `Float` are both built-in types.

Therefore, the type system needs some indication of what's immutable (grows by nesting like Russian Dolls) and what's not (changes in place).  Since imutability is the default, there should be an `@Mutable` or similar annotation required in order to update data in place.  Probably a second annotation `@MutableNotThreadSafe` should be required for people who really want to live dangerously.  Without such annotations, your class/interface cannot do any mutation.

There may come a time when the type system needs to choose between being mathematically sound and being lenient.  I am not committed to soundness in the strict sense.  I require a type system to prevent-known-bad, but that's weaker than most type systems which have an allow-known-good outlook.  My experience with Java is that sooner or later you have to cast somewhere in your API.  That seems just a little too strict for me, but this paragraph exceeds the limits of my competence, so basically, I don't know.

##Defining Types
To make a person type, you need:
```
;; Defines a type called Nameable that has a name() method which returns a String or null
type Nameable = ( name:String? )

;; Defines a type called Person that has a name(), age() and height() methods.
;; the name() method comes from Nameable.
type Person = Nameable & ( age:Int height:Float )
```

Here is a let block that performs some pretty simple logic on some people (fred is declared, but never used):

```
let( ( marge=(name=“Marge” age=37 height=16.24)
       fred:Person=(name=“Fred” age=39 height=15.5)
       sarah:Person=(”Sarah” 35 17.0) )
     cond(gt(marge.height sarah.height)
           λ“Marge is taller than Sarah”
           “Marge is not taller than Sarah”))
```

Parameterized types use angle-brackets like Java.

```
type List<T> =             ; Define a type called “List” with type param T
        ( get:Fn1<Long,T>
          cons:Fn<U,List<T|U>> )                  
```

Main Method
```
main( (args:List<String>)
      last(print(“Hello “ args.getOrElse(1 “World”) “!”)
           1))
```

##Strings
*Wish List:*
I'd love to have Str8 (pronounced “Straight”) to be native support for UTF8, have all serialization use UTF8, and give Str8 a .toUtf16() method to convert to Java style strings.  This would require a bunch of work that I don't want to do up front, but over time I think it would be a big win.  Also, it would be good to rewrite the regular expressions library to use this and use it quickly.  When people use emoji, we don't want to be counting “code points” as opposed to characters the way you have to in Java.  UTF8 seems to be the new world standard...

##Pattern Matching
Instead of inheritence, we use pattern matching (like ML).
TODO: Make this work a lot more like cond above.  Maybe have a constructedBy(item signature) or something?
```
match(item
      (Person(n:name a:age h:height) = λ“Person: $n$”
       Car(license year)             = λ“Car: $license$"
       default                       = λ“Default”))
```

Note: Enums values may have to be sub-classes of the Enum they belong to for pattern matching to work.

##Types
Any is the progenitor super-type
Nil is a sub-type of most things
Nothing might be a sub-type of Nil indicating that no valid type can be used?

##Union Types
Are available.  String-or-null is:
```
middleName:String|Nil
;; or maybe like Ceylon:
middleName:String?
```

Similar syntax could be used to indicate optional parameters.
```
foo = λ( (first:String
          middle:String=“”
          last:String)
        cat(“Hello “ first middle last))
```

Union and intersection types are available through type aliases:
```
type Suit = Clubs|Diamonds|Hearts|Spades

type FaceCard = Jack|Queen|King|Ace

type QueenOfSpades = Queen & Spades

type Num = Int

;; A Rank could be either a face card or a Num (int):
type Rank = FaceCard|Num

;; A card is a combination of a suit and a rank:
type Card = { suit:Suit
              rank:Rank
              toString:String=cat(suit “ “ rank) } ;; default zero-argument function
```

Function within the current namespace:
```
let{printCard:Fn<Card,String> =      ; variable name and optional type
     λ( (card:Card)                  ; function definition.  Arguments form a record
        "$card.suit$ $card.rank$") } ; body
```
Here we extend a type:
```
type WithBack = showBack=λ“*****”

type CardWithBack Card & WithBack
```

A poker chip:
```
type Color = Red|Green|Blue|Yellow

type Chip = {color:Color value:Int}

type PlayItem = Chip|CardWithBack
```

Now when you use a PlayItem, you have to destructure it:
TODO: Destructuring syntax needs work!
```
toString(item:PlayItem) = 
    case(item (Chip chip cat(“Chip: “ chip.color))
              (CardWithBack card cat(“Card: “ card.printCard))))
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

#Reserved syntax
```
. field access
, whitespace
{} map/dictionary (also stores key order from creation)
() tuple/record
[] vector/list
#{} set
<> parameterized type
: introduces a type
= type assignment, or key-value pair binding.
@ introduces an annotation
```

## Keywords
```
type introduces a type
default The default case for match and cond statements
match for type matching (ML calls this "pattern matching" but Java uses that to mean Regex)
Nil for null or false
t for true
```
