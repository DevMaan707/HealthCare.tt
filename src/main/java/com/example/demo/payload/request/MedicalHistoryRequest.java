package com.example.demo.payload.request;

import java.time.LocalDate;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class MedicalHistoryRequest {
    private String condition;
    private String diagnosis;
    private LocalDate diagnosisDate;
    private String treatment;
    private String medications;
    
    // Getters
    public String getCondition() {
        return condition;
    }
    
    public String getDiagnosis() {
        return diagnosis;
    }
    
    public LocalDate getDiagnosisDate() {
        return diagnosisDate;
    }
    
    public String getTreatment() {
        return treatment;
    }
    
    public String getMedications() {
        return medications;
    }
    
    // Setters
    public void setCondition(String condition) {
        this.condition = condition;
    }
    
    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }
    
    public void setDiagnosisDate(LocalDate diagnosisDate) {
        this.diagnosisDate = diagnosisDate;
    }
    
    public void setTreatment(String treatment) {
        this.treatment = treatment;
    }
    
    public void setMedications(String medications) {
        this.medications = medications;
    }
}