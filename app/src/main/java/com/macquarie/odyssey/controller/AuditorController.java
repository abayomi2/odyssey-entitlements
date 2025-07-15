package com.macquarie.odyssey.controller;

import com.macquarie.odyssey.model.Auditor;
import com.macquarie.odyssey.repository.AuditorRepository;
import com.macquarie.odyssey.service.DataIngestionService;
import com.opencsv.exceptions.CsvValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin; // <-- Ensure this import is present
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@RestController
@RequestMapping("/api/auditors")
@CrossOrigin(origins = "*") // <-- This annotation allows requests from your frontend
public class AuditorController {

    @Autowired
    private AuditorRepository auditorRepository;

    @Autowired
    private DataIngestionService dataIngestionService;

    @GetMapping
    public List<Auditor> getAllAuditors() {
        return StreamSupport.stream(auditorRepository.findAll().spliterator(), false)
                .collect(Collectors.toList());
    }

    @PostMapping("/ingest")
    public ResponseEntity<String> triggerIngestion() {
        try {
            dataIngestionService.ingestAuditorData();
            return ResponseEntity.ok("Data ingestion process started successfully.");
        } catch (IOException | CsvValidationException e) {
            return ResponseEntity.status(500).body("Error during data ingestion: " + e.getMessage());
        }
    }
}