@AllTests @Basic @Parallel=false
Feature: Get Dog Facts

  @DogFacts
  Scenario: Dog facts
    Given url EndPointURL + DogResources

