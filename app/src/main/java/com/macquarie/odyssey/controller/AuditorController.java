package com.macquarie.odyssey.controller;

import com.macquarie.odyssey.model.Auditor;
import com.macquarie.odyssey.repository.AuditorRepository;
import com.macquarie.odyssey.service.DataIngestionService; // Import the service
import com.opencsv.exceptions.CsvValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.http.ResponseEntity; // Import ResponseEntity
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping; // Import PostMapping
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@RestController
@RequestMapping("/api/auditors")
public class AuditorController {

    @Autowired
    private AuditorRepository auditorRepository;
    
    // Inject the new DataIngestionService
    @Autowired
    private DataIngestionService dataIngestionService;

    @GetMapping
    public List<Auditor> getAllAuditors() {
        return StreamSupport.stream(auditorRepository.findAll().spliterator(), false)
                .collect(Collectors.toList());
    }

    @QueryMapping
    public List<Auditor> auditors() {
        return getAllAuditors();
    }
    
    /**
     * POST /api/auditors/ingest
     * Triggers the ingestion of auditor data from the external source.
     */
    @PostMapping("/ingest")
    public ResponseEntity<String> triggerIngestion() {
        try {
            dataIngestionService.ingestAuditorData();
            return ResponseEntity.ok("Data ingestion process started successfully.");
        } catch (IOException | CsvValidationException e) {
            // In a real app, you'd have more robust error handling
            return ResponseEntity.status(500).body("Error during data ingestion: " + e.getMessage());
        }
    }
}