# Refactoring Guru Design Patterns Catalog

This document is a comprehensive summary categorized by Creational, Structural, and Behavioral patterns.

## 🏗️ Creational Patterns
Creational design patterns provide various object creation mechanisms, which increase flexibility and reuse of existing code.

| Pattern | Summary |
| :--- | :--- |
| **Factory Method** | Provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created. |
| **Abstract Factory** | Lets you produce families of related objects without specifying their concrete classes. |
| **Builder** | Lets you construct complex objects step by step. Allows producing different types and representations of an object using the same construction code. |
| **Prototype** | Lets you copy existing objects without making your code dependent on their classes. |
| **Singleton** | Ensures that a class has only one instance, while providing a global access point to this instance. |

### 🔍 Deep Dive: Factory Method
- **Intent:** Provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created.
- **Problem:** Imagine a logistics app initially handling only `Truck` transport. Adding `Ship` requires changes to the entire codebase, leading to nasty conditionals switching behavior based on transportation class.
- **Solution:** Replace direct object construction calls with calls to a special *factory method*. Objects are still created via the `new` operator, but it's called from within the factory method.
- **Structure:** 
    1. **Product** declares the interface common to all objects produced by the creator.
    2. **Concrete Products** are different implementations of the product interface.
    3. **Creator** class declares the factory method returning new product objects.
    4. **Concrete Creators** override the base factory method to return a different type of product.

## 🏛️ Structural Patterns
Structural design patterns explain how to assemble objects and classes into larger structures, while keeping these structures flexible and efficient.

| Pattern | Summary |
| :--- | :--- |
| **Adapter** | Allows objects with incompatible interfaces to collaborate. |
| **Bridge** | Splits a large class or set of related classes into two separate hierarchies—abstraction and implementation—which can be developed independently. |
| **Composite** | Lets you compose objects into tree structures and work with them as if they were individual objects. |
| **Decorator** | Lets you attach new behaviors to objects by placing them inside special wrapper objects. |
| **Facade** | Provides a simplified interface to a library, framework, or any other complex set of classes. |
| **Flyweight** | Lets you fit more objects into RAM by sharing common parts of state between multiple objects. |
| **Proxy** | Provides a substitute or placeholder for another object to control access to it. |

### 🔍 Deep Dive: Adapter
- **Intent:** Allows objects with incompatible interfaces to collaborate.
- **Problem:** A stock market app downloads XML data but needs to use a 3rd-party analytics library that only accepts JSON.
- **Solution:** Create an *adapter*—a special object that converts the interface of one object so that another object can understand it. The adapter wraps one of the objects to hide the complexity of conversion.
- **Structure:**
    1. **Client** contains the existing business logic.
    2. **Client Interface** describes a protocol other classes must follow to collaborate.
    3. **Service** is a useful class (usually 3rd-party) with an incompatible interface.
    4. **Adapter** implements the client interface while wrapping the service object.

## ⚙️ Behavioral Patterns
Behavioral design patterns are concerned with algorithms and the assignment of responsibilities between objects.

| Pattern | Summary |
| :--- | :--- |
| **Chain of Responsibility** | Lets you pass requests along a chain of handlers. Each handler decides to process the request or pass it to the next. |
| **Command** | Turns a request into a stand-alone object containing all information about the request. |
| **Iterator** | Lets you traverse elements of a collection without exposing its underlying representation. |
| **Mediator** | Restricts direct communications between objects and forces them to collaborate only via a mediator object. |
| **Memento** | Lets you save and restore the previous state of an object without revealing implementation details. |
| **Observer** | Defines a subscription mechanism to notify multiple objects about events happening to the object they're observing. |
| **State** | Lets an object alter its behavior when its internal state changes, as if the object changed its class. |
| **Strategy** | Defines a family of algorithms, puts each into a separate class, and makes their objects interchangeable. |
| **Template Method** | Defines the skeleton of an algorithm in a superclass but lets subclasses override specific steps without changing the structure. |
| **Visitor** | Lets you separate algorithms from the objects on which they operate. |

### 🔍 Deep Dive: Strategy
- **Intent:** Lets you define a family of algorithms, put each into a separate class, and make their objects interchangeable.
- **Problem:** A navigation app initially only built routes for cars. Adding walking, public transport, and cycling routes bloated the main class with massive conditionals and made maintenance a headache.
- **Solution:** Extract all algorithms into separate classes called *strategies*. The original class (context) has a field for storing a reference to one of the strategies and delegates work to it.
- **Structure:**
    1. **Context** maintains a reference to a concrete strategy and communicates only via the strategy interface.
    2. **Strategy interface** is common to all concrete strategies, declaring a method the context uses to execute an algorithm.
    3. **Concrete Strategies** implement different variations of the algorithm.
    4. **Client** creates a specific strategy object and passes it to the context.
