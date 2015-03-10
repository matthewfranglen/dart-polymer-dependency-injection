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

Define some of your Polymer Elements as Components. When the DOM is scanned these will be treated as Beans. They can include Autowired fields:

    @CustomTag('some-element')
    @component
    class SomeElement extends PolymerElement {

      @autowired AnotherElement field;

      SomeElement.created() : super.created();
    }

You first scan the DOM by passing elements to the _scan_ method. Those elements, and elements reachable from those elements are scanned for Components. This scanning will check the shadow DOM of Polymer Elements:

    new Configuration()
      .scan(document.querySelector('my-header'))
      .scan(document.querySelector('my-body'))
      .scan(document.querySelector('my-footer'));

You then trigger loading the beans and autowiring the fields by calling _configure_ on an instance of the AbstractHtmlInjectConfiguration:

    new Configuration()
      .scan(document.querySelector('my-header'))
      .scan(document.querySelector('my-body'))
      .scan(document.querySelector('my-footer'))
      .configure();

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

### DOM Scanning

The coupling issue is particularly acute with Polymer Elements. If an element needs to trigger another then it is very hard to do so without reaching out to that element in the DOM. This couples the two elements to the particular layout they are in. Using events allows some decoupling, but that requires that one element contain the other.

With DOM scanning the elements can be isolated from each other. Each element can define the beans it requires using interfaces, allowing for easy testing and reuse. The DOM scanning includes the shadow DOM of Polymer Elements. This allows arbitrary element layout.

To trigger DOM scanning you only need to call the _scan_ method on the AbstractHtmlInjectConfiguration subclass. This method takes any html Element and will scan that and every directly or indirectly contained element.

You must call _scan_ before you call _configure_. This is because _scan_ registers the discovered elements as Beans, ready for autowiring. The autowiring only occurs when _configure_ is called.

Example Code
------------

...

Dependency Injection
--------------------

This library extends the *dependency_injection* library, which is used to perform all dependency injection. Since this library uses that heavily, the documentation has been reproduced below.

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

A _Bean_ is a value which can be injected into an appropriate container. It is returned by a method on the AbstractHtmlInjectConfiguration subclass.

Unlike Spring the methods that return Bean objects do not become singleton methods. If you manually call a bean method you may receive a different object to the bean that has been used for autowiring. Since the AbstractHtmlInjectConfiguration subclass can be autowired, you can inject the bean into the configuration if you need access to it:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @autowired SomeClass someClassBean;
      @bean Object makeSomeClass() => new SomeClass();
    }

    Configuration config = new Configuration()
    config.configure();
    print(config.someClassBean);

If you need beans to perform additional configuration then you can create an autowired configuration method on the AbstractHtmlInjectConfiguration subclass. That method will be invoked with all of the required beans:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean Object makeSomeClass() => new SomeClass();
      @bean AnotherClass makeAnotherClass() => new AnotherClass();

      @autowired void configureSomeClass(SomeClass someBean, AnotherClass anotherBean) {}
    }

The bean methods do not have to create the bean, they merely have to return it. This means you can use them to return DOM elements:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean Element getBody() => document.querySelector('body');
    }

If you use this approach then you may wish to review the *polymer_dependency_injection* package, which can scan the DOM looking for annotated polymer elements. It loads those elements as beans and allows them to be autowired.

### Autowiring

Autowiring allows a method, setter or field to be provided with a bean. Every bean and the AbstractHtmlInjectConfiguration subclass are eligible for autowiring.

Autowiring assigns by type. This is done by testing that the bean can be assigned to the autowired field. For example:

    class ExampleClass {}
    class ExampleSubClass extends ExampleClass {}
    class ExampleMixin extends Object with ExampleClass {}

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean ExampleSubClass makeBean() => new ExampleSubClass();

      // This will get autowired
      @autowired ExampleClass field;

      // This will NOT get autowired - ExampleSubClass is not assignable to ExampleMixin
      @autowired ExampleMixin mixinField;
    }

When you define a method or setter as autowired all of the parameters will be set to the appropriate bean and then the method will be invoked. For example:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean ExampleSubClass makeBean() => new ExampleSubClass();
      @bean ExampleMixin makeMixin() => new ExampleMixin();

      // This will get invoked with autowired arguments
      @autowired void autowiredMethod(ExampleSubClass bean, ExampleMixin mixin) {}

      // This will also get invoked with autowired arguments
      @autowired set mixin(ExampleMixin mixin) {}

      // This will NOT get invoked - both beans can be assigned to the parameter
      @autowired void ambiguousMethod(ExampleClass bean) {}
    }

When there are multiple beans that can be assigned to an autowired field then the autowiring fails. If there are no beans then the autowiring also fails. When the autowiring fails an exception is thrown. If you want a field to be assigned only if a bean is available then you can set it to optional:

    class Configuration extends AbstractHtmlInjectConfiguration {

      // This will not get invoked - but that will not throw an exception
      @Autowired(required: false) void missingBean(ExampleClass bean) {}
    }

When there are multiple beans that match a field you can indicate a preferred bean. This is covered in the next section.


### Being Specific with Primary and Qualifier

Multiple beans cannot be assigned to an autowired field. When there are multiple beans that match a field there are two ways to indicate a preferred bean. If there is a single preferred bean then the autowiring can proceed.

The first way is to change the bean to indicate that it is preferred. This is done using the primary annotation:

    class ExampleClass {}

    class Configuration extends AbstractHtmlInjectConfiguration {
      @bean @primary ExampleClass primaryBean() => new ExampleClass();
      @bean ExampleClass bean() => new ExampleClass();

      // This is autowired with the bean created by primaryBean
      @autowired ExampleClass field;
    }

The second way is to change the autowired field to indicate which bean is preferred. This is done by naming the bean and using the qualifier annotation:

    class Configuration extends AbstractHtmlInjectConfiguration {
      @Bean(name="chosen") ExampleClass preferredBean() => new ExampleClass()
      @bean ExampleClass bean() => new ExampleClass();

      // This is autowired with the bean created by preferredBean
      @autowired @Qualifier("chosen") ExampleClass field;

      // For methods you need to add the Qualifier to the parameter
      @autowired void method(@Qualifier("chosen") ExampleClass argument) {}

      // Setters also need the Qualifier on the parameter
      @autowired set value(@Qualifier("chosen") ExampleClass argument) {}
    }

Beans are automatically assigned names based on the name of the method that creates them. If the name starts with _get_, _make_ or _build_ then that is removed. The first letter of the name is changed to lower case. For example:

    class Configuration extends AbstractHtmlInjectConfiguration {
      // The name is set, so the method name is not inspected
      @Bean(name="namedBean") String notInspected() => "Named Bean";

      // The method name starts with get so the bean name is firstBean
      @bean String getFirstBean() => "First Bean";

      // The method name starts with make so the bean name is secondBean
      @bean String makeSecondBean() => "Second Bean";

      // The method name starts with build so the bean name is thirdBean
      @bean String buildThirdBean() => "Third Bean";

      // The method name starts with a capital letter so the bean name is fourthBean
      @bean String FourthBean() => "Forth Bean";

      // The bean name is fifthBean
      @bean String fifthBean() => "Fifth Bean";

      // This gets autowired without issue
      @autowired void method(@Qualifier("namedBean") String value) {}
    }
