package com.macquarie.odyssey.model;

import com.google.cloud.spring.data.spanner.core.mapping.Column;
import com.google.cloud.spring.data.spanner.core.mapping.PrimaryKey;
import com.google.cloud.spring.data.spanner.core.mapping.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data // Generates getters, setters, toString, etc.
@AllArgsConstructor // Generates a constructor with all arguments.
@NoArgsConstructor // Generates a no-argument constructor.
@Table(name = "Auditors")
public class Auditor {

    @PrimaryKey
    @Column(name = "AuditorId")
    private String auditorId;

    private String name;

    private String company;

    // This field will hold the date as a string from the CSV.
    private String registrationDate;
}