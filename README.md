Dart Polymer Dependency Injection
=========================

This provides dependency injection using a Configuration to define Beans which can be injected into Autowired fields.

This is very similar to the Spring Dependency Injection using Annotations and Java Configuration.

This is able to automatically find Beans by searching the DOM. This allows Polymer Elements to be injected and autowired to configure your application.

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

You then trigger loading the beans and autowiring the fields by calling _configure_ on an instance of the AbstractHtmlInjectConfiguration:

    new Configuration().configure();

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

PolymerElements can be annotated with _Component_ to indicate that they are a bean. Once annotated they are able to be injected into autowired containers and may be autowired themselves:

    @PolymerElement('some-bean')
    @component
    class SomeBeanTag extends PolymerElement {
      @autowired SomeClass field;

      SomeBeanTag.created() : super.created();
    }

You can load the element by scanning the DOM. This is done using the AbstractHtmlInjectConfiguration subclass, and must be done before calling configure:

    new Configuration()
      .scan(document.querySelector('body'))
      .configure();

The scanning process will traverse the shadow dom of any PolymerElement found. This means that you can annotate PolymerElements that are deep within the DOM. You can restrict the search by using a more specific element to start the scanning process from. It is possible to call _scan_ multiple times before calling configure:

    new Configuration()
      .scan(document.querySelector('my-header'))
      .scan(document.querySelector('my-body'))
      .scan(document.querySelector('my-footer'))
      .configure();


Description
-----------

Every time you create an instance of a class by using the _new_ keyword you tightly couple your code to that class, and you will not be able to substitute that implementation with a different one. However if you write your class to use an interface, and inject the object to use, then you can change implementations by changing only the injection configuration.

Testing benefits greatly from this approach. A class can be isolated from other classes by mocking the interfaces that it requires. This allows for effective and simple unit tests that only test the class. This is in comparison to integration tests which test the class and all of the classes it uses, to confirm that they are behaving as a whole.

This also allows for greater reuse of classes. You can take a class (and the interfaces it uses) from one project and start using it in another project. If you have every dependency that the class requires then it can start working with minimal configuration.

This library allows you to define _Beans_, which are the values which can be injected, and to _Autowire_ fields or methods, injecting those _Beans_ into the fields and methods. All of this is controlled using a configuration which defines the _Beans_ to use.

### Configuration

The configuration is performed by a class which you define which must extend AbstractHtmlInjectConfiguration. This class can contain _Bean_ creating methods, and can also load beans by scanning the DOM. Bean methods must return a value and be annotated with _@Bean()_ or _@bean_:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean SomeClass makeSomeClass() => new SomeClass();
    }

The type of the bean is taken from the value of the returned object, not from the method definition. So this is an equivalent configuration:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean Object makeSomeClass() => new SomeClass();
    }

The configuration class will create all beans and inject them when it is configured. You trigger this configuration by calling _configure_:

    new Configuration().configure();

If you wish to scan the DOM to load beans then you must do so before calling configure:

    new Configuration()
      .scan(document.querySelector('body'))
      .configure();

You can call scan multiple times before calling configure:

    new Configuration()
      .scan(document.querySelector('my-header'))
      .scan(document.querySelector('my-body'))
      .scan(document.querySelector('my-footer'))
      .configure();

### Beans

A _Bean_ is a value which can be injected into an appropriate container.

### Autowiring

...

### Being Specific with Primary and Qualifier

...

Example Code
------------

...

