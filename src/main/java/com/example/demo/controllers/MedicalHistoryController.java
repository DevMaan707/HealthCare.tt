package com.example.demo.controllers;

import java.util.List;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.MedicalHistory;
import com.example.demo.models.User;
import com.example.demo.payload.request.MedicalHistoryRequest;
import com.example.demo.payload.response.MessageResponse;
import com.example.demo.repositories.MedicalHistoryRepository;
import com.example.demo.repositories.UserRepository;
import com.example.demo.security.services.UserDetailsImpl;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/medical")
public class MedicalHistoryController {
    @Autowired
    private MedicalHistoryRepository medicalHistoryRepository;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/history")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> addMedicalHistory(@Valid @RequestBody MedicalHistoryRequest medicalHistoryRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Error: User not found."));

        MedicalHistory medicalHistory = new MedicalHistory();
        medicalHistory.setUser(user);
        medicalHistory.setCondition(medicalHistoryRequest.getCondition());
        medicalHistory.setDiagnosis(medicalHistoryRequest.getDiagnosis());
        medicalHistory.setDiagnosisDate(medicalHistoryRequest.getDiagnosisDate());
        medicalHistory.setTreatment(medicalHistoryRequest.getTreatment());
        medicalHistory.setMedications(medicalHistoryRequest.getMedications());

        medicalHistoryRepository.save(medicalHistory);

        return ResponseEntity.ok(new MessageResponse("Medical history added successfully!"));
    }

    @GetMapping("/history")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<MedicalHistory>> getMedicalHistories() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        
        List<MedicalHistory> medicalHistories = medicalHistoryRepository.findByUserId(userDetails.getId());
        
        return ResponseEntity.ok(medicalHistories);
    }
}