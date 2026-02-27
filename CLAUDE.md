# CLAUDE.md — sist_prj3_eLearnWeb

AI-assistant reference for the **sist_prj3_eLearnWeb** Spring Boot e-learning platform.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Architecture & Design Patterns](#architecture--design-patterns)
5. [Configuration & Environment](#configuration--environment)
6. [Database & MyBatis](#database--mybatis)
7. [URL Routing Conventions](#url-routing-conventions)
8. [Authentication & Session Management](#authentication--session-management)
9. [External Integrations](#external-integrations)
10. [Thymeleaf Templates](#thymeleaf-templates)
11. [Development Workflow](#development-workflow)
12. [Known Issues & In-Progress Work](#known-issues--in-progress-work)

---

## Project Overview

An e-learning web platform (similar to Inflearn/Udemy) built as a team capstone project. It supports three distinct user roles:

| Role | Description |
|---|---|
| **Admin** | System administration, content moderation, member management |
| **Instructor** | Course creation, chapter/test management, revenue tracking |
| **User (Student)** | Course enrollment, video learning, quiz taking, payment |

Core features: lecture catalog, chapter video progress, quiz/test system, payment (TossPayments), review system, attendance dashboard, email/SMS authentication.

---

## Technology Stack

| Category | Technology | Version |
|---|---|---|
| Language | Java | 17 |
| Framework | Spring Boot | 4.0.2 |
| MVC | Spring WebMVC | (Boot-managed) |
| View | Thymeleaf | (Boot-managed) |
| ORM/SQL | MyBatis | 4.0.1 |
| Database | Oracle Database | ojdbc11 |
| Boilerplate | Lombok | (Boot-managed) |
| Encryption | Spring Security Crypto | 7.0.2 |
| JSON | json-simple | 1.1.1 |
| Email | Spring Boot Mail (JavaMail) | (Boot-managed) |
| SMS | Solapi SDK | 4.3.2 |
| Build | Maven (mvnw wrapper) | — |

---

## Project Structure

```
sist_prj3_eLearnWeb/
├── pom.xml                             # Maven build config
├── mvnw / mvnw.cmd                     # Maven wrapper executables
├── src/
│   ├── main/
│   │   ├── java/kr/co/sist/           # All Java source code
│   │   └── resources/
│   │       ├── application.properties      # Base config (sets active profiles)
│   │       ├── application-dev.properties  # Dev environment config
│   │       ├── mappers/                    # MyBatis XML mapper files
│   │       │   ├── admin/
│   │       │   ├── common/
│   │       │   ├── instructor/
│   │       │   └── user/
│   │       ├── templates/                  # Thymeleaf HTML templates
│   │       │   ├── admin/
│   │       │   ├── common/
│   │       │   ├── fragments/              # Reusable layout components
│   │       │   ├── instructor/
│   │       │   └── user/
│   │       └── static/                     # CSS, images
│   │           ├── admin/
│   │           ├── common/
│   │           └── css/
│   └── test/
│       └── java/kr/co/sist/
│           └── SistPrj3ELearnWebApplicationTests.java
```

### Java Package Structure

```
kr/co/sist/
├── SistPrj3ELearnWebApplication.java   # Main entry point (@SpringBootApplication)
├── DevController.java                   # Dev navigation at /dev
├── config/
│   └── WebMvcConfig.java               # Resource handler for /images/** → C:/upload/
├── common/
│   ├── email/EmailService.java         # Gmail SMTP email sender, auth code generator
│   ├── member/                         # Shared member ops (find ID/PW)
│   └── util/CryptoUtil.java            # AES-256 encrypt/decrypt utility
├── admin/
│   ├── announcement/                   # CRUD for system announcements
│   ├── dashboard/                      # Admin statistics dashboard
│   ├── lecture/                        # Lecture approval/moderation
│   ├── login/                          # Admin authentication
│   ├── member/                         # User & instructor management
│   ├── payment/                        # Payment analytics
│   ├── question/                       # (placeholder — not yet implemented)
│   └── review/                         # (placeholder — not yet implemented)
├── instructor/
│   ├── lecture/test/                   # Test/quiz creation and management
│   ├── member/                         # Instructor profile
│   │   └── login/                      # Instructor authentication
│   └── payment/                        # Revenue tracking
└── user/
    ├── lecture/
    │   ├── chapter/                    # Chapter list, video playback, progress
    │   ├── review/                     # Lecture reviews (CRUD)
    │   └── test/                       # Quiz taking and result recording
    ├── member/                         # Registration, profile
    │   └── login/                      # User login/logout
    ├── my/
    │   ├── dashboard/                  # Learning dashboard & attendance
    │   ├── lecture/                    # Enrolled lectures
    │   ├── payrec/                     # Purchase records
    │   ├── profile/                    # Profile editing
    │   └── setting/                    # Account settings (password change, etc.)
    └── payment/                        # Cart, TossPayments integration
```

---

## Architecture & Design Patterns

### Layered MVC (per feature package)

Every feature follows this 5-layer pattern:

```
Controller → Service → Mapper (interface) → XML Mapper → Oracle DB
                 ↕
            Domain / DTO
```

| Layer | Role | Annotation |
|---|---|---|
| **Controller** | HTTP handling, session access, Model population, view resolution | `@Controller` |
| **Service** | Business logic, pagination calculation, exception wrapping | `@Service` |
| **Mapper** | MyBatis interface (SQL query declarations) | `@Mapper` |
| **Domain** | DB result objects, `@Alias` for MyBatis type aliases | `@Alias("...")` |
| **DTO** | Request data from forms / HTTP params | plain POJO |

### Conventions

- **Domain** classes use `@Alias("camelCaseName")` for MyBatis `resultType` references.
- **Lombok** annotations (`@Getter`, `@Setter`, `@ToString`) are used on most Domain/DTO classes. Do not add explicit getters/setters.
- **`@Autowired`** field injection is the used pattern throughout. Do not refactor to constructor injection without team agreement.
- **Controller bean naming**: When multiple modules have a controller for the same concept (e.g., login), the controller uses an explicit bean name:
  ```java
  @Controller("userLoginController")
  @Controller("adminLoginController")
  ```
- **Pagination logic** is computed inside the Service layer. Pattern: `totalCnt()`, `pageScale()`, `totalPage()`, `startNum()`, `endNum()`, and `pagination2()` methods.
- **Method naming**: Mapper methods follow `select/insert/update/delete` + noun pattern (e.g., `selectRangeAnnouncement`, `insertAnnouncement`).

### Mapper XML Conventions

- Namespace must match the fully-qualified Mapper interface: `namespace="kr.co.sist.admin.announcement.AdminAnnouncementMapper"`.
- `resultType` uses the MyBatis alias (from `@Alias`) or primitive types.
- `parameterType` uses the alias or `Integer`, `String`, etc.
- Oracle-specific patterns:
  - Sequences: `seq_<table>_id.nextval`
  - Pagination: `ROW_NUMBER() OVER (ORDER BY ...) rnum` with `WHERE rnum BETWEEN #{startNum} AND #{endNum}`
  - Null handling: `NVL(...)` for nullables

---

## Configuration & Environment

### Profiles

The application uses Spring profile layering:
```properties
# application.properties
spring.profiles.active=dev,local
```

- `dev` → `application-dev.properties` (committed, development defaults)
- `local` → `application-local.properties` (not committed, personal overrides)

### Key Settings (`application-dev.properties`)

```properties
# Server
server.port=8080
server.servlet.session.timeout=10m

# Oracle DB
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@localhost:1521:orcl
spring.datasource.username=scott
spring.datasource.password=tiger

# MyBatis
mybatis.mapper-locations=classpath:mappers/**/**/*.xml
mybatis.type-aliases-package=kr.co.sist.user.lecture, kr.co.sist.user.lecture.chapter, ...
mybatis.configuration.log-impl=org.apache.ibatis.logging.stdout.StdOutImpl

# File upload
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=100MB
user.upload-dir=C:/upload/

# Encryption
user.crypto.key=test1234
user.crypto.salt=ABCDEF12345678

# Email (Gmail)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
```

> **Important**: `C:/upload/` is a Windows-specific path used for file uploads and static image serving. Change in `application-local.properties` on non-Windows environments.

### Adding a New MyBatis Type Alias

When adding a new Domain class that should be referenced in mapper XML as a short alias, add its package to `mybatis.type-aliases-package` in `application-dev.properties`.

---

## Database & MyBatis

### Mapper XML Location

```
src/main/resources/mappers/
├── admin/
│   ├── adminAnnouncementMapper.xml
│   ├── adminMemberMapper.xml
│   ├── dashboardMapper.xml
│   ├── lectureMapper.xml
│   ├── loginMapper.xml
│   └── payment.xml
├── common/
│   └── commonMemberMapper.xml
├── instructor/
│   ├── instPaymentMapper.xml
│   ├── instructorMemberMapper.xml
│   ├── loginMapper.xml
│   └── testMapper.xml
└── user/
    ├── loginMapper.xml
    ├── memberMapper.xml
    ├── profileMapper.xml
    ├── settingMapper.xml
    ├── userDashboardMapper.xml
    ├── userMyLectureMapper.xml
    ├── userPaymentMapper.xml
    ├── userReviewMapper.xml
    ├── userTestMapper.xml
    └── lecture/
        ├── chapterMapper.xml
        └── lectureMapper.xml
```

### Oracle-Specific SQL Patterns

```xml
<!-- Oracle sequence for auto-increment -->
<insert id="insertAnnouncement" parameterType="announcementDTO">
  INSERT INTO announcement(ann_id, title, ...)
  VALUES(seq_announcement_id.nextval, #{title}, ...)
</insert>

<!-- Oracle pagination using ROW_NUMBER() -->
<select id="selectRangeSomething" resultType="someDomain">
  SELECT col1, col2
  FROM (
    SELECT col1, col2,
           ROW_NUMBER() OVER (ORDER BY regdate DESC) rnum
    FROM some_table
    <where>
      <if test="keyword neq null and keyword neq ''">
        INSTR(${fieldStr}, #{keyword}) != 0
      </if>
    </where>
  )
  WHERE rnum BETWEEN #{startNum} AND #{endNum}
</select>
```

---

## URL Routing Conventions

| User Role | URL Base | Example |
|---|---|---|
| Admin | `/admin/` | `/admin/announcement/announcementList` |
| Instructor | `/instructor/` | `/instructor/lecture/test/instTestFrm` |
| User/Student | `/user/` | `/user/lecture/lectureList` |
| Common (all) | `/common/` | `/common/member/findIdFrm` |
| Dev utility | `/dev` | `/dev` |

### Controller Mapping Pattern

```java
@RequestMapping("/admin/announcement")   // Class-level prefix
@Controller
public class AdminAnnouncementController {
    @GetMapping("/announcementList")     // Full: GET /admin/announcement/announcementList
    @PostMapping("/announcementWriteFrmProcess")  // Full: POST /admin/announcement/announcementWriteFrmProcess
}
```

### Return Values (View vs Redirect)

- Return a template path string → renders Thymeleaf view (no leading `/` for user module, leading `/` for admin/instructor):
  ```java
  return "user/member/login/loginFrm";        // Resolves to /templates/user/member/login/loginFrm.html
  return "/admin/announcement/announcementList"; // Resolves with leading slash too
  ```
- Return `"redirect:/path"` → issues HTTP redirect.

---

## Authentication & Session Management

### Session Keys

| Role | Key | Value Type | Set By |
|---|---|---|---|
| User | `userId` | String | `LoginController` |
| User | `userName` | String | `LoginController` |
| User | `userEmail` | String | `LoginController` |
| Admin | `adm_id` | String | `AdminLoginController` |
| Instructor | *(TBD)* | — | Instructor login |

### Password Handling

Passwords are stored encrypted. `CryptoUtil` (in `common/util/`) provides AES-256 encryption using a fixed IV (deterministic):

```java
@Autowired
private CryptoUtil cryptoUtil;

String encrypted = cryptoUtil.encrypt("plainText");
String plain = cryptoUtil.decrypt("encryptedHex");
String safe = cryptoUtil.decryptSafe("encryptedHex"); // returns null on failure, no exception
```

Key and salt are injected from `application-dev.properties`:
```properties
user.crypto.key=test1234
user.crypto.salt=ABCDEF12345678
```

### Important Security Gaps (Active TODOs)

- **No interceptor** is currently implemented. Unauthenticated users can access protected URLs by typing them directly. An `HandlerInterceptor` must be added to redirect to login for protected paths.
- Some controllers temporarily hardcode the session values (e.g., `session.setAttribute("adm_id", "admin1")`). These are marked `// 임시` (temporary) in the code.

---

## External Integrations

### TossPayments

Implemented in `user/payment/PaymentController.java`. Calls `https://api.tosspayments.com/v1/payments/confirm` with Basic auth.

> **Warning**: The `TOSS_SECRET_KEY` is currently hardcoded in the controller source. It should be moved to `application-dev.properties` and injected via `@Value("${toss.secret-key}")`.

### Email (Gmail SMTP)

Implemented in `common/email/EmailService.java`. Sends HTML email with a 6-character alphanumeric auth code. Uses JavaMail directly.

```java
@Autowired
private EmailService emailService;
String code = emailService.sendAuthCode("user@example.com"); // returns null on failure
```

### SMS (Solapi)

Solapi SDK is configured with credentials in `application-dev.properties`. Used for phone number verification.

### Static File Serving

User-uploaded files are stored on disk at `C:/upload/`. They are served via:

```java
// WebMvcConfig.java
registry.addResourceHandler("/images/**")
        .addResourceLocations("file:///C:/upload/");
```

Access as: `http://localhost:8080/images/filename.jpg`

---

## Thymeleaf Templates

### Fragment Includes (Reusable Layout)

Located in `src/main/resources/templates/fragments/`:

| Fragment File | Purpose |
|---|---|
| `header.html` | User-facing site header |
| `footer.html` | Site footer |
| `adminHeader.html` | Admin panel header |
| `adminSidebar.html` | Admin panel sidebar |
| `MyHeader.html` | My-page header |
| `MySidebar.html` | My-page sidebar |
| `cdn.html` | CDN JS/CSS includes (Bootstrap, etc.) |

Include fragments in templates:
```html
<div th:replace="~{fragments/header :: header}"></div>
```

### Mapper XML in Templates Directory

There are mapper XML files placed inside `src/main/resources/templates/` (not the correct `mappers/` directory):
- `templates/common/mappers/mapper.xml`
- `templates/instructor/mappers/mapper.xml`
- `templates/user/mappers/mapper.xml`

These appear to be misplaced and are **not loaded** by MyBatis (which only scans `classpath:mappers/**/**/*.xml`). Move SQL to the correct `src/main/resources/mappers/` directory.

---

## Development Workflow

### Build & Run

```bash
# Run the application (requires Oracle DB running locally)
./mvnw spring-boot:run

# Build JAR
./mvnw clean package

# Run tests
./mvnw test

# Skip tests during build
./mvnw clean package -DskipTests
```

### Prerequisites

1. Oracle Database running at `localhost:1521` with SID `orcl`, user `scott/tiger`.
2. Upload directory: Create `C:/upload/` (Windows) or configure `user.upload-dir` in `application-local.properties` for other OS.
3. Java 17 installed.

### Development Convenience

- **Spring Boot DevTools** is enabled — the app auto-restarts on class file changes.
- **MyBatis SQL logging** is enabled — all SQL is printed to the console.
- **Thymeleaf cache** is disabled — template changes are reflected immediately.
- Visit `http://localhost:8080/dev` for a development navigation index page.

### Adding a New Feature

1. Create the feature package under the appropriate role module (e.g., `kr.co.sist.user.myfeature/`).
2. Add `Domain.java` (with `@Alias`, Lombok) and `DTO.java` if needed.
3. Add `Mapper.java` interface (with `@Mapper`).
4. Add `mapper.xml` in `src/main/resources/mappers/<role>/`.
5. If using a new type alias, add the package to `mybatis.type-aliases-package` in `application-dev.properties`.
6. Add `Service.java` with `@Service`.
7. Add `Controller.java` with `@Controller` and `@RequestMapping`.
8. Add Thymeleaf template under `src/main/resources/templates/<role>/myfeature/`.

### Git Branching

- Main integrated branch: `master` (or `devLast` on remote).
- Feature branches are named per developer (e.g., `njw2001_3`, `ljw0232_0210`).
- Integration is done via pull requests into `devLast`.

---

## Known Issues & In-Progress Work

| Issue | Location | Status |
|---|---|---|
| No login interceptor/route guard | `config/` | Missing — must be implemented |
| Hardcoded session values (`// 임시`) | Multiple controllers | Temporary dev shortcuts |
| TossPayments secret key in source | `user/payment/PaymentController.java:35` | Should use `@Value` |
| Hardcoded user/lecture IDs in controllers | `user/lecture/chapter/ChapterController.java` | Test code, replace with session/path vars |
| Misplaced mapper XML in templates dir | `templates/*/mappers/mapper.xml` | Not loaded by MyBatis; move to `mappers/` |
| Admin question/review modules | `admin/question/`, `admin/review/` | Empty placeholders |
| Instructor announcement/dashboard | `instructor/announcement/`, `instructor/dashboard/` | Empty placeholders |
| Windows-specific upload path | `application-dev.properties`, `WebMvcConfig.java` | Use env var or profile override |
| No meaningful unit tests | `src/test/` | Only context load test exists |
