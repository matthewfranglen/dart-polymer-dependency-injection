Dart Polymer Dependency Injection
=========================

This provides dependency injection using a Configuration to define Beans which can be injected into Autowired fields.

This is very similar to the Spring Dependency Injection using Annotations and Java Configuration.

This is able to automatically find Beans by searching the DOM. This allows Polymer Elements to be injected and autowired to configure your application.

Dependency Injection
--------------------

This library extends the *dependency_injection* library, which is used to perform all dependency injection. The documentation for that library is available [here](https://github.com/matthewfranglen/dart-dependency-injection).

Synopsis
--------

Create the configuration by extending AbstractHtmlInjectConfiguration. Define some methods which return Beans:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean SomeClass makeSomeClass() => new SomeClass();

      @bean AnotherClass makeAnotherClass() => new AnotherClass();
    }

Within those classes you can define Autowired fields. The AbstractHtmlInjectConfiguration subclass can also be Autowired:

    class Configuration extends AbstractHtmlInjectConfiguration {

      ...

      @autowired void setSomeClass(SomeClass bean) {}
    }

    class SomeClass {
      @autowired void setAnotherClass(AnotherClass bean) {}
    }

You can only use the Bean annotation on methods. The arguments to those methods are autowired, allowing you to reference other beans:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean SomeClass makeSomeClass() => new SomeClass();

      @bean AnotherClass makeAnotherClass(SomeClass bean) {
        AnotherClass instance = new AnotherClass();
        instance.setSomeClass(bean);
        return instance;
      }
    }

Methods, setters, and fields can be autowired. A method that is autowired can accept multiple beans:

    class Configuration extends AbstractHtmlInjectConfiguration {
      ...

      @autowired AnotherClass field;
      @autowired set setter(AnotherClass value) {}
      @autowired void method(SomeClass someBean, AnotherClass anotherBean) {}
    }

Polymer Elements can be annotated with _Component_ to indicate that they are a bean. Once annotated they are able to be injected into autowired containers and may be autowired themselves:

    @PolymerElement('some-bean')
    @component
    class SomeBeanTag extends PolymerElement {
      @autowired SomeClass field;

      SomeBeanTag.created() : super.created();
    }

You can load the element by scanning the DOM. This is done using the AbstractHtmlInjectConfiguration subclass, and must be done before calling configure:

    new Configuration()
      ..scan(document.querySelector('body'))
      ..configure();

The scanning process will traverse the shadow DOM of any Polymer Element found. This means that you can annotate Polymer Elements that are deep within the DOM. You can restrict the search by using a more specific element to start the scanning process from. It is possible to call _scan_ multiple times before calling configure:

    new Configuration()
      ..scan(document.querySelector('my-header'))
      ..scan(document.querySelector('my-body'))
      ..scan(document.querySelector('my-footer'))
      ..configure();


Description
-----------

Every time you create an instance of a class by using the _new_ keyword you tightly couple your code to that class, and you will not be able to substitute that implementation with a different one. However if you write your class to use an interface, and inject the object to use, then you can change implementations by changing only the injection configuration.

Testing benefits greatly from this approach. A class can be isolated from other classes by mocking the interfaces that it requires. This allows for effective and simple unit tests that only test the class. This is in comparison to integration tests which test the class and all of the classes it uses, to confirm that they are behaving as a whole.

This also allows for greater reuse of classes. You can take a class (and the interfaces it uses) from one project and start using it in another project. If you have every dependency that the class requires then it can start working with minimal configuration.

This library allows you to define _Beans_, which are the values which can be injected, and to _Autowire_ fields or methods, injecting those _Beans_ into the fields and methods. All of this is controlled using a configuration which defines the _Beans_ to use.

### DOM Scanning

The coupling issue is particularly acute with Polymer Elements. If an element needs to trigger another then it is very hard to do so without reaching out to that element in the DOM. This couples the two elements to the particular layout they are in. Using events allows some decoupling, but that requires that one element contain the other.

With DOM scanning the elements can be isolated from each other. Each element can define the beans it requires using interfaces, allowing for easy testing and reuse. The DOM scanning includes the shadow DOM of Polymer Elements. This allows arbitrary element layout.

To trigger DOM scanning you only need to call the _scan_ method on the AbstractHtmlInjectConfiguration subclass. This method takes any html Element and will scan that and every directly or indirectly contained element.

You must call _scan_ before you call _configure_. This is because _scan_ registers the discovered elements as Beans, ready for autowiring. The autowiring only occurs when _configure_ is called.

Example Code
------------

Example code is available in the _example_ directory.

