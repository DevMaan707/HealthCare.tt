package com.example.demo.repositories;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.models.DailyData;

@Repository
public interface DailyDataRepository extends JpaRepository<DailyData, Long> {
    List<DailyData> findByUserId(Long userId);
    Optional<DailyData> findByUserIdAndDate(Long userId, LocalDate date);
}