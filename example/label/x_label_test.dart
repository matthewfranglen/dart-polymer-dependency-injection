library polymer_dependency_injection.example.test.test_label;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:logging/logging.dart';
import 'package:behave/behave.dart';
import 'package:polymer_dependency_injection/polymer_dependency_injection.dart';
import '../interfaces.dart';


void main() {
  configureLogging();
  initPolymer().then((v) {
    Polymer.onReady.then(runTests);
  });
}

void configureLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.forEach(print);
}

void runTests(v) {
  useHtmlConfiguration();

  Feature feature = new Feature("Can increment label");

  feature.load(new _Steps());

  feature.scenario("Can increment label")
    .given("a label")
    .when("I increment the incrementable")
    .then("the label is updated")
    .test();
}

class _Steps {

  @Given("a label")
  void makeConfiguration(Map<String, dynamic> context) {
    Configuration configuration;

    configuration = new Configuration();
    configuration.scan(document.querySelector("body"));
    configuration.configure();

    context["configuration"] = configuration;
    context["label"] = document.querySelector("x-label::shadow p");
  }

  @When("I increment the incrementable")
  void callConfigure(Map<String, dynamic> context) {
    Configuration configuration = context["configuration"] as Configuration;
    configuration.incrementable.increment();
  }

  @Then("the label is updated")
  void testConfigurationFails(Map<String, dynamic> context) {
    Element label = context["label"] as Element;
    Duration oneMillisecond = new Duration(milliseconds: 1);

    // Must delay the test otherwise polymer cannot update the HTML
    new Future.delayed(oneMillisecond, () => expect(label.text, contains("1")));
  }
}

class Configuration extends AbstractHtmlInjectConfiguration {
  @autowired Incrementable incrementable;
}

// vim: set ai et sw=2 syntax=dart :
