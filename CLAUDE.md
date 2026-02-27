# CLAUDE.md — sist_prj3_eLearnWeb

**sist_prj3_eLearnWeb** Spring Boot 이러닝 플랫폼을 위한 AI 어시스턴트 참고 문서입니다.

> **중요**: 이 프로젝트에서 AI 어시스턴트는 **항상 한국어로 답변**해야 합니다.

---

## 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [기술 스택](#기술-스택)
3. [프로젝트 구조](#프로젝트-구조)
4. [아키텍처 및 설계 패턴](#아키텍처-및-설계-패턴)
5. [설정 및 환경](#설정-및-환경)
6. [데이터베이스 및 MyBatis](#데이터베이스-및-mybatis)
7. [URL 라우팅 규칙](#url-라우팅-규칙)
8. [인증 및 세션 관리](#인증-및-세션-관리)
9. [외부 연동](#외부-연동)
10. [Thymeleaf 템플릿](#thymeleaf-템플릿)
11. [개발 워크플로](#개발-워크플로)
12. [알려진 문제 및 진행 중인 작업](#알려진-문제-및-진행-중인-작업)

---

## 프로젝트 개요

인프런/유데미와 유사한 이러닝 웹 플랫폼으로, 팀 캡스톤 프로젝트로 개발되었습니다. 세 가지 사용자 역할을 지원합니다:

| 역할 | 설명 |
|---|---|
| **관리자 (Admin)** | 시스템 관리, 콘텐츠 검토, 회원 관리 |
| **강사 (Instructor)** | 강의 생성, 챕터/테스트 관리, 수익 조회 |
| **사용자/수강생 (User)** | 강의 수강 신청, 영상 학습, 퀴즈 응시, 결제 |

주요 기능: 강의 목록, 챕터 영상 진도 관리, 퀴즈/테스트 시스템, 결제(TossPayments), 리뷰 시스템, 출석 대시보드, 이메일/SMS 인증.

---

## 기술 스택

| 분류 | 기술 | 버전 |
|---|---|---|
| 언어 | Java | 17 |
| 프레임워크 | Spring Boot | 4.0.2 |
| MVC | Spring WebMVC | (Boot 관리) |
| 뷰 | Thymeleaf | (Boot 관리) |
| ORM/SQL | MyBatis | 4.0.1 |
| 데이터베이스 | Oracle Database | ojdbc11 |
| 보일러플레이트 | Lombok | (Boot 관리) |
| 암호화 | Spring Security Crypto | 7.0.2 |
| JSON | json-simple | 1.1.1 |
| 이메일 | Spring Boot Mail (JavaMail) | (Boot 관리) |
| SMS | Solapi SDK | 4.3.2 |
| 빌드 | Maven (mvnw 래퍼) | — |

---

## 프로젝트 구조

```
sist_prj3_eLearnWeb/
├── pom.xml                             # Maven 빌드 설정
├── mvnw / mvnw.cmd                     # Maven 래퍼 실행 파일
├── src/
│   ├── main/
│   │   ├── java/kr/co/sist/           # 전체 Java 소스 코드
│   │   └── resources/
│   │       ├── application.properties      # 기본 설정 (활성 프로파일 지정)
│   │       ├── application-dev.properties  # 개발 환경 설정
│   │       ├── mappers/                    # MyBatis XML 매퍼 파일
│   │       │   ├── admin/
│   │       │   ├── common/
│   │       │   ├── instructor/
│   │       │   └── user/
│   │       ├── templates/                  # Thymeleaf HTML 템플릿
│   │       │   ├── admin/
│   │       │   ├── common/
│   │       │   ├── fragments/              # 재사용 가능한 레이아웃 컴포넌트
│   │       │   ├── instructor/
│   │       │   └── user/
│   │       └── static/                     # CSS, 이미지
│   │           ├── admin/
│   │           ├── common/
│   │           └── css/
│   └── test/
│       └── java/kr/co/sist/
│           └── SistPrj3ELearnWebApplicationTests.java
```

### Java 패키지 구조

```
kr/co/sist/
├── SistPrj3ELearnWebApplication.java   # 메인 진입점 (@SpringBootApplication)
├── DevController.java                   # 개발용 네비게이션 (/dev)
├── config/
│   └── WebMvcConfig.java               # 리소스 핸들러 설정 (/images/** → C:/upload/)
├── common/
│   ├── email/EmailService.java         # Gmail SMTP 이메일 발송, 인증코드 생성
│   ├── member/                         # 공통 회원 기능 (아이디/비밀번호 찾기)
│   └── util/CryptoUtil.java            # AES-256 암호화/복호화 유틸리티
├── admin/
│   ├── announcement/                   # 공지사항 CRUD
│   ├── dashboard/                      # 관리자 통계 대시보드
│   ├── lecture/                        # 강의 승인/검토
│   ├── login/                          # 관리자 인증
│   ├── member/                         # 회원 및 강사 관리
│   ├── payment/                        # 결제 분석
│   ├── question/                       # (플레이스홀더 — 미구현)
│   └── review/                         # (플레이스홀더 — 미구현)
├── instructor/
│   ├── lecture/test/                   # 테스트/퀴즈 생성 및 관리
│   ├── member/                         # 강사 프로필
│   │   └── login/                      # 강사 인증
│   └── payment/                        # 수익 조회
└── user/
    ├── lecture/
    │   ├── chapter/                    # 챕터 목록, 영상 재생, 진도 관리
    │   ├── review/                     # 강의 리뷰 (CRUD)
    │   └── test/                       # 퀴즈 응시 및 결과 기록
    ├── member/                         # 회원가입, 프로필
    │   └── login/                      # 사용자 로그인/로그아웃
    ├── my/
    │   ├── dashboard/                  # 학습 대시보드 및 출석
    │   ├── lecture/                    # 수강 중인 강의
    │   ├── payrec/                     # 구매 내역
    │   ├── profile/                    # 프로필 편집
    │   └── setting/                    # 계정 설정 (비밀번호 변경 등)
    └── payment/                        # 장바구니, TossPayments 연동
```

---

## 아키텍처 및 설계 패턴

### 계층형 MVC (기능별 패키지)

모든 기능은 다음 5계층 패턴을 따릅니다:

```
Controller → Service → Mapper (인터페이스) → XML Mapper → Oracle DB
                 ↕
            Domain / DTO
```

| 계층 | 역할 | 어노테이션 |
|---|---|---|
| **Controller** | HTTP 처리, 세션 접근, Model 데이터 설정, 뷰 반환 | `@Controller` |
| **Service** | 비즈니스 로직, 페이지네이션 계산, 예외 처리 | `@Service` |
| **Mapper** | MyBatis 인터페이스 (SQL 쿼리 선언) | `@Mapper` |
| **Domain** | DB 결과 객체, MyBatis 타입 별칭용 `@Alias` | `@Alias("...")` |
| **DTO** | 폼/HTTP 파라미터 요청 데이터 | 일반 POJO |

### 코딩 컨벤션

- **Domain** 클래스는 MyBatis `resultType` 참조를 위해 `@Alias("camelCaseName")`을 사용합니다.
- **Lombok** 어노테이션(`@Getter`, `@Setter`, `@ToString`)을 대부분의 Domain/DTO 클래스에 사용합니다. 명시적인 getter/setter를 추가하지 마세요.
- **`@Autowired`** 필드 주입 방식을 프로젝트 전반에서 사용합니다. 팀 합의 없이 생성자 주입으로 변경하지 마세요.
- **Controller 빈 이름 명시**: 여러 모듈에 같은 개념의 컨트롤러가 있을 때(예: login), 명시적 빈 이름을 사용합니다:
  ```java
  @Controller("userLoginController")
  @Controller("adminLoginController")
  ```
- **페이지네이션 로직**은 Service 계층에서 계산합니다. 패턴: `totalCnt()`, `pageScale()`, `totalPage()`, `startNum()`, `endNum()`, `pagination2()` 메서드.
- **메서드 명명**: Mapper 메서드는 `select/insert/update/delete` + 명사 패턴을 따릅니다 (예: `selectRangeAnnouncement`, `insertAnnouncement`).

### Mapper XML 규칙

- namespace는 Mapper 인터페이스의 전체 경로와 일치해야 합니다: `namespace="kr.co.sist.admin.announcement.AdminAnnouncementMapper"`.
- `resultType`은 MyBatis 별칭(`@Alias`) 또는 기본 타입을 사용합니다.
- `parameterType`은 별칭 또는 `Integer`, `String` 등을 사용합니다.
- Oracle 전용 패턴:
  - 시퀀스: `seq_<table>_id.nextval`
  - 페이지네이션: `ROW_NUMBER() OVER (ORDER BY ...) rnum` + `WHERE rnum BETWEEN #{startNum} AND #{endNum}`
  - Null 처리: `NVL(...)`

---

## 설정 및 환경

### 프로파일

Spring 프로파일 계층을 사용합니다:
```properties
# application.properties
spring.profiles.active=dev,local
```

- `dev` → `application-dev.properties` (커밋됨, 개발 기본값)
- `local` → `application-local.properties` (커밋 안 됨, 개인 설정 덮어쓰기)

### 주요 설정 (`application-dev.properties`)

```properties
# 서버
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

# 파일 업로드
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=100MB
user.upload-dir=C:/upload/

# 암호화
user.crypto.key=test1234
user.crypto.salt=ABCDEF12345678

# 이메일 (Gmail)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
```

> **중요**: `C:/upload/`는 Windows 전용 경로입니다. Windows가 아닌 환경에서는 `application-local.properties`에서 `user.upload-dir`을 변경해야 합니다.

### 새 MyBatis 타입 별칭 추가

mapper XML에서 짧은 별칭으로 참조할 새 Domain 클래스를 추가할 때는, `application-dev.properties`의 `mybatis.type-aliases-package`에 해당 패키지를 추가하세요.

---

## 데이터베이스 및 MyBatis

### Mapper XML 위치

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

### Oracle 전용 SQL 패턴

```xml
<!-- Oracle 시퀀스를 이용한 자동 증가 -->
<insert id="insertAnnouncement" parameterType="announcementDTO">
  INSERT INTO announcement(ann_id, title, ...)
  VALUES(seq_announcement_id.nextval, #{title}, ...)
</insert>

<!-- ROW_NUMBER()를 이용한 Oracle 페이지네이션 -->
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

## URL 라우팅 규칙

| 사용자 역할 | URL 기본 경로 | 예시 |
|---|---|---|
| 관리자 | `/admin/` | `/admin/announcement/announcementList` |
| 강사 | `/instructor/` | `/instructor/lecture/test/instTestFrm` |
| 사용자/수강생 | `/user/` | `/user/lecture/lectureList` |
| 공통 (전체) | `/common/` | `/common/member/findIdFrm` |
| 개발 유틸리티 | `/dev` | `/dev` |

### Controller 매핑 패턴

```java
@RequestMapping("/admin/announcement")   // 클래스 레벨 접두사
@Controller
public class AdminAnnouncementController {
    @GetMapping("/announcementList")             // 전체: GET /admin/announcement/announcementList
    @PostMapping("/announcementWriteFrmProcess")  // 전체: POST /admin/announcement/announcementWriteFrmProcess
}
```

### 반환 값 (뷰 vs 리다이렉트)

- 템플릿 경로 문자열 반환 → Thymeleaf 뷰 렌더링 (user 모듈은 앞에 `/` 없음, admin/instructor는 `/` 포함):
  ```java
  return "user/member/login/loginFrm";          // /templates/user/member/login/loginFrm.html 으로 해석
  return "/admin/announcement/announcementList"; // 앞에 슬래시 있어도 동작
  ```
- `"redirect:/path"` 반환 → HTTP 리다이렉트 발생.

---

## 인증 및 세션 관리

### 세션 키

| 역할 | 키 | 값 타입 | 설정 위치 |
|---|---|---|---|
| 사용자 | `userId` | String | `LoginController` |
| 사용자 | `userName` | String | `LoginController` |
| 사용자 | `userEmail` | String | `LoginController` |
| 관리자 | `adm_id` | String | `AdminLoginController` |
| 강사 | *(미정)* | — | 강사 로그인 |

### 비밀번호 처리

비밀번호는 암호화하여 저장합니다. `CryptoUtil`(`common/util/`)은 고정 IV 방식의 AES-256 암호화를 제공합니다 (결정론적: 같은 입력 → 같은 출력):

```java
@Autowired
private CryptoUtil cryptoUtil;

String encrypted = cryptoUtil.encrypt("평문");
String plain = cryptoUtil.decrypt("암호문(Hex)");
String safe = cryptoUtil.decryptSafe("암호문(Hex)"); // 실패 시 null 반환, 예외 없음
```

키와 salt는 `application-dev.properties`에서 주입됩니다:
```properties
user.crypto.key=test1234
user.crypto.salt=ABCDEF12345678
```

### 주요 보안 미비 사항 (진행 중인 TODO)

- **인터셉터 없음**: 현재 인터셉터가 구현되어 있지 않아 미로그인 사용자가 URL을 직접 입력하여 보호된 페이지에 접근할 수 있습니다. 보호된 경로에 대해 로그인 페이지로 리다이렉트하는 `HandlerInterceptor`를 추가해야 합니다.
- 일부 컨트롤러에서 세션 값을 임시로 하드코딩하고 있습니다 (예: `session.setAttribute("adm_id", "admin1")`). 코드에 `// 임시` 주석으로 표시되어 있습니다.

---

## 외부 연동

### TossPayments

`user/payment/PaymentController.java`에 구현되어 있습니다. Basic 인증으로 `https://api.tosspayments.com/v1/payments/confirm`을 호출합니다.

> **경고**: `TOSS_SECRET_KEY`가 현재 컨트롤러 소스에 하드코딩되어 있습니다. `application-dev.properties`로 이동하여 `@Value("${toss.secret-key}")`로 주입받아야 합니다.

### 이메일 (Gmail SMTP)

`common/email/EmailService.java`에 구현되어 있습니다. 6자리 영숫자 인증 코드를 HTML 이메일로 발송합니다. JavaMail을 직접 사용합니다.

```java
@Autowired
private EmailService emailService;
String code = emailService.sendAuthCode("user@example.com"); // 실패 시 null 반환
```

### SMS (Solapi)

Solapi SDK는 `application-dev.properties`에 설정된 자격증명을 사용합니다. 휴대전화 번호 인증에 사용됩니다.

### 정적 파일 서빙

사용자 업로드 파일은 디스크의 `C:/upload/`에 저장됩니다. 다음 설정으로 서빙됩니다:

```java
// WebMvcConfig.java
registry.addResourceHandler("/images/**")
        .addResourceLocations("file:///C:/upload/");
```

접근 URL: `http://localhost:8080/images/파일명.jpg`

---

## Thymeleaf 템플릿

### Fragment 포함 (재사용 가능한 레이아웃)

`src/main/resources/templates/fragments/`에 위치합니다:

| Fragment 파일 | 용도 |
|---|---|
| `header.html` | 사용자용 사이트 헤더 |
| `footer.html` | 사이트 푸터 |
| `adminHeader.html` | 관리자 패널 헤더 |
| `adminSidebar.html` | 관리자 패널 사이드바 |
| `MyHeader.html` | 마이페이지 헤더 |
| `MySidebar.html` | 마이페이지 사이드바 |
| `cdn.html` | CDN JS/CSS 포함 (Bootstrap 등) |

템플릿에서 Fragment 포함 방법:
```html
<div th:replace="~{fragments/header :: header}"></div>
```

### 잘못 배치된 Mapper XML

`src/main/resources/templates/` 내부에 mapper XML 파일이 잘못 배치되어 있습니다:
- `templates/common/mappers/mapper.xml`
- `templates/instructor/mappers/mapper.xml`
- `templates/user/mappers/mapper.xml`

이 파일들은 MyBatis가 스캔하지 않아 **로드되지 않습니다** (MyBatis는 `classpath:mappers/**/**/*.xml`만 스캔). 올바른 위치인 `src/main/resources/mappers/`로 이동해야 합니다.

---

## 개발 워크플로

### 빌드 및 실행

```bash
# 애플리케이션 실행 (로컬 Oracle DB 필요)
./mvnw spring-boot:run

# JAR 빌드
./mvnw clean package

# 테스트 실행
./mvnw test

# 테스트 생략하고 빌드
./mvnw clean package -DskipTests
```

### 사전 요구 사항

1. `localhost:1521`, SID `orcl`, 계정 `scott/tiger`로 Oracle Database 실행 중이어야 합니다.
2. 업로드 디렉토리: `C:/upload/` 생성(Windows) 또는 `application-local.properties`에서 `user.upload-dir` 설정(다른 OS).
3. Java 17 설치.

### 개발 편의 기능

- **Spring Boot DevTools** 활성화 — 클래스 파일 변경 시 앱 자동 재시작.
- **MyBatis SQL 로깅** 활성화 — 모든 SQL이 콘솔에 출력됨.
- **Thymeleaf 캐시** 비활성화 — 템플릿 변경 사항이 즉시 반영됨.
- `http://localhost:8080/dev` 에서 개발용 네비게이션 인덱스 페이지 접근 가능.

### 새 기능 추가 순서

1. 적절한 역할 모듈 아래에 기능 패키지 생성 (예: `kr.co.sist.user.myfeature/`).
2. 필요한 경우 `Domain.java`(`@Alias`, Lombok 포함)와 `DTO.java` 추가.
3. `@Mapper` 어노테이션을 붙인 `Mapper.java` 인터페이스 추가.
4. `src/main/resources/mappers/<role>/`에 `mapper.xml` 추가.
5. 새 타입 별칭이 필요한 경우 `application-dev.properties`의 `mybatis.type-aliases-package`에 패키지 추가.
6. `@Service` 어노테이션을 붙인 `Service.java` 추가.
7. `@Controller`와 `@RequestMapping`을 붙인 `Controller.java` 추가.
8. `src/main/resources/templates/<role>/myfeature/`에 Thymeleaf 템플릿 추가.

### Git 브랜칭

- 메인 통합 브랜치: `master` (원격에서는 `devLast`).
- 피처 브랜치는 개발자별로 명명합니다 (예: `njw2001_3`, `ljw0232_0210`).
- Pull Request를 통해 `devLast`로 통합합니다.

---

## 알려진 문제 및 진행 중인 작업

| 문제 | 위치 | 상태 |
|---|---|---|
| 로그인 인터셉터/라우트 가드 없음 | `config/` | 미구현 — 반드시 추가 필요 |
| 하드코딩된 세션 값 (`// 임시`) | 여러 컨트롤러 | 임시 개발 편의용 코드 |
| TossPayments 시크릿 키 소스에 하드코딩 | `user/payment/PaymentController.java:35` | `@Value`로 주입받아야 함 |
| 컨트롤러에 하드코딩된 사용자/강의 ID | `user/lecture/chapter/ChapterController.java` | 테스트 코드, 세션/경로 변수로 교체 필요 |
| 잘못 배치된 mapper XML | `templates/*/mappers/mapper.xml` | MyBatis가 로드하지 않음, `mappers/`로 이동 필요 |
| 관리자 질문/리뷰 모듈 | `admin/question/`, `admin/review/` | 빈 플레이스홀더 |
| 강사 공지사항/대시보드 | `instructor/announcement/`, `instructor/dashboard/` | 빈 플레이스홀더 |
| Windows 전용 업로드 경로 | `application-dev.properties`, `WebMvcConfig.java` | 환경변수 또는 프로파일 오버라이드 사용 필요 |
| 유의미한 단위 테스트 없음 | `src/test/` | 컨텍스트 로드 테스트만 존재 |
