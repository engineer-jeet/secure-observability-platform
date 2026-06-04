package com.demo;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@RestController
public class CheckoutController {

    private final RestTemplate restTemplate =
        new RestTemplate();

    @PostMapping("/checkout")
    public Map<String,String> checkout(
            @RequestBody Map<String,Object> req) {

        restTemplate.postForObject(
            "http://payment-service.apps.svc.cluster.local:3000/payment",
            Map.of(
                "amount",100
            ),
            String.class
        );

        restTemplate.postForObject(
            "http://notification-service.apps.svc.cluster.local:4000/notify",
            Map.of(
                "email","bishwajeet@example.com",
                "message","Order Confirmed"
            ),
            String.class
        );

        return Map.of(
            "status",
            "CHECKOUT_SUCCESS"
        );
    }
}