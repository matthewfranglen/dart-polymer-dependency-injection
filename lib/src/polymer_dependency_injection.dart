part of polymer_dependency_injection;

class AbstractHtmlInjectConfiguration extends AbstractInjectConfiguration {

  AbstractHtmlInjectConfiguration();

  void scan(Element root) {
    _findPolymerElements(root)
      .where(objectHasAnnotationFilter(Component))
      .map((PolymerElement element) => new BeanInstance(element))
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
      print("Found ${element}");
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
