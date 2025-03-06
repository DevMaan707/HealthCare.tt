package com.example.demo.controllers;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.DailyData;
import com.example.demo.models.User;
import com.example.demo.payload.request.DailyDataRequest;
import com.example.demo.payload.response.MessageResponse;
import com.example.demo.repositories.DailyDataRepository;
import com.example.demo.repositories.UserRepository;
import com.example.demo.security.services.UserDetailsImpl;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/data")
public class DailyDataController {
    @Autowired
    private DailyDataRepository dailyDataRepository;

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/daily")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> addOrUpdateDailyData(@Valid @RequestBody DailyDataRequest dailyDataRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Error: User not found."));

        Optional<DailyData> existingDataOpt = dailyDataRepository.findByUserIdAndDate(
                userDetails.getId(), dailyDataRequest.getDate());
        
        DailyData dailyData;
        
        if (existingDataOpt.isPresent()) {
            dailyData = existingDataOpt.get();
        } else {
            dailyData = new DailyData();
            dailyData.setUser(user);
            dailyData.setDate(dailyDataRequest.getDate());
        }
        
        dailyData.setSteps(dailyDataRequest.getSteps());
        dailyData.setDistance(dailyDataRequest.getDistance());
        dailyData.setCaloriesBurned(dailyDataRequest.getCaloriesBurned());
        dailyData.setHeartRate(dailyDataRequest.getHeartRate());
        dailyData.setBloodPressureSystolic(dailyDataRequest.getBloodPressureSystolic());
        dailyData.setBloodPressureDiastolic(dailyDataRequest.getBloodPressureDiastolic());

        dailyDataRepository.save(dailyData);

        return ResponseEntity.ok(new MessageResponse("Daily data saved successfully!"));
    }

    @GetMapping("/daily")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<DailyData>> getDailyData() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        
        List<DailyData> dailyDataList = dailyDataRepository.findByUserId(userDetails.getId());
        
        return ResponseEntity.ok(dailyDataList);
    }

    @GetMapping("/daily/{date}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> getDailyDataByDate(@PathVariable String date) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        
        LocalDate parsedDate = LocalDate.parse(date);
        
        Optional<DailyData> dailyData = dailyDataRepository.findByUserIdAndDate(userDetails.getId(), parsedDate);
        
        return dailyData.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}