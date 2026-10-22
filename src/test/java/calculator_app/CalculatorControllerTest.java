package calculator_app;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorControllerTest {

    private final CalculatorController calculator =
            new CalculatorController();

    @Test
    void testAddition() {
        assertEquals(30.0, calculator.calculate(20, 10, "add"));
    }

    @Test
    void testSubtraction() {
        assertEquals(10.0, calculator.calculate(20, 10, "subtract"));
    }

    @Test
    void testMultiplication() {
        assertEquals(200.0, calculator.calculate(20, 10, "multiply"));
    }

    @Test
    void testDivision() {
        assertEquals(2.0, calculator.calculate(20, 10, "divide"));
    }
}