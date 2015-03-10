library polymer_dependency_injection.example;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:polymer_dependency_injection/polymer_dependency_injection.dart';

void main() {
  initPolymer().run(() {
    Polymer.onReady.then(load);
  });
}

void load(v) {
  new Configuration()
    ..scan(document.querySelector('body'))
    ..configure();
}

class Configuration extends AbstractHtmlInjectConfiguration {}

// vim: set ai et sw=2 syntax=dart :
