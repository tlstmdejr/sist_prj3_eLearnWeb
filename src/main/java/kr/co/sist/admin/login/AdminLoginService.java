package kr.co.sist.admin.login;

import kr.co.sist.admin.member.AdminDTO;
import kr.co.sist.admin.member.AdminDomain;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.exceptions.PersistenceException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * 관리자 - 로그인 서비스
 */
@Slf4j
@Service
public class AdminLoginService {

    private final AdminLoginMapper adminLoginMapper;

    public AdminLoginService(AdminLoginMapper adminLoginMapper) {
        this.adminLoginMapper = adminLoginMapper;
    }

    /**
     * 로그인 인증 (BCrypt 해시 검증)
     *
     * @param adminDTO 로그인 정보
     * @return 로그인 성공 시 관리자 도메인, 실패 시 null
     */
    public AdminDomain login(AdminDTO adminDTO) {
        AdminDomain adminDomain = null;
        try {
            AdminDomain tempAdmin = adminLoginMapper.selectAdmin(adminDTO.getId());
            if (tempAdmin != null) {
                BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
                if (encoder.matches(adminDTO.getPassword(), tempAdmin.getPassword())) {
                    adminDomain = tempAdmin;
                }
            }
        } catch (PersistenceException pe) {
            log.error("관리자 로그인 처리 실패 - id: {}", adminDTO.getId(), pe);
        }
        return adminDomain;
    }

}
