
package calculator_app;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class CalculatorController {

    @GetMapping("/api/calculate")
    public double calculate(
            @RequestParam double a,
            @RequestParam double b,
            @RequestParam String operation) {

        return switch (operation) {
            case "add" -> a + b;
            case "subtract" -> a - b;
            case "multiply" -> a * b;
            case "divide" -> {
                if (b == 0) {
                    throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Cannot divide by zero"
                    );
                }
                yield a / b;
            }
            default -> throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Invalid operation"
            );
        };
    }
}
