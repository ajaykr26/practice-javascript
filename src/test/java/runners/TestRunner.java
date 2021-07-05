package runners;

@CucumberOptions(tags = {"@ScenarioOne", "not @ignored"})
public class SmokeTest extends AutoEngBaseTestAPI {

}