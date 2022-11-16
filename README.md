# Cymling Programming Language

*Rough Ideas Follow: Feel free to talk me out of some things!*

 - Nearly homoiconic (like a lisp, with it's own JSON-like data definition syntax)
 - Functional (first class functions, immutability is assumed/easier/preferred)
 - Type-safe (with type aliases like ML, not necessarily Object Oriented)
 - Has a compatable [data exchange format](DATA_EXCHANGE_FORMAT.md)

Cymling is a rarely used word for a pattypan squash.  It's also one of the few short words in the English language that have the letters ML in them ("Cy**ML**ing") which is a nod to the ML programming language.  ML because it showed me that static typing does not need to be Object Oriented.  The C nods to Clojure.

## Design Goals
 - Yet another typed Clojure with and superficially C/JavaScript/Kotlin-like syntax
 - Static Type checking based on Records, but in a way that doesn't preclude writing functions first and defining complex data types later.
 - Immutability is the default.
 - Applicative Order by default (eager, not like Haskell)
 - Type inference for local variables, but not for function parameters or return types (the only places type safety is proven to improve comprehension).
 - Regular (lisp-like) syntax with very few infix operators for the basic language
 - Traditional algebraic syntax for types
 - Homoiconic where practical, especially toString() implementations (see [Indented](https://github.com/GlenKPeterson/Indented) for the toString() library).
 - No primitives (int, float, etc.).  Built-in and user-defined data behave the same.  (Like Kotlin before version 1.6)
 - Types are related using interfaces, aliases and set theory (like ML), not through object hierarchies.
   Inheritance is for interfaces only.
   Records (a little like Classes) can implement interfaces, but cannot inherit from each other.
   Some class inheritance may be allowed with something like a @JvmExtends annotation for compatibility with Object-Oriented libraries.
 - Evaluative: almost everything is an expression – no return statements.
 - Built-in data types like Clojure (or JSON) except the fundamental unit is a Record instead of a linked list.
   Default implementations of JVM collections can be found in [Paguro](https://github.com/GlenKPeterson/Paguro).
   Built-in types:
   - Record (like a heterogeneous map) with items accessible by by name `(a=b c=d e=f)`, order `(a b c)`, or some combination of the two (like parameters in Kotlin).
     Function parameters look like a record because they are roughly equivalent to a record `someFun(x y z)`
   - Vector (ArrayList/AssociativeArray): `[a b c]` (like Clojure)
   - Function: `{ optionalArgs -> body }` (Like Kotlin)
   - There are no built-in data types for homogeneous maps or sets.
     Those will be in the standard library (based on Paguro which was forked from Clojure).
 - Angle brackets are used for parameterized types: `List<String>`
 - Null safety with `?` type operator like Kotlin and Ceylon
 - The language should manage singleton instances of common functions like the identity function (just returns its argument) so that other functions can be compared to it for equality.

## Syntax
The syntax is a combination of Clojure (Lisp) and ML, designed to look C-style, like Kotlin/Java/JavaScript.

### Commas
Commas are whitespace (like Clojure).  Add them when it helps you, but the compiler treats them as spaces.

### Comments

In order to look familiar, traditional C-style comments will be used.  Or possibly a semicolon starts a comment like Lisp?

```
// single line comment

/*
Multi-line comment
Still in a multi-line comment...
Comment ends here: */

/**
Multi-line CymDoc comment in .md format
*/
```

### Functions vs. Record literals
**Lisp** puts the function name to the right of the parenthesis, which causes plain lists to require quoting:
```
(func arg1 arg2)    ;; call/apply func with arguments arg1 and arg2.
'("Marge" 37 16.24) ;; a literal list of 3 items.
```

**Cymling** puts the function to the left and literal Records (not lists) will NOT require quoting:
```
func(arg1 arg2)    // function application
(name="Marge" age=37 height=16.24) // anonymous record of 3 items with members name:String, age:Int and height:Float
Person("Marge" 37 16.24) // Person record instantiated with 3 items of the appropriate types.
```

## Operators
Infix operators allow very Natural-Language friendly syntax, but can quickly lead to confusion with precedence and overriding.
There will be very few infix operators in this language, mostly for the type system.

Operators (in precedence order):
 - `.` for function application
 - `=` associates keys with values in records/maps.

Type operators (in precedence order):
 - `<T>` Specifies a generic type, like Kotlin/Scala/Java
 - `:` Introduces a type, like Kotlin/Scala.
 - `|` ("or") for union types, `&` ("and") for intersection types

### Dot Operator
Instead of the usual Lisp convention of reading code inside out:
```
(third (second (first arg1) arg2) arg3)
```
We borrow the "dot operator" from C-style languages to enable a "Fluent Interface" style:
```
first(arg1).second(arg2)
           .third(arg3)
```

## Records
Records are the basis of Cymling.
This language is type safe, but does not require you to define types beforehand.
Just make tuples or records and use them.
The difference between a record and a tuple is that members of a record are accessed by name while members of a tuple are accessed by position.
Cymling may support an anonymous tuple as well as a record, but maybe not immediately.
You'll probably want to define aliases for commonly used records, especially if you pass them to functions.
For that, there's a built-in `type` keyword.
A data definition looks like this:
```
type Person(name:String?
            age:Int = 0
            height:Float?)
```
Notice that this is C-like syntax.
That's because this is about types and therefore deserves to *look* different from the more lispy grammar of the rest of the language.

An instance of that definition is declared using Record syntax.  Parameters can be accessed by index (0-based), or optional names may be used for clarity.
```
// Each line produces a Person instance.
Person("Marge" 37 16.24)
Person(name="Fred" age=23 height=17.89)
Person("Little Margo" height=3.14) // gets the default age=0.
```

Both of the above examples compile to something like Plain Old Java Objects (POJO's) of type Person with getter methods and a static factory constructor, but no setter methods:
```java
public class Person implements IndentedStringable {
    private final @NotNull String name;
    private final @NotNull Long age;
    private final @NotNull Double height;
    private Person(@NotNull String p1, @NotNull Long p2, @NotNull Double p3) {
        name = p1;
        age = p2;
        height = p3;
    }
    public @NotNull String getName() { return name; }
    public long getAge() { return age; }
    public double getHeight() { return height; }

    @Override
    public String indentedStr(int indent) {
        return "Person(" + stringify(name) +
               " " + stringify(age) +
               " " + stringify(height) + ")";
    }

    @Override
    public String toString() { return indentedStr(0); }

    @Override
    public int hashCode() { return EQUATOR.hash(this); }

    @Override
    public boolean equals(Object other) { return EQUATOR.eq(this, other); }

    public static Person of(@NotNull String name, @NotNull Long age, @NotNull Double height) {
        return new Person(name, age, height);
    }

    public static Equator<Person> getDefaultEquator();  // Defines equality
}
```
Note the private constructor and public factory method.
This follows Joshua Bloch's advice and makes it easy to control instance creation later for making a flyweight or limited instance class.
This is *different* from Kotlin.
It may implement a Tuple3-like interface, but does not *extend* anything.
Maybe there will be a @JvmExtends annotation to let you extend Java classes for compatibility with existing libraries.
There may be static Equator and Comparator objects on this too.
It may include JetBrains @Nullable and @NotNull annotations (in the generated code).

```
// Record definition with some defaults and inferred types (name: String and Height: Float32)
// Note that position matters (all Person's will be defined in the order: name, age, height).
type Person(
    name = "Marge" // String with default value
    age: Int       // required parameter
    height = 16.24 // Float with default value
)

// Instantiation:
val sally = Person("Sally" 15 12.2)
val fred = Person(name="Fred" 35) // age is 35, height is 16.24
val marge = Person(age=37)

marge.height // 16.24: Float64
fred.age     // 5: Int64
```

## Interfaces
Interfaces (not objects) can extend the functionality of other interfaces in a pseudo-Object-Oriented way.  When creating data that you intend to treat as implementing an interface, simply attach the name of the interface to the data to give it a type when you construct it:
```
Person(name="Marge" age=37 height=16.24)
```
Require interfaces for intersection types and type-aliases for union types
```
typealias PnE = Person | Employee
Person("Marge", 37, 16.24)
PnE("Marge" 37 16.24)
interface GoodPerson implements Person, Good
GoodPerson("Marge" 37 16.24)
```

## Functions
Functions are first class.  To name a function, simply assign it to a variable, like any other value.

Anonymous function syntax is copied from Kotlin (formerly used a syntax involving the λ character, but not exactly equivalent to Lambda Calculus).  The basic syntax of a function definition is `{ arguments -> functionBody }`.  Arguments are the same as a record (but do not require the parens), the body is any expression which will only be executed when the function is called.  A function without the arrow `{ expression }` assumes zero arguments and is effectively a "thunk" (lazy evaluation).  As syntactic sugar, Lots of Irratating Superfluous Parentheses (LISP) can be removed by eliminating the record parens before the arrow and eliminating parens which enclose a single lambda.

```
val myFn = { "hello!" }
// defined myFn:Fn0<String>

myFn() // Apply the function
// "hello!"

printLater(myFn) // Pass the function to another function (so it can be applied later)

// Define myFn2:Fn1<String,String>
val myFn2 = { name: String ->
              "Hello $name$. Pleased to meet you!" }

myFn2("Kelly")
// "Hello Kelly. Pleased to meet you!"
```

This means that function pointers require no special handling (is this a good idea?).
```
val marge=Person(age=37)

marge.age() // function application
// 37:Int

marge.age // Returns the value of the field "age" (which is a function).
// Fn0<Int>
```

Alternately, some other syntax could access the function:
```
marge.age // 37:Int function application
marge&age // Fn0<Int> function reference
```

## Other Operators
This may be a bad idea...
All other (non-infix) operators have syntax just like functions.  Because they are functions, they can be lazily evaluated:

```
cond(a    {"a"}          ;; eager if, followed by lazy then
     [({b} {"b"})        ;; list of lazily evaluated if/then clauses.
      ({c} {"c"})]
     {"otherwise"}) ;; lazily-evaluated else clause
```

The generated byte code "unwraps" the thunks to be if/then/else statements.  Why show the thunks?  Because lazy evaluation is important.  It is a useful and common programming technique.  Programmers should be aware of when they are using it.  If you've ever used a language that doesn't diferentiate between pointers and values, you know how confusing this can be!  In Cymling, everything is an object (no primitives) so that's one less thing to worry about.  But there is a similar caveat with objects vs. functions, and this syntax (combined with the type system) makes it obvious to the programmer-end-user which one is being used at all times.
```
cond
;; Fn4<Bool,Fn0<T>,List<Tuple2<Fn0<T>,Fn0<T>>>,Fn0<T>,T>
```

The cond built-in is overloaded with a second definition that leaves out the elseifs:
```
cond(a    {"a"}          ;; eager if, followed by lazy then
     {"otherwise"}) ;; lazily-evaluated else clause

cond
;; Fn3<Bool,Fn0<T>,Fn0<T>,T>
```
Should we allow an "if" without an "else" branch?  Such a statement would lack a return type for the false condition.

## Type System

Types should be record-based.  Meaning that a type definition is based on named members of a data structure and their types.  Thus, Person(name:String age:Int) would be defined by its two members (name and age) and their types (String and Int).  Type inference will work on these structures as well.  This should allow Duck Typing unless you annotate your type with @Strict or similar.  So that Car(name:String age:Int) will by default be interchangeable with Person.  If we add a `car:Car` parameter to `Person`, it can (by default) still be passed to any function expecting a type with `name:String` and/or `age:Int` member.  Duck typing.  In this case, you may want to be careful to pass `somePerson.car` or add an interface or a @Strict somewhere. Or add an Inferred Type Conversion `toCar()` method as detailed below?  Really, I need to play with this and see how it comes out in the wash.

Java Generics, p. 16 by Naftalin/Wadler has an example that shows why mutable collections cannot safely be covariant.  *Immutable* collections *can* be covariant because of their nesting properties.  You can have a `ImList<Int>` and add a `Float` to it and you'll get back the union type `ImList<Int|Float>` which can then be safely cast to a `ImList<Number>` (`Number` is the most specific common ancestor of both `Int` and `Float`).  If the List were mutable, you'd have to worry about other pointers to the same list still thinking it was a `List<Int>`, but immutable collections solve that problem.

That paragraph assumes inheritance and, for Java compatibility, it makes sense.  Cymling's view of Java's inheritance in this case is: `type Number = Int | Float` where `Int` and `Float` are both built-in types.

Therefore, the type system needs some indication of what's immutable (grows by nesting like Russian Dolls) and what's not (changes in place).  Since imutability is the default, there should be an `@Mutable` or similar annotation required in order to update data in place.  Probably a second annotation `@MutableNotThreadSafe` should be required for people who really want to live dangerously.  Without such annotations, your class/interface cannot do any mutation.

There may come a time when the type system needs to choose between being mathematically sound and being lenient.  I am not committed to soundness in the strict sense.  I require a type system to prevent-known-bad, but that's weaker than most type systems which have an allow-known-good outlook.  My experience with Java is that sooner or later you have to cast somewhere in your API.  That seems just a little too strict for me, but this paragraph exceeds the limits of my competence, so basically, I don't know.

## Defining Types
To make a person type, you need:
```
;; Defines a type called Nameable that has a name() instance method which returns a String or null
type Nameable = (name:String?)

;; Defines a type called Person that has a name(), age() and height() methods.
;; the name() method comes from Nameable.
type Person = Nameable & (age:Int height:Float)
```

Here is a let block that performs some pretty simple logic on some people (fred is declared, but never used):

```
let( ( marge=(name="Marge" age=37 height=16.24)
       fred:Person=(name="Fred" age=39 height=15.5)
       sarah:Person=("Sarah" 35 17.0) )
     cond(gt(marge.height sarah.height)
           {"Marge is taller than Sarah"}
           {"Marge is not taller than Sarah"}))
```

Parameterized types use angle-brackets like Java.

```
type List<T> =             ; Define a type called "List" with type param T
        ( get:Fn1<Long,T>
          cons:Fn<U,List<T|U>> )
```

Main Method
```
main( (args:List<String>)
      last(print("Hello " args.getOrElse(1 "World") "!")
           1))
```

### Static/Class methods and fields
```
type Person = (name:String?
               age:Int = 0
               height:Float?
               static=(addAges = { people:List<Person>
                                   -> people.foldLeft(0, { count, person -> +(count person.age) }) }
```

#### Default Static methods
Each record will have a generated `defaultEquator()` method which can be overridden.
It will default to comparing any unique fields or unique combinations of fields.
Uniqueness will work like the SQL UNIQUE and be declared with `uniqueFields=name height` or similar in a constraints section (similar to the static section).
For the JVM, the `.equals(other)` method implementation will be implemented as `defaultEquator(this, other)`.


### Inferred type conversions
If you give your type fromXXXX or toXXXX static methods, the compiler can make this conversion.  For instance if you have a type Person, just add a static method as follows:

```
type Person = (instance=(name:String?
                         age:Int = 0
                         height:Float?)
               static=(toInt = { person:Person -> person.age })
```

## Strings
*Wishlist:*
I'd love to have Str8 (pronounced "Straight") to be native support for UTF8, have all serialization use UTF8, and give Str8 a .toUtf16() method to convert to Java style strings.  This would require a bunch of work that I don't want to do up front, but over time I think it would be a big win.  Also, it would be good to rewrite the regular expressions library to use this and use it quickly.  When people use emoji, we don't want to be counting "code points" as opposed to characters the way you have to in Java.  UTF8 seems to be the new world standard...

## Pattern Matching
Instead of inheritence, we use pattern matching (like ML).
TODO: Make this work a lot more like cond above.  Maybe have a constructedBy(item signature) or something?
```
item.match({ (n:name a:age h:height):Person -> "Person: $n$" }
           { (license year):Car             -> "Car: $license$" }
           { "Default" })
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
        middle:String=""
        last:String
        -> cat("Hello " first " " middle " " last "!") }
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
type Card = (suit:Suit
             rank:Rank
             toString:String = { concat(rank " of " suit) }) ;; default zero-argument function
```

Function within the current namespace:
```
let(printCard:Fn<Card,String> =      ; variable name and optional type
     { card:Card ->                  ; function definition.  Arguments form a record
       "$card.suit$ $card.rank$"}) ; function body
```
Here we extend a type:
```
type WithBack = (showBack="*****")

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
    item.match({ chip         -> cat("Chip: " chip.color()) }
               { cardWithBack -> cat("Card: " card.printCard())})
```


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
# (de)reference
% keyword???
```

## Keywords
```
type introduces a type
default The default case for match and cond statements
match for type matching (ML calls this "pattern matching" but Java uses that to mean Regex)
nil for null or false
t for true
```

## Additional Ideas
From Josh Bloch: https://youtu.be/EduWekviwRg

 - Maybe auto-promote variables from a Record to a Map with Assoc, and let the type-system handle that.
 - Type system must handle nulls (Nil).  Any time you start a function by checking basic attributes of arguments is a missed opportunity for the type system to help you out.
 - Make it easier to write immutable, private code.
 - Friend classes/packages?  So you can share certain internals only with certain other classes/packages?

# License

Copyright 2015-2021 Glen K. Peterson

This program and the accompanying materials are made available under the
terms of the Apache License, Version 2.0 which is available at
https://www.apache.org/licenses/LICENSE-2.0
or the Eclipse Public License 2.0 which is available at
http://www.eclipse.org/legal/epl-2.0

SPDX-License-Identifier: Apache-2.0 OR EPL-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
