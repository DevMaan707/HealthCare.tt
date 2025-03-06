package com.example.demo.payload.request;

import java.time.LocalDate;
import jakarta.validation.constraints.NotNull;

public class DailyDataRequest {
    @NotNull
    private LocalDate date;
    private Integer steps;
    private Float distance;
    private Integer caloriesBurned;
    private Integer heartRate;
    private Float bloodPressureSystolic;
    private Float bloodPressureDiastolic;
    
    // Getters
    public LocalDate getDate() { return date; }
    public Integer getSteps() { return steps; }
    public Float getDistance() { return distance; }
    public Integer getCaloriesBurned() { return caloriesBurned; }
    public Integer getHeartRate() { return heartRate; }
    public Float getBloodPressureSystolic() { return bloodPressureSystolic; }
    public Float getBloodPressureDiastolic() { return bloodPressureDiastolic; }
    
    // Setters
    public void setDate(LocalDate date) { this.date = date; }
    public void setSteps(Integer steps) { this.steps = steps; }
    public void setDistance(Float distance) { this.distance = distance; }
    public void setCaloriesBurned(Integer caloriesBurned) { this.caloriesBurned = caloriesBurned; }
    public void setHeartRate(Integer heartRate) { this.heartRate = heartRate; }
    public void setBloodPressureSystolic(Float bloodPressureSystolic) { this.bloodPressureSystolic = bloodPressureSystolic; }
    public void setBloodPressureDiastolic(Float bloodPressureDiastolic) { this.bloodPressureDiastolic = bloodPressureDiastolic; }
}
