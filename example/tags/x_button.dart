library polymer_dependency_injection.example.button;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:dependency_injection/dependency_injection.dart';
import '../interfaces.dart';

@CustomTag('x-button')
@component
class ButtonTag extends PolymerElement {

  @autowired Incrementable incrementor;

  ButtonTag.created() : super.created();

  void increment(Event e, var detail, Node target) {
    incrementor.increment();
  }
}

// vim: set ai et sw=2 syntax=dart :
