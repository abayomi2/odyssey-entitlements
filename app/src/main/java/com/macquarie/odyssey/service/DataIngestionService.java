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

    // --- Updated Data Source URL ---
    private static final String DATA_URL = "https://data.gov.au/data/dataset/4117fdec-3eff-44a1-9b78-869f7ec5c409/resource/0f2e41ec-6f49-4d35-8e6d-ebcd4a0e3e27/download/reg_auditor_202507.csv";

    @Autowired
    private AuditorRepository auditorRepository;

    public void ingestAuditorData() throws IOException, CsvValidationException {
        log.info("🚚 Starting data ingestion process from new URL: {}", DATA_URL);
        
        RestTemplate restTemplate = new RestTemplate();
        String csvData = restTemplate.getForObject(DATA_URL, String.class);

        if (csvData == null) {
            log.error("Failed to fetch data from the URL.");
            throw new IOException("No data received from URL.");
        }

        List<Auditor> auditorsToSave = new ArrayList<>();
        try (CSVReader reader = new CSVReader(new StringReader(csvData))) {
            reader.readNext(); // Skip header row

            String[] line;
            int rowNum = 1;
            while ((line = reader.readNext()) != null) {
                rowNum++;
                // --- Updated validation and mapping ---
                if (line.length >= 6) { // Check for at least 6 columns
                    Auditor auditor = new Auditor(
                            UUID.randomUUID().toString(),
                            line[1], // Auditor Name
                            line[2], // Company Name
                            line[5]  // Registration Start Date
                    );
                    auditorsToSave.add(auditor);
                } else {
                    log.warn("Skipping malformed row number {}: Found {} columns, expected at least 6", rowNum, line.length);
                }
            }
        }
        
        log.info("Parsed and validated {} records. Saving to Spanner...", auditorsToSave.size());
        auditorRepository.saveAll(auditorsToSave);

        log.info("✅ Data ingestion complete.");
    }
}




// package com.macquarie.odyssey.service;

// import com.macquarie.odyssey.model.Auditor;
// import com.macquarie.odyssey.repository.AuditorRepository;
// import com.opencsv.CSVReader;
// import com.opencsv.exceptions.CsvValidationException;
// import org.slf4j.Logger;
// import org.slf4j.LoggerFactory;
// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.stereotype.Service;
// import org.springframework.util.StringUtils;
// import org.springframework.web.client.RestTemplate;

// import java.io.IOException;
// import java.io.StringReader;
// import java.util.ArrayList;
// import java.util.List;
// import java.util.UUID;

// @Service
// public class DataIngestionService {

//     private static final Logger log = LoggerFactory.getLogger(DataIngestionService.class);
//     private static final String DATA_URL = "https://data.gov.au/data/dataset/01548c24-1138-4958-8187-54b92b604533/resource/5347a61a-5f96-419b-a627-5f1113a3e4a3/download/asic_registered-auditors_202401.csv";

//     @Autowired
//     private AuditorRepository auditorRepository;

//     public void ingestAuditorData() throws IOException, CsvValidationException {
//         log.info("🚚 Starting data ingestion process from URL: {}", DATA_URL);
        
//         RestTemplate restTemplate = new RestTemplate();
//         String csvData = restTemplate.getForObject(DATA_URL, String.class);

//         if (csvData == null) {
//             log.error("Failed to fetch data from the URL.");
//             throw new IOException("No data received from URL.");
//         }

//         List<Auditor> auditorsToSave = new ArrayList<>();
//         try (CSVReader reader = new CSVReader(new StringReader(csvData))) {
//             reader.readNext(); // Skip header row

//             String[] line;
//             int rowNum = 1;
//             while ((line = reader.readNext()) != null) {
//                 rowNum++;
//                 // --- START: Added robustness check ---
//                 // Ensure the row has at least the minimum number of columns we need
//                 if (line.length >= 3) {
//                     Auditor auditor = new Auditor(
//                             UUID.randomUUID().toString(),
//                             line[0], // Name
//                             line[1], // Company
//                             line[2]  // RegistrationDate
//                     );
//                     auditorsToSave.add(auditor);
//                 } else {
//                     log.warn("Skipping malformed row number {}: Found {} columns, expected at least 3", rowNum, line.length);
//                 }
//                 // --- END: Added robustness check ---
//             }
//         }
        
//         log.info("Parsed and validated {} records. Saving to Spanner...", auditorsToSave.size());
//         auditorRepository.saveAll(auditorsToSave);

//         log.info("✅ Data ingestion complete.");
//     }
// }