package pageobjects;

import library.selenium.core.Element;
import library.selenium.exec.BasePO;
import org.openqa.selenium.By;


public class ExamplePageObject extends BasePO {

    private By register = By.xpath("//a[text()='Create New Account']");

    public Element register() {
        return $(register);
    }

}
