part of polymer_dependency_injection;

/// Controls the creation and registration of all [Bean] instances and populates [Autowired] fields, methods and setters.
///
/// Application configuration is performed by a subclass of this class.
/// Application configuration is the process of creating all beans and
/// providing beans for every autowired field.
///
/// This class can contain [Bean] creating methods. Such a method must return a
/// value and be annotated with _@Bean()_ or _@bean_. The type of the bean is
/// taken from the value of the returned object, not from the method
/// definition.
///
/// This class can also scan the DOM for any [PolymerElement] that has the
/// [Component] annotation. Every component element will be registered as a
/// bean and can contain [Autowired] methods, setters and fields. The DOM
/// scanning will traverse the shadow DOM of any [PolymerElement] found.
///
/// The configuration class will:
///
/// * Create the beans that come from bean creating methods
/// * Inject beans into autowired fields, including all beans found through
///   DOM scanning
///
/// when it is configured. You trigger this configuration by calling
/// [configure]. Any DOM scanning must be invoked before calling configure.
///
/// A _Configuration Bean_ is a [Bean] which has a type with the
/// [Configuration] annotation. Configuration Beans can contain [Bean] creating
/// methods just like the [AbstractHtmlInjectConfiguration] subclass. The beans
/// created by a configuration bean are available to all classes for
/// autowiring. The configuration bean and all beans it creates are eligible
/// for autowiring.
///
/// Autowiring allows a method, setter or field to be provided with a bean.
/// Every bean and the [AbstractHtmlInjectConfiguration] subclass are eligible for
/// autowiring. Autowiring assigns by type. This is done by testing that the
/// bean can be assigned to the autowired field. When you define a method or
/// setter as autowired all of the parameters will be set to the appropriate
/// bean and then the method will be invoked.
///
/// When there are multiple beans that can be assigned to an autowired field
/// then the autowiring fails. If there are no beans then the autowiring also
/// fails. When the autowiring fails an exception is thrown.
///
/// For more details see the [Autowired] and [Bean] annotations.
///
///     class Configuration extends AbstractHtmlInjectConfiguration {
///       // This will get invoked and the result will be available as a bean
///       @bean ExampleSubClass makeBean() => new ExampleSubClass();
///
///       // This will get invoked with the bean created by makeBean
///       @bean ExampleMixin makeMixin(ExampleSubClass otherBean) => new ExampleMixin();
///
///       // This will get invoked with autowired arguments
///       @autowired void autowiredMethod(ExampleSubClass bean, ExampleMixin mixin) {}
///
///       // This will also get invoked with autowired arguments
///       @autowired set mixin(ExampleMixin mixin) {}
///
///       // This will NOT get set - no bean can be assigned to the parameter
///       @autowired String missingType;
///
///       // This will NOT get invoked - both beans can be assigned to the parameter
///       @autowired void ambiguousMethod(ExampleClass bean) {}
///
///       // This will get loaded by DOM scanning
///       @autowired void scannedAutowire(Element domBean) {}
///     }
///     class ExampleClass {}
///     class ExampleSubClass extends ExampleClass {}
///     class ExampleMixin extends Object with ExampleClass {}
///
///     // This creates all the beans and autowires all fields, methods and setters.
///     // Since the ambiguousMethod cannot be autowired this will throw an exception.
///     new Configuration()
///       .scan(document.querySelector('body'))
///       .configure();
class AbstractHtmlInjectConfiguration extends AbstractInjectConfiguration {

  static final Logger log = new Logger('AbstractHtmlInjectConfiguration');

  AbstractHtmlInjectConfiguration();

  /// Scan the DOM for any [PolymerElement] annotated with [Component].
  ///
  /// This inspects the element and every child element recursively looking for
  /// any [PolymerElement] with a [Component] annotation. The scanning will
  /// search the shadow DOM of any [PolymerElement] found. The element passed
  /// to this method does not have to be a [PolymerElement].
  ///
  /// This allows you to define elements which are autowired and which can be
  /// provided to other elements through dependency injection. This can
  /// dramatically reduce the amount of coupling between elements.
  ///
  /// ### index.html
  ///     <body>
  ///       <custom-element></custom-element>
  ///       <another-custom-element></another-custom-element>
  ///     </body>
  ///
  /// ### element dart code
  ///     @CustomTag('custom-element') @component class CustomElement {
  ///       @autowired AnotherCustomElement otherElement;
  ///       ...
  ///     }
  ///     @CustomTag('another-custom-element') @component class AnotherCustomElement {
  ///       ...
  ///     }
  ///
  /// ### configuration
  ///     new AbstractHtmlInjectConfiguration()
  ///       ..scan(document.querySelector('body'))
  ///       ..configure();
  void scan(Element root) {
    _findPolymerElements(root)
      .where(InstanceAnnotationFacade.filterByAnnotation(Component))
      .forEach(addBean);
  }

  List<PolymerElement> _findPolymerElements(Element root) {
    List<PolymerElement> results = [];
    var searchClosure;

    searchClosure = (Element element) {
      _searchForPolymerElements(element, results, searchClosure);
    };
    searchClosure(root);

    return results;
  }

  void _searchForPolymerElements(Element element, List<PolymerElement> results, var searchClosure) {
    if (element is PolymerElement) {
      log.fine("Found ${element}");
      results.add(element);

      element.shadowRoot.childNodes
        .where(_isElement)
        .forEach(searchClosure);
    }
    element.children.forEach(searchClosure);
  }

  bool _isElement(Node node) => node is Element;
}

// vim: set ai et sw=2 syntax=dart :
