# Cymling as a Data Exchange Format

A subset of the [Cymling language](README.md).
Sort of a type-safe version of JSON or Clojure data.
Designed for serialization and deserialization.

Zipped data format:
```
cym/              // Everything goes in a root folder so that when you unzip, it's all contained.
cym/version.txt   // The version number x.y.z - parse this first as the parsing rules may change in newer versions.
cym/allTypes.type // All classes used in this zip are defined in this file.  A future version may allow package/folders and individual type files.
                  // This file should be parsed second.
                  // Global typealiases can be defined in this file too.

cym/data/         // The actual data files go here.  Should be parsed third after version number and types.
```
All files are UTF-8 text.
All filenames besides cym/meta/version are valid Cymling user-defined class names (start with an uppercase letter, no periods, etc.).
The receiver of this data can supply a map of types from cymData/meta/classes to their own compatible types, or their system can guess at default types already loaded by the classloader that match these definitions.
Each class has an `id: Long` field as the first field which will uniquely identify each object of a given type.

 - Built-in data types like Clojure (or JSON) except the fundamental unit is a Record instead of a linked list.  Default implementations of JVM collections can be found in [Paguro](https://github.com/GlenKPeterson/Paguro).  Here are the built-in types:
   - Records (tuples / heterogenious map) with items accessible by order `(1 "hello" 3.5)`.
   - Objects (defined by classes) with items accessible by order `ClassName(1 "hello" 3.5)`, by name `ClassName(a=1 b="hello" e=3.5)`, or some combination of the two (like parameters in Kotlin).
   - List: `[a b c]` (like Clojure)
   - There are no built-in data types for homogenious maps or sets (yet).
   If there are, they will probably not use angle brackets or curly braces, as the language reserves those for types and functions respectively.
   They may do something like `#()` for a set, `%()` for a map, `$()` for a linked-list...
 - Angle brackets are used for parameterized types: `List<String>`
 - Null (nil) safety with `?` type operator like Kotlin

### Comments

In order to look familiar, traditional C-style (Java/Kotlin) comments will be used.

```
// single line comment

/*
Multi-line comment
Still in a multi-line comment...
Comment ends here: */

/**
Multi-line CymDoc comment
*/
```

Operators (in precedence order):
 - `=` associates keys with values in records/maps.

Type operators (in precedence order):
 - `<T>` Specifies a generic type, like Java, Scala, and Kotlin
 - `:` Introduces a type, like Scala and Kotlin.

## Defining Types
All types must be named.
Names and typealiases must be unique per zip file.
Names will be resolved to type descriptions in the Classes file.
The resolution may go to Tuples with reified generic types, or to fully qualified class names.
The first field, `id: Long` is *implied* and need not be specified.
```
type my.package.Person(
    name: String // Required String parameter
    height: Float? // Required decimal parameter, may be null.
    age: Int = 0 // Optional integer parameter, defaults to zero
    children: List<Person> = [] // Optional list parameter, defaults to empty list.
)
typealias Person = my.package.Person
```

An instance of that definition is declared using Record syntax.  Parameters can be accessed by index (0-based), or optional names may be used for clarity.
```
// Each line produces a Person instance.
Person(1 “Marge” 16.24 37)
Person(2 “Fred” 17.89) // gets the default age=0.
// We can skip the age parameter (taking the default of zero) and specify a subsequent parameter by name.
// Notice how this references previously defined People by ID.
// Forward references will probably be allowed, but maybe not in phase one.
Person(3 “Auntie Em” 3.14, children=[Person(1) Person(2)])
```
Type/Class names can be fully specified for readability, or aliased for brevity.
Variables can be declared to use instead of the id-based scheme:

# License

Copyright 2015-2020 Glen K. Peterson

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

At your option, you may elect to use this under the Eclipse public license as well.  It's user's choice.
