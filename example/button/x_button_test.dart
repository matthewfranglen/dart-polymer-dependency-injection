library polymer_dependency_injection.example.test.test_button;

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

  Feature feature = new Feature("Can press button");

  feature.load(new _Steps());

  feature.scenario("Can press button")
    .given("a button")
    .when("I press the button")
    .then("the incrementable is incremented")
    .test();
}

class _Steps {

  @Given("a button")
  void makeConfiguration(Map<String, dynamic> context) {
    Configuration configuration;

    configuration = new Configuration();
    configuration.scan(document.querySelector("body"));
    configuration.configure();

    context["configuration"] = configuration;
    context["button"] = document.querySelector("x-button::shadow button");
  }

  @When("I press the button")
  void callConfigure(Map<String, dynamic> context) {
    (context["button"] as ButtonElement).click();
  }

  @Then("the incrementable is incremented")
  void testConfigurationFails(Map<String, dynamic> context) {
    Configuration configuration = context["configuration"] as Configuration;

    expect(configuration.incrementable.incrementCalled, isTrue);
  }
}

class Configuration extends AbstractHtmlInjectConfiguration {
  @autowired MockIncrementable incrementable;

  @bean MockIncrementable makeIncrementable() => new MockIncrementable();
}

class MockIncrementable implements Incrementable {
  bool incrementCalled = false;

  void increment() {
    incrementCalled = true;
  }
}

// vim: set ai et sw=2 syntax=dart :
