# Identity Design

## Objective
Establish the first identity structure for the cloud platform.

## User Categories

### Standard employee users
Used for normal daily work such as email, collaboration, and business applications.

### Information Technology support users
Used by technical support staff. These users may have elevated operational needs but should not automatically use privileged administrator access for daily work.

### Privileged administrator users
Separate high-privilege identities used for administrative tasks. These are not yet created in the first build stage.

## Group Categories

### Department groups
- Finance Team
- Human Resources Team
- Information Technology Support Team

### Access groups
- Payroll Application Users

## Access Design Principles
- Prefer group-based assignment over direct assignment
- Use least privilege
- Separate normal user identities from privileged administrator identities
- Keep naming clear and descriptive

## Sample Users
- Sarah Johnson — Finance Officer
- David Clarke — Human Resources Manager
- Michael Evans — Information Technology Support Engineer

## Sample Group Membership
- Sarah Johnson → Finance Team
- Sarah Johnson → Payroll Application Users
- David Clarke → Human Resources Team
- Michael Evans → Information Technology Support Team
