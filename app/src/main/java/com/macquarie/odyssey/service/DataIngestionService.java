package com.macquarie.odyssey.service;

import com.macquarie.odyssey.model.Auditor;
import com.macquarie.odyssey.repository.AuditorRepository;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class DataIngestionService {

    private static final Logger log = LoggerFactory.getLogger(DataIngestionService.class);
    // URL for the ASIC Registered Auditor dataset CSV file
    private static final String DATA_URL = "https://data.gov.au/data/dataset/01548c24-1138-4958-8187-54b92b604533/resource/5347a61a-5_96-419b-a627-5f1113a3e4a3/download/asic_registered-auditors_202401.csv";

    @Autowired
    private AuditorRepository auditorRepository;

    public void ingestAuditorData() throws IOException, CsvValidationException {
        log.info("🚚 Starting data ingestion process from URL: {}", DATA_URL);
        
        RestTemplate restTemplate = new RestTemplate();
        String csvData = restTemplate.getForObject(DATA_URL, String.class);

        if (csvData == null) {
            log.error("Failed to fetch data from the URL.");
            throw new IOException("No data received from URL.");
        }

        List<Auditor> auditorsToSave = new ArrayList<>();
        try (CSVReader reader = new CSVReader(new StringReader(csvData))) {
            // Skip the header row
            reader.readNext(); 

            String[] line;
            while ((line = reader.readNext()) != null) {
                // Assuming CSV format: "Name", "Company", "Registration Date"
                Auditor auditor = new Auditor(
                        UUID.randomUUID().toString(), // Generate a unique ID for the Spanner primary key
                        line[0], // Name
                        line[1], // Company
                        line[2]  // RegistrationDate
                );
                auditorsToSave.add(auditor);
            }
        }
        
        log.info("Parsed {} records. Saving to Spanner...", auditorsToSave.size());
        // Save all parsed auditors to the database in a single transaction
        auditorRepository.saveAll(auditorsToSave);

        log.info("✅ Data ingestion complete.");
    }
}