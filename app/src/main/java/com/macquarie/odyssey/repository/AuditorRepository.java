package com.macquarie.odyssey.repository;

import com.google.cloud.spring.data.spanner.repository.SpannerRepository;
import com.macquarie.odyssey.model.Auditor;
import org.springframework.stereotype.Repository;

// This interface extends SpannerRepository to provide CRUD operations for the Auditor entity.
@Repository
public interface AuditorRepository extends SpannerRepository<Auditor, String> {
}