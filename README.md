# Cymling Programming Language
(Formerly called RIPPL)

*Design Unfinished: Comments Welcome!*

 - Nearly homoiconic (like a lisp, with it's own JSON-like data definition syntax)
 - Functional (first class functions, immutability is assumed/easier/preferred)
 - Type-safe (with type aliases like ML, not Object Oriented)

Cymling is a rarely used word for a pattypan squash.  It's also one of the few short words in the English language that have the letters ML in them ("Cy**ML**ing") which is a nod to the ML programming language.  ML because it showed me that static typing does not need to be Object Oriented.  I could have nodded to Clojure, JSON, and Java too, but ML was the final missing piece for me.

## Design Goals
 - Clojure with types, but somewhat different syntax.
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
   - Record (tuple / heterogenious map): `(a b c)` (items accessible by order) OR `(a=b c=d e=f)` (items also accessible by name) OR a combination of the two.
   - List: `[a b c]`
   - Function: `{ args -> body }`
   - There are no built-in data types for maps or sets.
 - Angle brackets are used for parameterized types: `List<String>`
 - Null (nil) safety with `?` type operator like Kotlin

## Syntax
The syntax is a combination of Clojure (Lisp) and ML, with a sprinkling of Kotlin.

### Commas
Commas are whitespace (like Clojure).  Add them when it helps you, but the compiler treats them as spaces.

### Comments

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

### Functions vs. Record literals
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

## Operators
Infix operators allow very Natural-Language friendly syntax, but can quickly lead to confusion with precedence and overriding.  So there will be very few operators in this language, mostly for the type system.

Operators (in precedence order):
 - `.` for function application
 - `=` associates keys with values in records/maps.

Type operators (in precedence order):
 - `<T>` Defines a symbol (in this case, the letter `T` to be used as a parameterized type.
 - `:` Defines a type (TODO: return type, or just plain type?).
 - `|` ("or") for union types, `&` ("and") for intersection types

### Dot Operator
Instead of the usual Lisp convention of reading code inside out:
```
(third (second (first arg1) arg2) arg3)
```
We borrow the “dot operator” from C-style languages to enable a “Fluent Interface” style:
```
first(arg1).second(arg2)
           .third(arg3)
```

## Records
Like ML, we'll use records.  This language is type safe, but it does not require you to define types beforehand.  Just make records and use them.  You'll probably want to define aliases for commonly used records, especially if you pass them to functions.  For that, there's a built-in `type` keyword.  A data definition looks like this:
```
type Person = (instance=(name:String?
                         age:Int = 0
                         height:Float?)
               static=())
```
Notice that this is C-like syntax.  That's because this is about types and therefore deserves to *look* different from the more lispy grammar of the rest of the language.

An instance of that definition is declared using Record syntax.  Parameters can be accessed by index (0-based), or optional names may be used for clarity.
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

## Interfaces
Interfaces (not objects) can extend the functionality of records in a pseudo-Object-Oriented way.  When creating data that you intend to treat as implementing an interface, simply attach the name of the interface to the data to give it a type when you construct it:
~~TODO: Pick one:~~
~~A. This cannot be used with union or intersection types~~
```
;; NOT THIS!
;; Person(name=“Marge” age=37 height=16.24)
```
B. This will work with union or intersection types
```
(name=“Marge” age=37 height=16.24):Person
(name=“Marge” age=37 height=16.24):Person|Employee
```

## Functions
Functions are first class.  To name a function, simply assign it to a variable, like any other value.

Anonymous function syntax is copied from Kotlin (formerly used a syntax involving the λ character, but not exactly equivalent to Lambda Calculus).  The basic syntax of a function definition is `{ arguments -> functionBody }`.  Arguments are the same as a record (but do not require the parens), the body is any expression which will only be executed when the function is called.  A function without the arrow `{ expression }` assumes zero arguments and is effectively a "thunk" (lazy evaluation).  As syntactic sugar, Lots of Irratating Superfluous Parentheses (LISP) can be removed by eliminating the record parens before the arrow and eliminating parens which enclose a single lambda.

```
val myFn = {“hello!”}
;; defined myFn:Fn0<String>

myFn() ;; Apply the function
;; "hello!"

printLater(myFn) ;; Pass the function to another function (so it can be applied later)

val myFn2 = { name:String ->
              "Hello $name$. Pleased to meet you!" }
;; defined myFn2:Fn1<String,String>

myFn2("Kelly")
;; "Hello Kelly. Pleased to meet you!"
```

This means that function pointers require no special handling.
```
val marge=(age=37):Person

marge.age() ;; function application
;; 37:Int

marge.age ;; Returns the value of the field "age" (which is a function).
;; Fn0<Int>
```

## Other Operators
All other (non-infix) operators have syntax just like functions.  Because they are functions, they can be lazily evaluated:

```
cond(a    {“a”}          ;; eager if, followed by lazy then
     [({b} {“b”})        ;; list of lazily evaluated if/then clauses.
      ({c} {“c”})]
     {“otherwise”}) ;; lazily-evaluated else clause
```

The generated byte code "unwraps" the thunks to be if/then/else statements.  Why show the thunks?  Because lazy evaluation is important.  It is a useful and common programming technique.  Programmers should be aware of when they are using it.  If you've ever used a language that doesn't diferentiate between pointers and values, you know how confusing this can be!  In Cymling, everything is an object (no primitives) so that's one less thing to worry about.  But there is a similar caveat with objects vs. functions, and this syntax (combined with the type system) makes it obvious to the programmer-end-user which one is being used at all times.
```
cond
;; Fn4<Bool,Fn0<T>,List<Tuple2<Fn0<T>,Fn0<T>>>,Fn0<T>,T>
```

The cond built-in is overloaded with a second definition that leaves out the elseifs:
```
cond(a    {“a”}          ;; eager if, followed by lazy then
     {“otherwise”}) ;; lazily-evaluated else clause

cond
;; Fn3<Bool,Fn0<T>,Fn0<T>,T>
```
There is no "if" without an "else" because such a statement would lack a return type for the false condition.

## Type System

Java Generics, p. 16 by Naftalin/Wadler has an example that shows why mutable collections cannot safely be covariant.  *Immutable* collections *can* be covariant because of their nesting properties.  You can have a `ImList<Int>` and add a `Float` to it and you'll get back the union type `ImList<Int|Float>` which can then be safely cast to a `ImList<Number>` (`Number` is the most specific common ancestor of both `Int` and `Float`).  If the List were mutable, you'd have to worry about other pointers to the same list still thinking it was a `List<Int>`, but immutable collections solve that problem.

That paragraph assumes inheritance and, for Java compatibility, it makes sense.  Cymling's view of Java's inheritance in this case is: `type Number = Int | Float` where `Int` and `Float` are both built-in types.

Therefore, the type system needs some indication of what's immutable (grows by nesting like Russian Dolls) and what's not (changes in place).  Since imutability is the default, there should be an `@Mutable` or similar annotation required in order to update data in place.  Probably a second annotation `@MutableNotThreadSafe` should be required for people who really want to live dangerously.  Without such annotations, your class/interface cannot do any mutation.

There may come a time when the type system needs to choose between being mathematically sound and being lenient.  I am not committed to soundness in the strict sense.  I require a type system to prevent-known-bad, but that's weaker than most type systems which have an allow-known-good outlook.  My experience with Java is that sooner or later you have to cast somewhere in your API.  That seems just a little too strict for me, but this paragraph exceeds the limits of my competence, so basically, I don't know.

## Defining Types
To make a person type, you need:
```
;; Defines a type called Nameable that has a name() method which returns a String or null
type Nameable = (instance=(name:String?)
                 static=())

;; Defines a type called Person that has a name(), age() and height() methods.
;; the name() method comes from Nameable.
type Person = Nameable & (instance=(age:Int height:Float)
                          static=())
```

Here is a let block that performs some pretty simple logic on some people (fred is declared, but never used):

```
let( ( marge=(name=“Marge” age=37 height=16.24)
       fred:Person=(name=“Fred” age=39 height=15.5)
       sarah:Person=(”Sarah” 35 17.0) )
     cond(gt(marge.height sarah.height)
           {“Marge is taller than Sarah”}
           {“Marge is not taller than Sarah”}))
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

### Static methods
```
type Person = (instance=(name:String?
                         age:Int = 0
                         height:Float?)
               static=(addAges = { people:List<Person>
                                   -> people.foldLeft(0, { count, person -> +(count person.age) } }
```

### Inferred type conversions
If you give your type fromXXXX or toXXXX static methods, the compiler can make this conversion.  For instance if you have a type Person, just add a static method as follows:

```
type Person = (instance=(name:String?
                         age:Int = 0
                         height:Float?)
               static=(toInt = { person:Person -> person.age })
```

## Strings
*Wish List:*
I'd love to have Str8 (pronounced “Straight”) to be native support for UTF8, have all serialization use UTF8, and give Str8 a .toUtf16() method to convert to Java style strings.  This would require a bunch of work that I don't want to do up front, but over time I think it would be a big win.  Also, it would be good to rewrite the regular expressions library to use this and use it quickly.  When people use emoji, we don't want to be counting “code points” as opposed to characters the way you have to in Java.  UTF8 seems to be the new world standard...

## Pattern Matching
Instead of inheritence, we use pattern matching (like ML).
TODO: Make this work a lot more like cond above.  Maybe have a constructedBy(item signature) or something?
```
match(item
      (Person(n:name a:age h:height) = {“Person: $n$”}
       Car(license year)             = {“Car: $license$"}
       default                       = {“Default”}))
```

Note: Enums values may have to be sub-classes of the Enum they belong to for pattern matching to work.

## Types
Any is the progenitor super-type
nil is a sub-type of most things
Nothing might be a sub-type of nil indicating that no valid type can be used?

## Union Types
Are available.  String-or-null is:
```
middleName:String|nil
;; or maybe like Ceylon/Kotlin:
middleName:String?
```

Similar syntax could be used to indicate optional parameters.
```
foo = { first:String
        middle:String=“”
        last:String
        -> cat(“Hello “ first middle last) }
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
let(printCard:Fn<Card,String> =      ; variable name and optional type
     { card:Card                  ; function definition.  Arguments form a record
       -> "$card.suit$ $card.rank$"}) ; function body
```
Here we extend a type:
```
type WithBack = showBack={“*****”}

type CardWithBack Card & WithBack
```

A poker chip:
```
type Color = Red|Green|Blue|Yellow

type Chip = (color:Color value:Int)

type PlayItem = Chip|CardWithBack
```

Now when you use a PlayItem, you have to destructure it:
TODO: Destructuring syntax needs work!  Should be similar to cond() expression.
```
toString(item:PlayItem) = 
    case(item (Chip { chip -> cat(“Chip: “ chip.color) })
              (CardWithBack { card -> cat(“Card: “ card.printCard)}))
```

## Additional Ideas
From Josh Bloch: https://youtu.be/EduWekviwRg

 - Maybe auto-promote variables from a Record to a Map with Assoc, and let the type-system handle that.
 - Type system must handle nulls (Nil).  Any time you start a function by checking basic attributes of arguments is a missed opportunity for the type system to help you out.
 - Make it easier to write immutable, private code.
 - Friend classes/packages?  So you can share certain internals only with certain other classes/packages?

# License

Copyright 2015 Glen K. Peterson

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

# Reserved syntax
```
. field access
, whitespace
() tuple/record (heterogenious map that stores key order from creation)
[] vector/list
{ -> } Function
= type assignment, or key-value pair binding.
<> parameterized type
@ introduces an annotation
: introduces a type
| 'or' for union types
& 'and' for intersection type
? for 'or nil' types
```

## Keywords
```
type introduces a type
default The default case for match and cond statements
match for type matching (ML calls this "pattern matching" but Java uses that to mean Regex)
nil for null or false
t for true
```
