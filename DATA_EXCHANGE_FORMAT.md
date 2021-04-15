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

Each class has an implicit `_id: Long` field as the first field which will uniquely identify each object of a given type.
This allows for forward references and data deduplication so that the stored graph can be self-referential

 - Built-in data types like Clojure (or JSON) except the fundamental unit is a Record instead of a linked list.  Default implementations of JVM collections can be found in [Paguro](https://github.com/GlenKPeterson/Paguro).  Here are the built-in types:
   - Records (tuples / heterogenious map) with items accessible by order `(1 "hello" 3.5)`.
   - Objects (defined by classes) with items accessible by order `ClassName(1 "hello" 3.5)`, by name `ClassName(a=1 b="hello" e=3.5)`, or some combination of the two (like parameters in Kotlin).
   - List: `[a b c]` (like Clojure)
   - There are no built-in data types for homogenious maps or sets (yet).
   If there are, they will probably not use angle brackets or curly braces, as the language reserves those for types and functions respectively.
   They may do something like `#()` for a set, `%()` for a map...
 - Angle brackets are used for parameterized types: `List<String>`
 - Null (nil) safety with `?` type operator like Kotlin

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
The first field, `_id: Long` is *implied* and need not be specified.
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
// Notice how this references previously defined People by _id.
// Forward references will probably be allowed, but maybe not in phase one.
Person(3 “Auntie Em” 3.14, children=[Person(1) Person(2)])
```
Type/Class names can be fully specified for readability, or aliased for brevity.

### Deserializing Types

The deserializing code can accept everything as generic tuples, or provide a mapping: `Map<String,Class>` to translate from the Cym-data to Java classes (or classes in another language/paradigm).

# License

Copyright 2015-2020 Glen K. Peterson

This program and the accompanying materials are made available under the
terms of the Apache License, Version 2.0 which is available at
https://www.apache.org/licenses/LICENSE-2.0
or the Eclipse Public License 2.0 which is available at
http://www.eclipse.org/legal/epl-2.0

SPDX-License-Identifier: Apache-2.0 OR EPL-2.0
