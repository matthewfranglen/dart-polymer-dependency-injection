part of polymer_dependency_injection;

class AbstractHtmlInjectConfiguration extends AbstractInjectConfiguration {

  static final Logger log = new Logger('AbstractHtmlInjectConfiguration');

  AbstractHtmlInjectConfiguration();

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
