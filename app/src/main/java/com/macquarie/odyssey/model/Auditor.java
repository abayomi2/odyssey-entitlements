package com.macquarie.odyssey.model;

import com.google.cloud.spring.data.spanner.core.mapping.Column;
import com.google.cloud.spring.data.spanner.core.mapping.PrimaryKey;
import com.google.cloud.spring.data.spanner.core.mapping.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "Auditors")
public class Auditor {

    @PrimaryKey
    @Column(name = "AuditorId")
    private String auditorId;

    // Add annotations to match the database schema
    @Column(name = "Name")
    private String name;

    @Column(name = "Company")
    private String company;

    @Column(name = "RegistrationDate")
    private String registrationDate;
}