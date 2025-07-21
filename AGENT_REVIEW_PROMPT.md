# Multi-Agent PRD and Database Review Prompt

## Overview
I want to review the current state of the PRD and the database scripts. To that end, I want to create multiple agents and have them review the documents.

## Agent Definitions

### Agent 1 - System Summary Analyst
- **Responsibility**: Understanding the system summary, roles and features
- **Task**: Read PRD.md, lines 1-104
- **Focus Areas**:
  - Core system purpose and goals
  - User roles (members, admins, staff)
  - Key features outlined
  - User requirements and expectations

### Agent 2 - Architecture Analyst
- **Responsibility**: Understanding the system architecture
- **Task**: Read PRD.md, lines 106-371
- **Focus Areas**:
  - Technical stack and components
  - Database design requirements
  - API structure and endpoints
  - System integrations
  - Data models and relationships

### Agent 3 - Security Analyst
- **Responsibility**: Understanding the security requirements
- **Task**: Read PRD.md, lines 373-439
- **Focus Areas**:
  - Authentication and authorization requirements
  - Data protection measures
  - Privacy considerations
  - Security policies and constraints
  - Compliance requirements

### Agent 4 - Database Schema Analyst
- **Responsibility**: Understanding the database structure, functions and triggers
- **Task**: Read supabase/schema.sql
- **Focus Areas**:
  - All tables and their columns
  - Data types and constraints
  - Relationships between tables (foreign keys)
  - Database functions
  - Triggers and their purposes
  - Indexes and performance considerations

### Agent 5 - Migration Analyst
- **Responsibility**: Understanding how the migrations are structured
- **Task**: Read all files in supabase/migrations/ directory
- **Focus Areas**:
  - Migration order and dependencies
  - What each migration accomplishes
  - Whether migrations align with the schema.sql
  - Any potential conflicts or missing migrations
  - Whether running migrations from scratch would produce the same result as schema.sql

### Agent 6 - UI Requirements Analyst
- **Responsibility**: Understanding the user interface requirements and ensuring they align with database capabilities
- **Task**: Read PRD.md, lines 475-484 (Section 5: User Interface Requirements)
- **Focus Areas**:
  - Design principles and UX guidelines
  - Key pages/screens and their data requirements
  - Responsive design considerations
  - Data display needs vs available database fields
  - UI features that require specific database support
  - Identifying any UI requirements that lack database backing

### Agent 7 - Project Manager Coordinator
- **Responsibility**: Coordinating all other agents and synthesizing their reports
- **Task**: Wait for reports from all 6 other agents, then analyze and synthesize
- **Focus Areas**:
  - Consistency between PRD requirements and database implementation
  - Identifying gaps where PRD features lack database support
  - Identifying database structures not mentioned in PRD
  - Verifying security requirements are implemented in database
  - Ensuring data models align between PRD and schema
  - Confirming UI requirements have necessary database support
  - Confirming migrations and schema.sql would produce identical databases
  - Proposing specific solutions for any identified gaps

## Execution Requirements

1. **Parallel Execution**: All agents *MUST* run simultaneously in parallel
2. **Consistency Check**: Ensure that the PRD is consistent with the schema and migration plans
3. **Migration Validation**: The schema and migrations should result in the exact same database if run from scratch
4. **Alignment Verification**: The database schema should align fully with the PRD
5. **Gap Analysis**: Identify gaps and propose solutions to ensure that the plan doesn't diverge from the PRD

## Expected Output

Each agent should provide a structured report that the Project Manager agent can use to create a comprehensive analysis including:
- Summary of findings
- List of inconsistencies
- Recommended actions
- Priority of fixes